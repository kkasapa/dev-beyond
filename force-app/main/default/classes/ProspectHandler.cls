/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for ProspectTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vladislav Polovtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.1
* @created        2019-05-23
* @modified       2019-09-05
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
    Map<String, List<nu_dse__Prospect__c>> coClientSSNProspectsMap = new Map<String, List<nu_dse__Prospect__c>>();
    Map<Id, nu_dse__Prospect__c> updateProspectMap = new Map<Id, nu_dse__Prospect__c>();
    Set<Id> ssnProspectIds = new Set<Id>();
    Set<Id> coClientSSNProspectIds = new Set<Id>();

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
            //Copy prospect client and co-client Encrypted SSN to non Encrypted SSN
            updateProspectNonEncryptSSN(newProspect, null);
        }
        //checkDuplicateAndTagAccount(); 
	
    }
    
    public override void afterInsert() {

        for (nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) { 

            // validation to check if any duplicate SSN in available for other records
            collectAllProspectSSN(newProspect, null);
        } 

        if(prospectSSN_ProspectsMap.isEmpty() == false
            || updateProspectMap.isEmpty() == false
            || coClientSSNProspectsMap.isEmpty() == false) {
            
            prospectHandler.SSNDuplicateReferWrap reqWrap = new prospectHandler.SSNDuplicateReferWrap();
            reqWrap.ssnProspectIds = ssnProspectIds;
            reqWrap.ssnProspectMap = prospectSSN_ProspectsMap;
            reqWrap.coClientSSNProspectIds = coClientSSNProspectIds;
            reqWrap.coClientSSNProspectsMap = coClientSSNProspectsMap;
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
            //Copy prospect client and co-client Encrypted SSN to non Encrypted SSN
            updateProspectNonEncryptSSN(newProspect, oldProspectMap.get(newProspect.Id));
        } 

        // checkDuplicateAndTagAccount(); 

        if(disqualifiedProspectIdUuIdMap.isEmpty() == false) {
            updateDispositionEmailType();
        }
    }

    public override void afterUpdate() {
        
        for(nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) {
            //collect prospect Ids of all prospects when prospect status is changed
            collectVelocifyLeadIds(newProspect, oldProspectMap.get(newProspect.Id));
            // validation to check if any duplicate SSN in available for other records
            collectAllProspectSSN(newProspect,oldProspectMap.get(newProspect.Id));
            //Check if this is a approvall recall trigger
            recallApproval(newProspect);
        }

        if(prospectSSN_ProspectsMap.isEmpty() == false
            || updateProspectMap.isEmpty() == false
            || coClientSSNProspectsMap.isEmpty() == false) {
            
            prospectHandler.SSNDuplicateReferWrap reqWrap = new prospectHandler.SSNDuplicateReferWrap();
            reqWrap.ssnProspectIds = ssnProspectIds;
            reqWrap.ssnProspectMap = prospectSSN_ProspectsMap;
            reqWrap.coClientSSNProspectIds = coClientSSNProspectIds;
            reqWrap.coClientSSNProspectsMap = coClientSSNProspectsMap;
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

    //Copy prospect client and co-client Encrypted SSN to non Encrypted SSN
    public void updateProspectNonEncryptSSN(nu_dse__Prospect__c newProspect, nu_dse__Prospect__c oldProspect) {
        
        if((Trigger.isInsert && newProspect.nu_dse__SSN_ENC__c != null)
            || (Trigger.isUpdate &&  newProspect.nu_dse__SSN_ENC__c != oldProspect.nu_dse__SSN_ENC__c)) {
            
            newProspect.nu_dse__SSN__c = newProspect.nu_dse__SSN_ENC__c;
        }
        if((Trigger.isInsert && newProspect.nu_dse__CO_SSN_ENC__c != null)
            || (Trigger.isUpdate &&  newProspect.nu_dse__CO_SSN_ENC__c != oldProspect.nu_dse__CO_SSN_ENC__c)) {
            
            newProspect.nu_dse__Co_SSN__c = newProspect.nu_dse__CO_SSN_ENC__c;
        }
    }
    
    public void collectAllProspectSSN(nu_dse__Prospect__c newProspect, nu_dse__Prospect__c oldProspect) {
        
        if (Trigger.isInsert
            ||(oldProspect.nu_dse__SSN_ENC__c != newProspect.nu_dse__SSN_ENC__c)) {
            
            nu_dse__Prospect__c updatepros = new nu_dse__Prospect__c(Id=newProspect.Id);

            if(String.isBlank(newProspect.nu_dse__SSN_ENC__c) == true) {
                
                updatepros.Client_SSN_Duplicate_Reference__c = '';
                updatepros.Client_Duplicate_By_SSN__c = false;

            } else if (prospectSSN_ProspectsMap.containsKey(newProspect.nu_dse__SSN_ENC__c) == false) {
                prospectSSN_ProspectsMap.put(newProspect.nu_dse__SSN_ENC__c, new List<nu_dse__Prospect__c>{newProspect}); //collecting SSN of all prospect for duplicate validation
                updatepros.Client_SSN_Duplicate_Reference__c = 'SSN Duplicate Check ran on ['+ System.now()+']::::No duplicate found';
                updatepros.Client_Duplicate_By_SSN__c = false;

            } else {
                
                nu_dse__Prospect__c prosDupSSN = prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN_ENC__c)[prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN_ENC__c).size() - 1];
                String duplicatRefName = '';

                if(String.isNotBlank(prosDupSSN.Client_SSN_Duplicate_Reference__c)
                    && prosDupSSN.Client_SSN_Duplicate_Reference__c.contains('No duplicate found') == false) {

                    duplicatRefName = prosDupSSN.Client_SSN_Duplicate_Reference__c.split('::::')[1] +',';
                }

                duplicatRefName = '['+prosDupSSN.Name+': '+ prosDupSSN.nu_dse__First_Name__c + ' ' +prosDupSSN.nu_dse__Last_Name__c + ', ' +
                                  (prosDupSSN.nu_dse__DOB__c != null ? prosDupSSN.nu_dse__DOB__c + ', ':'') + prosDupSSN.nu_dse__Prospect_Status__c + ']';
                updatepros.Client_SSN_Duplicate_Reference__c = 'SSN Duplicate Check ran on ['+ System.now()+']::::'+duplicatRefName;
                updatepros.Client_Duplicate_By_SSN__c = true;
                prospectSSN_ProspectsMap.get(newProspect.nu_dse__SSN_ENC__c).add(newProspect);
            }
            updateProspectMap.put(updatepros.Id, updatepros);
            ssnProspectIds.add(newProspect.Id);
        }

        if (Trigger.isInsert
            ||(oldProspect.nu_dse__CO_SSN_ENC__c != newProspect.nu_dse__CO_SSN_ENC__c)) {
            
            nu_dse__Prospect__c updatepros = new nu_dse__Prospect__c(Id=newProspect.Id);

            if(updateProspectMap.containskey(newProspect.Id)) {
                updatepros = updateProspectMap.get(newProspect.Id);
            }

            if(String.isBlank(newProspect.nu_dse__CO_SSN_ENC__c) == true) { // if SSN is cleared we mark that as no duplicate found
                
                updatepros.Co_Client_SSN_Duplicate_Reference__c = '';
                updatepros.Co_Client_Duplicate_By_SSN__c = false;

            } else if (coClientSSNProspectsMap.containsKey(newProspect.nu_dse__CO_SSN_ENC__c) == false) { //collecting SSN of all prospect for duplicate validation
                coClientSSNProspectsMap.put(newProspect.nu_dse__CO_SSN_ENC__c, new List<nu_dse__Prospect__c>{newProspect}); 
                updatepros.Co_Client_SSN_Duplicate_Reference__c = 'Co-Client SSN Duplicate Check ran on ['+ System.now()+']::::No duplicate found';
                updatepros.Co_Client_Duplicate_By_SSN__c = false;
            } else {
                
                nu_dse__Prospect__c prosDupSSN = coClientSSNProspectsMap.get(newProspect.nu_dse__CO_SSN_ENC__c)[coClientSSNProspectsMap.get(newProspect.nu_dse__CO_SSN_ENC__c).size() - 1];
                String duplicatRefName = '';

                if(String.isNotBlank(prosDupSSN.Co_Client_SSN_Duplicate_Reference__c)
                    && prosDupSSN.Co_Client_SSN_Duplicate_Reference__c.contains('No duplicate found') == false) {

                    duplicatRefName = prosDupSSN.Co_Client_SSN_Duplicate_Reference__c.split('::::')[1] +',';
                }

                duplicatRefName = '['+prosDupSSN.Name+': '+ prosDupSSN.nu_dse__Co_Full_Name__c + ', ' +
                                  (prosDupSSN.nu_dse__CO_DOB__c != null ? prosDupSSN.nu_dse__CO_DOB__c + ', ':'') + prosDupSSN.nu_dse__Prospect_Status__c + ']';
                updatepros.Co_Client_SSN_Duplicate_Reference__c = 'Co-Client SSN Duplicate Check ran on ['+ System.now()+']::::'+duplicatRefName;
                updatepros.Co_Client_Duplicate_By_SSN__c = true;
                coClientSSNProspectsMap.get(newProspect.nu_dse__CO_SSN_ENC__c).add(newProspect);
            }
            updateProspectMap.put(updatepros.Id, updatepros);
            coClientSSNProspectIds.add(newProspect.Id);
        }
    }

    //future method to query all Account and prospect and tag to Prospect
    @future
    public static void updateSSNDuplicateReference(String reqWrapJSON) { 

        if(String.isNotBlank(reqWrapJSON)) {

            SSNDuplicateReferWrap reqWrap = (SSNDuplicateReferWrap) JSON.deserialize(reqWrapJSON, SSNDuplicateReferWrap.class);

            Set<Id> ssnProspectIds = reqWrap.ssnProspectIds;
            Map<String, List<nu_dse__Prospect__c>> prospectSSN_ProspectsMap = reqWrap.ssnProspectMap;
            Map<Id, nu_dse__Prospect__c> updateProspectMap = reqWrap.updateProspectMap;
            Set<Id> coClientSSNProspectIds = reqWrap.coClientSSNProspectIds;
            Map<String, List<nu_dse__Prospect__c>> coClientSSNProspectsMap = reqWrap.coClientSSNProspectsMap;

            Map<String, List<SObject>> SSNDublicateRecMap = SSNDuplicateFinderService.checkAndTagDuplicate(prospectSSN_ProspectsMap.keyset());
            Map<String, String> SSNDuplicateRefNameMap = new Map<String, String>();
            
            for(String SSNno : SSNDublicateRecMap.keySet()) {
                
                for(SObject duplicateRec : SSNDublicateRecMap.get(SSNno)) {
                    
                    String duplicatRefName = '';

                    if(duplicateRec.Id.getSobjectType().getDescribe().getName() == 'nu_dse__Prospect__c') {
                        
                        nu_dse__Prospect__c prospect = (nu_dse__Prospect__c)duplicateRec;
                        
                        if(ssnProspectIds.contains(prospect.Id) == false) {
                            
                            duplicatRefName = '[' + prospect.Name+': '+ prospect.nu_dse__First_Name__c + ' ' +prospect.nu_dse__Last_Name__c + ', ' +
                                               (prospect.nu_dse__DOB__c != null ? prospect.nu_dse__DOB__c + ', ':'') + 
                                               prospect.nu_dse__Prospect_Status__c + ']'; // formulating the reference of duplicate in apattern easy to parse

                            if(SSNDuplicateRefNameMap.containskey(prospect.nu_dse__SSN__c) == false) {
                                SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, duplicatRefName);
                            } else {
                                SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, 
                                    SSNDuplicateRefNameMap.get(prospect.nu_dse__SSN__c) + ', '+ duplicatRefName);
                            }
                        }
                    } else {
                        
                        nu_dse__Program__c program = (nu_dse__Program__c)duplicateRec;
                        duplicatRefName = '[' + program.Name +': '+ program.nu_dse__Account__r.FirstName + ' ' + 
                                program.nu_dse__Account__r.LastName + ', '+ program.nu_dse__Account__r.PersonBirthdate + ', ' + 
                                program.nu_dse__Program_Status__c + ']'; // formulating the reference of duplicate in apattern easy to parse

                        if(SSNDuplicateRefNameMap.containskey(program.nu_dse__Account__r.nu_dse__SSN__c) == false) {
                            SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, duplicatRefName); //setting reference in Prospect
                        } else {
                            SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, 
                                SSNDuplicateRefNameMap.get(program.nu_dse__Account__r.nu_dse__SSN__c) + ', ' + duplicatRefName);  //apending reference in Prospect
                        }   
                    }
                    
                }
            }
            for(String SSN_no : SSNDuplicateRefNameMap.keySet()) { // iterating all ssn and getting it ready for dml
                
                String duplicateRef = 'SSN Duplicate Check ran on ['+ System.now()+']::::'+ SSNDuplicateRefNameMap.get(SSN_no);
                for(nu_dse__Prospect__c prospect : prospectSSN_ProspectsMap.get(SSN_no)) { // if one ssn has multiple duplicate records, we handle as list of duplicate for one SSN

                    nu_dse__Prospect__c newProspect = new nu_dse__Prospect__c(Id=prospect.Id); 
                    if(updateProspectMap.containskey(prospect.Id)) {

                        newProspect = updateProspectMap.get(prospect.Id);
                    }
                    newProspect.Client_SSN_Duplicate_Reference__c = duplicateRef;
                    newProspect.Client_Duplicate_By_SSN__c = true;
                    duplicateRef += ', [' + prospect.Name +': '+ prospect.nu_dse__First_Name__c + ' ' + prospect.nu_dse__Last_Name__c + ']'; // appending to existing reference for new duplicate
                    updateProspectMap.put(newProspect.Id, newProspect);
                }
            }

            Map<String, List<SObject>> coClientSSNDublicateRecMap = SSNDuplicateFinderService.coClientcheckAndTagDuplicate(coClientSSNProspectsMap.keyset());
            Map<String, String> coClientSSNDuplicateRefNameMap = new Map<String, String>();

            //similar logic as we did for Client SSN
            for(String SSNno : coClientSSNDublicateRecMap.keySet()) {
                
                for(SObject duplicateRec : coClientSSNDublicateRecMap.get(SSNno)) {
                    
                    String duplicatRefName = '';

                    if(duplicateRec.Id.getSobjectType().getDescribe().getName() == 'nu_dse__Prospect__c') {
                        
                        nu_dse__Prospect__c prospect = (nu_dse__Prospect__c)duplicateRec;
                        
                        if(coClientSSNProspectIds.contains(prospect.Id) == false) {
                            
                            duplicatRefName = '[' + prospect.Name+': '+ prospect.nu_dse__Co_Full_Name__c + ', ' +
                                               (prospect.nu_dse__CO_DOB__c != null ? prospect.nu_dse__CO_DOB__c + ', ':'') + 
                                               prospect.nu_dse__Prospect_Status__c + ']';

                            if(coClientSSNDuplicateRefNameMap.containskey(prospect.nu_dse__Co_SSN__c) == false) {
                                coClientSSNDuplicateRefNameMap.put(prospect.nu_dse__Co_SSN__c, duplicatRefName);
                            } else {
                                coClientSSNDuplicateRefNameMap.put(prospect.nu_dse__Co_SSN__c, 
                                    coClientSSNDuplicateRefNameMap.get(prospect.nu_dse__Co_SSN__c) + ', '+ duplicatRefName);
                            }
                        }
                    } else {
                        
                        nu_dse__Program__c program = (nu_dse__Program__c)duplicateRec;
                        duplicatRefName = '[' + program.Name +': '+ program.nu_dse__Account__r.nu_dse__Co_First_Name__c + ' ' + 
                                program.nu_dse__Account__r.nu_dse__Co_Last_Name__c + ', '+ 
                                (program.nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c != null ? program.nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c + ', ' : '')+ 
                                program.nu_dse__Program_Status__c + ']';

                        if(coClientSSNDuplicateRefNameMap.containskey(program.nu_dse__Account__r.nu_dse__Co_SSN__c) == false) {
                            coClientSSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__Co_SSN__c, duplicatRefName);
                        } else {
                            coClientSSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__Co_SSN__c, 
                                coClientSSNDuplicateRefNameMap.get(program.nu_dse__Account__r.nu_dse__Co_SSN__c) + ', ' + duplicatRefName);
                        }   
                    }
                    
                }
            }
            for(String SSN_no : coClientSSNDuplicateRefNameMap.keySet()) {
                
                String duplicateRef = 'Co-Client SSN Duplicate Check ran on ['+ System.now()+']::::'+ coClientSSNDuplicateRefNameMap.get(SSN_no);
                for(nu_dse__Prospect__c prospect : coClientSSNProspectsMap.get(SSN_no)) {
                    
                    nu_dse__Prospect__c newProspect = new nu_dse__Prospect__c(Id=prospect.Id);

                    if(updateProspectMap.containskey(prospect.Id)) {

                        newProspect = updateProspectMap.get(prospect.Id);
                    }
                    newProspect.Co_Client_SSN_Duplicate_Reference__c = duplicateRef;
                    newProspect.Co_Client_Duplicate_By_SSN__c = true;
                    duplicateRef += ', [' + prospect.Name +': '+ prospect.nu_dse__First_Name__c + ' ' + prospect.nu_dse__Last_Name__c + ']';
                    updateProspectMap.put(newProspect.Id, newProspect);
                }
            }
            update updateProspectMap.values();
        }
    }
    
    //updated by Ashwin to prevent record read-only error while creation as newProspect instance can't be assigned with any values from afterUpdate context.
    public void recallApproval(nu_dse__Prospect__c newProspect){
        Boolean RecalledApproval; 
        RecalledApproval = newProspect.Recalled_Approval__c;
        //newProspect.Recalled_Approval__c = false; moved this update within the if condition
        if(RecalledApproval) {

            newProspect.Recalled_Approval__c = false;
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

    public class SSNDuplicateReferWrap{

        Set<Id> ssnProspectIds;
        Map<String, List<nu_dse__Prospect__c>> ssnProspectMap;
        Map<Id, nu_dse__Prospect__c> updateProspectMap;
        Set<Id> coClientSSNProspectIds;
        Map<String, List<nu_dse__Prospect__c>> coClientSSNProspectsMap;
    }
}