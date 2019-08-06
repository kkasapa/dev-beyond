global class Batch_MissedCallsTaskAssignment implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Schema.DescribeSObjectResult sObjectResult = Missed_Call__c.sObjectType.getDescribe();
        String prefix = sObjectResult.getKeyPrefix();
        //Query list of all Orphan tasks and also the tasks assigned previously to missed call object.
        String query = 'SELECT Id,Five9ANI_phone_Formatted__c,whatId FROM Task WHERE Five9ANI_phone_Formatted__c != null AND (whatId = null OR What.Type = \'Missed_Call__c\')'; 
        system.debug('---query----'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Task> scope){
        if(scope != null && !scope.isEmpty()){
            boolean flag = false;
            String five9ANI = scope[0].Five9ANI_phone_Formatted__c;
            //Search if phone number on task matches phone on any account
            List<Account> lstAccount = [SELECT Id,Phone,PersonAssistantPhone,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,nu_dse__Best_Phone__c,nu_dse__Cell_phone__c,nu_dse__co_other_phone__c,nu_dse__CO_Best_Phone__c,nu_dse__CO_Cell_Phone__c,nu_dse__CO_Home_Phone__c,nu_dse__Co_Phone__c,nu_dse__CO_Work_Phone__c,nu_dse__Home_Phone__c,nu_dse__Other_Phone__c,nu_dse__Work_Phone__c FROM Account WHERE 
                                        (Phone=:five9ANI OR PersonAssistantPhone=:five9ANI OR PersonHomePhone=:five9ANI OR PersonMobilePhone=:five9ANI OR PersonOtherPhone=:five9ANI OR nu_dse__Best_Phone__c=:five9ANI OR nu_dse__Cell_phone__c=:five9ANI OR nu_dse__co_other_phone__c=:five9ANI OR nu_dse__CO_Best_Phone__c=:five9ANI OR 
                                        nu_dse__CO_Cell_Phone__c=:five9ANI OR nu_dse__CO_Home_Phone__c=:five9ANI OR nu_dse__Co_Phone__c=:five9ANI OR nu_dse__CO_Work_Phone__c=:five9ANI OR nu_dse__Home_Phone__c=:five9ANI OR nu_dse__Other_Phone__c=:five9ANI OR nu_dse__Work_Phone__c=:five9ANI)];
            if(lstAccount != null && !lstAccount.isEmpty()){
               // scope[0].whatId = lstAccount[0].Id; // if matched assign task to matched account
               string AccRelatedPgm = lstAccount[0].Id;
                List<nu_dse__Program__c> lstProgram = [select id,name,nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c = :AccRelatedPgm ];
                if(lstProgram != null && !lstProgram.isEmpty())
                    scope[0].whatId = lstProgram[0].Id; // if matched any account, related prgrm is queried and assigned as parent to this task
                flag = true;
            }else{
                //Search if phone number on task matches phone on any prospect
                List<nu_dse__Prospect__c> lstProspect = [SELECT Id,Best_Phone__c,nu_dse__Cell_Phone__c,CO_Best_Phone__c, nu_dse__CO_Cell_Phone__c,nu_dse__CO_Home_Phone__c,nu_dse__CO_Work_Phone__c,nu_dse__Home_Phone__c,nu_dse__Work_Phone__c,Prospect_Score__c FROM nu_dse__Prospect__c WHERE 
                                                        (Best_Phone__c=:five9ANI OR nu_dse__Cell_Phone__c=:five9ANI OR CO_Best_Phone__c=:five9ANI OR nu_dse__CO_Cell_Phone__c=:five9ANI OR nu_dse__CO_Home_Phone__c=:five9ANI OR nu_dse__CO_Work_Phone__c=:five9ANI OR nu_dse__Home_Phone__c=:five9ANI OR nu_dse__Work_Phone__c=:five9ANI)];
                if(lstProspect != null && !lstProspect.isEmpty()){
                   // if matched with one prospect assign task to matched prospect
                    if(lstProspect.size() == 1){
                        scope[0].whatId = lstProspect[0].Id; 
                        flag = true;
                    }else{
                       //if matched with multiple prospects find the prospect with highest score 
                        List<Integer> lstPropsectScore = new List<Integer>();
                        for(nu_dse__Prospect__c objProspect : lstProspect){
                            if(String.isNotBlank(objProspect.Prospect_Score__c)){
                                lstPropsectScore.add(Integer.valueOf(objProspect.Prospect_Score__c));
                            }  
                        }
                        if(lstPropsectScore != null && !lstPropsectScore.isEmpty()){
                            lstPropsectScore.sort();
                            String maxScore = String.valueOf(lstPropsectScore[lstPropsectScore.size()-1]);
                            for(nu_dse__Prospect__c objProspect : lstProspect){
                                if(maxScore == objProspect.Prospect_Score__c){
                                    scope[0].whatId = objProspect.Id; // assign this task to highest score prospect 
                                    flag = true;
                                    break;
                                }  
                            }
                        }
                    }
                }
            }
            if(!flag){ // if not matched any account or Program creates a missied call record and assign task to new missed call record
                if(String.isBlank(scope[0].whatId)){
                    Missed_Call__c objMissedCall = new Missed_Call__c();
                    objMissedCall.Missed_Call_From__c = scope[0].Five9ANI_phone_Formatted__c;
                    insert objMissedCall;
                    if(objMissedCall != null && String.isNotBlank(objMissedCall.Id))
                        scope[0].whatId = objMissedCall.Id;
                }
            }else if(flag){//Deleting missed call record if account or propsect record found based on phone number
                List<Missed_Call__c> lstMissedCall = [SELECT Id,Missed_Call_From__c FROM Missed_Call__c WHERE Missed_Call_From__c =:five9ANI];
                if(lstMissedCall != null && !lstMissedCall.isEmpty())
                    delete lstMissedCall;
            }
            update scope;
        }        
    }  
    
    global void finish(Database.BatchableContext BC){
        
    }
    // to test this batch class execute below in anonymous with appropriate time
    /*MissedCallBatchScheduler obj = new MissedCallBatchScheduler();
    String sch = '0 32 09 07 11 ?';
    String jobID = system.schedule('Test Schedule', sch, obj);*/
}