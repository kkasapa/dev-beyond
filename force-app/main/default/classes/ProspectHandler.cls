/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for ProspectTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.1
* @created        2019-05-23
* @modified       2019-07-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ProspectHandler extends TriggerHandler {        
    
    private Map<Id, nu_dse__Prospect__c> newProspectMap;
    private Map<Id, nu_dse__Prospect__c> oldProspectMap;
    
    public ProspectHandler() {
        this.newProspectMap = (Map<Id, nu_dse__Prospect__c>) Trigger.newMap;
        this.oldProspectMap = (Map<Id, nu_dse__Prospect__c>) Trigger.oldMap;
    }
    
    Map<Id, String> disqualifiedProspectIdUuIdMap = new Map<Id, String>(); // Map of Prospect Id and UUId 
    List<nu_dse__Prospect__c> velocifyLeadList = new List<nu_dse__Prospect__c>(); //List of Prospect for velocify update
    Set<Id> velocifyProspectIds = new Set<Id>(); // Set of Prospect Ids for Velocify modify leads

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
        } 
        if(disqualifiedProspectIdUuIdMap.isEmpty() == false) {
            updateDispositionEmailType();
        }
    }

    public override void afterUpdate() {

        for(nu_dse__Prospect__c newProspect : (List<nu_dse__Prospect__c>)Trigger.New) {
            //collect prospect Ids of all prospects when prospect status is changed
            collectVelocifyLeadIds(newProspect, oldProspectMap.get(newProspect.Id));
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
}