/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for ProspectTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vladislav Polovtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.1
* @created        2019-05-23
* @modified       2019-08-27
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ProspectHandler extends TriggerHandler {        
    
    private Map<Id, nu_dse__Prospect__c> newProspectMap;
    private Map<Id, nu_dse__Prospect__c> oldProspectMap;
    private Set<Id> prospectIds;
    
    public ProspectHandler() {
        this.newProspectMap = (Map<Id, nu_dse__Prospect__c>) Trigger.newMap;
        this.oldProspectMap = (Map<Id, nu_dse__Prospect__c>) Trigger.oldMap;
    }
    
    Map<Id, String> disqualifiedProspectIdUuIdMap = new Map<Id, String>(); // Map of Prospect Id and UUId 
    List<nu_dse__Prospect__c> velocifyLeadList = new List<nu_dse__Prospect__c>(); //List of Prospect for velocify update
    Set<Id> velocifyProspectIds = new Set<Id>(); // Set of Prospect Ids for Velocify modify leads
    Map<String, List<nu_dse__Prospect__c>> prospectSSN_ProspectsMap = new Map<String, List<nu_dse__Prospect__c>>(); //contains ssn of all prospects for duplicate validation
    Map<Id, nu_dse__Prospect__c> updateProspectMap = new Map<Id, nu_dse__Prospect__c>();
    List<Enrolled_Agreement_Details__c> insertEA = new List<Enrolled_Agreement_Details__c>();
    Set<Id> ssnProspectIds = new Set<Id>();

    public override void beforeInsert() {
       
        List<BusinessHours> bussinessHourList = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        
        for (nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) {  
            // method to update offBusinessHours checkbox in prospect records
            if(bussinessHourList.isEmpty() == false) {
                updateProspectsOffBussinessHours(newProspect, bussinessHourList);
            }
            // Update Uuid in Prospect records 
            updateUuIdProspects(newProspect);
            // updates Owner from Five9 Owner field, if Has_Been_Assigned__c is set to TRUE
            updateProspectOwner(newProspect, null);
            // validation to check if any duplicate SSN in available for other records
            //collectAllProspectSSN(newProspect, null);
        }
        //checkDuplicateAndTagAccount(); 
	
    }
    
    public override void afterInsert() {

        for (nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) { 

            // validation to check if any duplicate SSN in available for other records
            collectAllProspectSSN(newProspect, null);
        } 

        if(prospectSSN_ProspectsMap.isEmpty() == false
            || updateProspectMap.isEmpty() == false) {
            
            prospectHandler.SSNDuplicateReferWrap reqWrap = new prospectHandler.SSNDuplicateReferWrap();
            reqWrap.prospectIds = ssnProspectIds;
            reqWrap.ssnProspectMap = prospectSSN_ProspectsMap;
            reqWrap.updateProspectMap = updateProspectMap;
            prospectHandler.updateSSNDuplicateReference(JSON.serialize(reqWrap));
        }
    }
    
    public override void beforeUpdate() {
        
        for (nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) {  
            // Update Uuid in Prospect records 
            updateUuIdProspects(newProspect);
            // Call method for Collect Send Disqualified Disposition Type prospect records
            collectDisqualifiedProspects(newProspect);
            //Update Prospect Owner from Five9 Owner Id value if Has been assigned it set to true
            updateProspectOwner(newProspect, oldProspectMap.get(newProspect.Id));
            // validation to check if any duplicate SSN in available for other records
            // collectAllProspectSSN(newProspect,oldProspectMap.get(newProspect.Id));
        } 

        // checkDuplicateAndTagAccount(); 

        if(disqualifiedProspectIdUuIdMap.isEmpty() == false) {
            updateDispositionEmailType();
        }
    }
    
    public void createSnapshot(nu_dse__Prospect__c snapProspect)
    {
        if(snapProspect.Create_Snapshot__c)
        {	
            snapProspect.Create_Snapshot__c = false;
            Enrolled_Agreement_Details__c snapObj = new Enrolled_Agreement_Details__c();
            snapObj.Prospect_Id__c = snapProspect.Id;
            insertEA.add(snapObj);
            updateProspectMap.put(snapProspect.ID,snapProspect);
        }
	}

    public override void afterUpdate() {
        
        this.prospectIds = trigger.newMap.keySet();
        List<nu_dse__Prospect__c> prospects = [SELECT ID,Recalled_Approval__c FROM nu_dse__Prospect__c WHERE Id IN :prospectIds];
        Boolean RecalledApproval;
        for (nu_dse__Prospect__c newProspect: prospects)
        {
            RecalledApproval = newProspect.Recalled_Approval__c;
            newProspect.Recalled_Approval__c = false;
            if(RecalledApproval)
            {
                List<ProcessInstance> instances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId=:newProspect.Id AND Status='Pending' LIMIT 1];
                if (!instances.isEmpty())
                {
                    ProcessInstance instance = instances[0];
                    List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId=:instance.Id LIMIT 1];
                    if (!workItems.isEmpty())
                    {
                        ProcessInstanceWorkItem workItem = workItems[0];
                        Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                        req.setWorkItemId(workItem.Id);
                        req.setAction('Removed');
                        req.setComments('Recalled Approval from ACE');
                        Approval.ProcessResult result = Approval.process(req);
                    }
                }
            }
        }
        
        for(nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) {
            //collect prospect Ids of all prospects when prospect status is changed
            collectVelocifyLeadIds(newProspect, oldProspectMap.get(newProspect.Id));
            // validation to check if any duplicate SSN in available for other records
            collectAllProspectSSN(newProspect,oldProspectMap.get(newProspect.Id));
            //generate snapshot if flag is set
            createSnapshot(newProspect);
        }
        insert insertEA;

        if(prospectSSN_ProspectsMap.isEmpty() == false
            || updateProspectMap.isEmpty() == false) {
            
            prospectHandler.SSNDuplicateReferWrap reqWrap = new prospectHandler.SSNDuplicateReferWrap();
            reqWrap.prospectIds = ssnProspectIds;
            reqWrap.ssnProspectMap = prospectSSN_ProspectsMap;
            reqWrap.updateProspectMap = updateProspectMap;
            prospectHandler.updateSSNDuplicateReference(JSON.serialize(reqWrap));
        }

        if(velocifyLeadList.isEmpty() == false) {
            String leadListJson = JSON.serialize(velocifyLeadList);
            //Pushes fields from prospect to velocify based on datamapping record named "Velocifyleads"
            VelocifyLeadHandler.modifyLeads_Async(velocifyProspectIds);
            //To perform Modify Lead Status Callout... Added on Oct 4
            //Updated on 7/26/19. check on Prospect status instead on Last Disposition.
            //send JSON string of Leads and perform status update on Velocify based on datamapping named Velocifyleadstatusmapping
            VelocifyLeadHandler.modifyLeadStatus(leadListJson);
            //To perform Lead Actions Callout...check on Prospect status instead on Last Disposition.
            //send JSON string of Leads and perform Action update on Velocify based on datamapping named VelocifyActionMap
            VelocifyLeadHandler.addLeadActions(leadListJson);
        }
    }
    /*  * This method filters prospects that are need to be pushed to Velocify
        * Prospect must have velocify Id and change in Prospect Status.
     */
    public void collectVelocifyLeadIds(nu_dse__Prospect__c newProspect, nu_dse__Prospect__c oldProspect) {

        if(newProspect.velocify_id__c != null 
            && newProspect.nu_dse__Last_Disposition__c != null
            && newProspect.nu_dse__Last_Disposition__c  != oldProspect.nu_dse__Last_Disposition__c) {

            velocifyLeadList.add(newProspect); // Prospect for updating the Status and Action in Velocify
            velocifyProspectIds.add(newProspect.Id); // Prospect Ids for modify leads in Velocify
        }
    }
    // Collect Send Disqualified Disposition Type prospect records
    public void collectDisqualifiedProspects(nu_dse__Prospect__c newProspect) {
    
        if(newProspect.Disposition_Email_Type__c == null) {
            if(newProspect.nu_dse__Last_Disposition__c == 'Disqualified' && newProspect.uuid__c != null){
                disqualifiedProspectIdUuIdMap.put(newProspect.Id, newProspect.uuid__c);    
            } else if(newProspect.nu_dse__Last_Disposition__c == 'LTLending'){
                newProspect.Disposition_Email_Type__c = 'LTLending';
            }   
        }
    }
    // Update offBusinessHours checkbox in prospect records 
    public void updateProspectsOffBussinessHours(nu_dse__Prospect__c newProspect, List<BusinessHours> bussinessHourList) {
        
        datetime currentTime = system.now();
        Boolean isWithin= BusinessHours.isWithin(bussinessHourList[0].id, currentTime);
         if(isWithin){
            newProspect.Off_Business_Hours__c = false;              
        }else{
            newProspect.Off_Business_Hours__c = true;              
        } 
    }
    //update prospect with UUID
    public void updateUuIdProspects(nu_dse__Prospect__c newProspect) {
    
        if(newProspect.uuid__c == null) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            newProspect.uuid__c = guid;
        }
    }
    
    //updates Disposition_Email_Type__c in prospect based on UUID in prospect and Permission Audit
    public void updateDispositionEmailType() {
        
        Set<String> uuIdSet = new Set<String>();
        for(TU_Permission_Audit__c permissionAudit : [SELECT Id, uuid__c, Created_At__c 
                                                      FROM TU_Permission_Audit__c WHERE uuid__c IN :disqualifiedProspectIdUuIdMap.values()]) {
            uuIdSet.add(permissionAudit.uuid__c);                                                  
        }
        for(Id newProspectId : disqualifiedProspectIdUuIdMap.keyset()) {
            nu_dse__Prospect__c newProspect = newProspectMap.get(newProspectId);
            if(uuIdSet.contains(newProspect.uuid__c)){
                newProspect.Disposition_Email_Type__c = 'PullTU-NotQualified';
            }
        }
    }
    
    //update prospect owner from Five9 Owner Id
    public void updateProspectOwner(nu_dse__Prospect__c newProspect, nu_dse__Prospect__c oldProspect) {
    
        if(newProspect.Has_Been_Assigned__c == true 
           && newProspect.FIve9_Owner_ID__c != null 
           && (newProspect.FIve9_Owner_ID__c.length() == 18 
               || newProspect.FIve9_Owner_ID__c.length() == 15)
           && (newProspect.FIve9_Owner_ID__c.startsWith('005') 
               || newProspect.FIve9_Owner_ID__c.startsWith('00G'))
           && (Trigger.isInsert 
               || (oldProspect.Has_Been_Assigned__c == false 
                   ||newProspect.FIve9_Owner_ID__c != oldProspect.FIve9_Owner_ID__c))) {
            newProspect.OwnerId = Id.valueof(newProspect.FIve9_Owner_ID__c);
        }
    }
    public void collectAllProspectSSN(nu_dse__Prospect__c newProspect, nu_dse__Prospect__c oldProspect) {
        if (Trigger.isInsert
            ||(oldProspect.nu_dse__SSN__c != newProspect.nu_dse__SSN__c)) {
            
            nu_dse__Prospect__c updatepros = new nu_dse__Prospect__c(Id=newProspect.Id);

            if(String.isBlank(newProspect.nu_dse__SSN__c) == true) {
                
                updatepros.SSN_Duplicate_Reference__c = 'No duplicate found';
                updatepros.Duplicate_By_SSN__c = false;

            } else if (prospectSSN_ProspectsMap.containsKey(newProspect.nu_dse__SSN__c) == false) {
                prospectSSN_ProspectsMap.put(newProspect.nu_dse__SSN__c, new List<nu_dse__Prospect__c>{newProspect}); //collecting SSN of all prospect for duplicate validation
                updatepros.SSN_Duplicate_Reference__c = 'No duplicate found';
                updatepros.Duplicate_By_SSN__c = false;
                /* nu_dse__Prospect__c prosDupSSN = prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN__c);
                newProspect.SSN_Duplicate_Reference__c = newProspect.SSN_Duplicate_Reference__c != null ? 
                    newProspect.SSN_Duplicate_Reference__c + '::' : '' +  prosDupSSN.Name+': '+
                    prosDupSSN.nu_dse__First_Name__c + ' ' +prosDupSSN.nu_dse__Last_Name__c; */
            } else {
                
                nu_dse__Prospect__c prosDupSSN = prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN__c)[prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN__c).size() - 1];
                String duplicatRefName = '';

                if(String.isNotBlank(prosDupSSN.SSN_Duplicate_Reference__c)) {

                    duplicatRefName = prosDupSSN.SSN_Duplicate_Reference__c;
                }

                duplicatRefName = prosDupSSN.Name+': '+
                    prosDupSSN.nu_dse__First_Name__c + ' ' +prosDupSSN.nu_dse__Last_Name__c;
                updatepros.SSN_Duplicate_Reference__c = duplicatRefName;
                updatepros.Duplicate_By_SSN__c = true;
                updateProspectMap.put(updatepros.Id, updatepros);
                prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN__c).add(newProspect);
            }
            updateProspectMap.put(updatepros.Id, updatepros);
            ssnProspectIds.add(newProspect.Id);
        }
    }

    @future
    public static void updateSSNDuplicateReference(String reqWrapJSON) {

        if(String.isNotBlank(reqWrapJSON)) {

            Set<Id> ssnProspectIds = new Set<Id>();
            Map<String, List<nu_dse__Prospect__c>> prospectSSN_ProspectsMap = new Map<String, List<nu_dse__Prospect__c>>(); 
            Map<Id, nu_dse__Prospect__c> updateProspectMap = new Map<Id, nu_dse__Prospect__c>();

            SSNDuplicateReferWrap reqWrap = (SSNDuplicateReferWrap) JSON.deserialize(reqWrapJSON, SSNDuplicateReferWrap.class);

            ssnProspectIds = reqWrap.prospectIds;
            prospectSSN_ProspectsMap = reqWrap.ssnProspectMap;
            updateProspectMap = reqWrap.updateProspectMap;

            Map<String, List<SObject>> SSNDublicateRecMap = SSNDuplicateFinderService.checkAndTagDuplicate(prospectSSN_ProspectsMap.keyset());
            Map<String, String> SSNDuplicateRefNameMap = new Map<String, String>();
            
            for(String SSNno : SSNDublicateRecMap.keySet()) {
                
                for(SObject duplicateRec : SSNDublicateRecMap.get(SSNno)) {
                    
                    if(duplicateRec.Id.getSobjectType().getDescribe().getName() == 'nu_dse__Prospect__c') {
                        
                        nu_dse__Prospect__c prospect = (nu_dse__Prospect__c)duplicateRec;
                    
                        if(ssnProspectIds.contains(prospect.Id) == false) {
                            
                            if(SSNDuplicateRefNameMap.containskey(prospect.nu_dse__SSN__c) == false) {
                                SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, prospect.Name+': '+ 
                                    prospect.nu_dse__First_Name__c + ' ' +prospect.nu_dse__Last_Name__c);
                            } else {
                                SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, SSNDuplicateRefNameMap.get(prospect.nu_dse__SSN__c) + 
                                    ', ' + prospect.Name +': '+ prospect.nu_dse__First_Name__c + ' ' + 
                                    prospect.nu_dse__Last_Name__c);
                            }
                        }
                    } else {
                        
                        nu_dse__Program__c program = (nu_dse__Program__c)duplicateRec;

                        if(SSNDuplicateRefNameMap.containskey(program.nu_dse__Account__r.nu_dse__SSN__c) == false) {
                            SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, program.Name+': '+ 
                                program.nu_dse__Account__r.FirstName + ' ' +program.nu_dse__Account__r.LastName);
                        } else {
                            SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, SSNDuplicateRefNameMap.get(program.nu_dse__Account__r.nu_dse__SSN__c) + 
                                ', ' + program.Name +': '+ program.nu_dse__Account__r.FirstName + ' ' + 
                                program.nu_dse__Account__r.LastName + ' ' + program.nu_dse__Account__r.PersonBirthdate + ' ' +program.nu_dse__Program_Status__c);
                        }   
                    }
                    
                }
            }
            for(String SSN_no : SSNDuplicateRefNameMap.keySet()) {
                
                String duplicateRef = SSNDuplicateRefNameMap.get(SSN_no);
                for(nu_dse__Prospect__c prospect : prospectSSN_ProspectsMap.get(SSN_no)) {

                    nu_dse__Prospect__c newProspect = new nu_dse__Prospect__c(Id=prospect.Id); 
                    newProspect.SSN_Duplicate_Reference__c = duplicateRef;
                    newProspect.Duplicate_By_SSN__c = true;
                    duplicateRef += ', ' + prospect.Name +': '+ prospect.nu_dse__First_Name__c + ' ' + prospect.nu_dse__Last_Name__c;
                    updateProspectMap.put(newProspect.Id, newProspect);
                }
            }

            update updateProspectMap.values();
        }
    }

    public class SSNDuplicateReferWrap{

        public Set<Id> prospectIds;
        public Map<String, List<nu_dse__Prospect__c>> ssnProspectMap;
        public Map<Id, nu_dse__Prospect__c> updateProspectMap;
    }
}