public class ProspectOpenTaskTrigger{ 
    public static void checkOpenTasks(List<Id> taskIdList) {
                        
            List<nu_dse__Prospect__c> prospectList = [SELECT id, nu_dse__Prospect_Status__c, InQueue__c, Remove_from_Five9_Campaign__c, Remove_From_Pardot_Campaign__c, OwnerId FROM nu_dse__Prospect__c WHERE nu_dse__Prospect_Status__c NOT IN ('Confirmation','Application') AND Id IN :taskIdList];
            List<Id> prospectIdList = new List<Id>();
            if(prospectList.size() > 0){
                prospectIdList.add(prospectList[0].Id);
            }        
            for(nu_dse__Prospect__c p :prospectList){
                    if(p.InQueue__c == false){
                        p.OwnerId = UserInfo.getUserId();
                    }
                    if(p.Remove_From_Five9_Campaign__c == false){
                        p.Remove_from_Five9_Campaign__c =  true;
                    }
                    if(p.Remove_From_Pardot_Campaign__c == false){
                        p.Remove_From_Pardot_Campaign__c =  true;
                    }
            }   
            update prospectList;
        }
}