public class RejectionCommentsRequired {
    public Map <Id,nu_dse__Prospect__c> rejectionMesage(Map<Id,nu_dse__Prospect__c>newProspectMap, Map<Id,nu_dse__Prospect__c>oldProspectmap){
        Map <Id,nu_dse__Prospect__c>rejectedStatement = new Map <Id,nu_dse__Prospect__c>();
        Map<Id,String> LeadProcessStepMap = new Map<Id,String>(); 
        Map<Id,Id> LeadProcessMap = new Map<Id,Id>();
        system.debug('@@Handler begin-->');
        for(nu_dse__Prospect__c prosRec: newProspectMap.values()){
            
            nu_dse__Prospect__c oldRec = oldProspectmap.get(prosRec.id);
            
            if(oldRec.nu_dse__Prospect_Status__c != 'Approval Rejected' &&
               prosRec.nu_dse__Prospect_Status__c == 'Approval Rejected'){
                   rejectedStatement.put(prosRec.id, prosRec);
                   system.debug('@@rejectedStatement-->'+rejectedStatement);
                   
               }
            
        }
        
        if(!rejectedStatement.IsEmpty()){
            List<Id> processInstanceIds = new List<Id>{};
                
                for(ProcessInstance pp : [select Id, TargetObjectId from ProcessInstance where TargetObjectId in :rejectedStatement.keySet() ]){
                    processInstanceIds.add(pp.Id);
                    LeadProcessMap.put (pp.TargetObjectId,pp.Id); 
                    
                }
            
            
            for (ProcessInstanceStep pi : [select Comments,ProcessInstanceId from ProcessInstanceStep where ProcessInstanceId in :processInstanceIds])   
            {   
                LeadProcessStepMap.put (pi.ProcessInstanceId, pi.Comments); 
                
                system.debug('@@@@Comments --> '+pi.Comments);    
                
            } 
            
            for(nu_dse__Prospect__c prosRec: newProspectMap.values()){                
                try{
                    if(prosRec.SecondLevelRejection__c == true){
                        if(LeadProcessStepMap.get(LeadProcessMap.get(prosRec.id)) == null || 
                           LeadProcessStepMap.get(LeadProcessMap.get(prosRec.id)).length() == 0   )
                        {
                            system.debug('@@@@In IF --> ');
                            rejectedStatement.get(prosRec.id).addError(
                                'Operation Cancelled: Please provide a rejection reason!');
                            
                        }
                        else if((LeadProcessStepMap.get(LeadProcessMap.get(prosRec.id)) != null && 
                                 LeadProcessStepMap.get(LeadProcessMap.get(prosRec.id)).length() > 0  )){                            
                                     prosRec.Rejection_Reason__c = LeadProcessStepMap.get(LeadProcessMap.get(prosRec.id));
                                 }
                    }
                }
                catch(Exception e){}                
            }
        }        
        return rejectedStatement;        
    }
}