/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Prospect for Velocify
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-06-11
* @modified       2019-06-11
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger prospectTrigger on nu_dse__Prospect__c (after insert, after update) {
    
    Set<Id> updatedProspectIds = new Set<Id>(); 
    Map<String,String> leadIdAndItsDispositions = new Map<string,String>();
    
    for (nu_dse__Prospect__c p: trigger.new) {
        
        /* Commented on Oct 4...
           Callout based on Last Disposition field only...
           
        if( (p.velocify_id__c !=null) && ((trigger.isInsert && (trigger.newMap.get(p.Id).UUId__c!=null || trigger.newMap.get(p.Id).nu_dse__Total_Debt_Included__c !=null  )) || 
          ((trigger.isupdate )&& (trigger.oldMap.get(p.Id).UUID__c != trigger.newMap.get(p.Id).UUId__c ||
          trigger.oldMap.get(p.Id).nu_dse__Total_Debt_Included__c  != trigger.newMap.get(p.Id).nu_dse__Total_Debt_Included__c 
          )) )
          
          ){
              
            updatedProspectIds.add(p.id);
          }
        */
        
        if ((p.velocify_id__c !=null) && (((trigger.isinsert) && (p.nu_dse__Last_Disposition__c !=null))|| ((trigger.isUpdate) && (trigger.oldMap.get(p.Id).nu_dse__Last_Disposition__c  != trigger.newMap.get(p.Id).nu_dse__Last_Disposition__c) && (p.nu_dse__Last_Disposition__c !=null)) )){
            
            updatedProspectIds.add(p.id);
            leadIdAndItsDispositions.put(p.velocify_id__c, (p.nu_dse__Last_Disposition__c).toUppercase());
        }
    }
    
    if (updatedProspectIds.size()>0) {
        
        VelocifyLeadHandler.modifyLeads_Async(updatedProspectIds);
        
        //To perform Modify Lead Status Callout... Added on Oct 4
        VelocifyLeadHandler.modifyLeadStatus(leadIdAndItsDispositions);
        
        //To perform Lead Actions Callout...
        VelocifyLeadHandler.addLeadActions(leadIdAndItsDispositions);
    }
}