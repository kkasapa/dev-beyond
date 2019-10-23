public class RejectionCommentsRequired {

    public static String rejectionMesage(Map<Id,nu_dse__Prospect__c>newProspectMap, Map<Id,nu_dse__Prospect__c>oldProspectmap){
        
        for(nu_dse__Prospect__c prosRec: newProspectMap.values()){
            
            nu_dse__Prospect__c oldRec = oldProspectmap.get(prosRec.id);
            
            if(oldRec.nu_dse__Prospect_Status__c != 'Approval Rejected' &&
               prosRec.nu_dse__Prospect_Status__c == 'Approval Rejected'){
                   
                   
               }
            
        }
            
        return null;
        
    }
}