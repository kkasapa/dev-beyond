global class Batch_Fiv9TaskValidate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Five9ANI_phone_Formatted__c,Five9__Five9SessionId__c,whatId,What.Type FROM Task WHERE Five9ANI_phone_Formatted__c != null AND Five9__Five9SessionId__c != null AND (What.Type = \'nu_dse__Prospect__c\' OR What.Type =\'nu_dse__Program__c\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Task> scope){
        if(scope != null && !scope.isEmpty()){
            String five9ANI = scope[0].Five9ANI_phone_Formatted__c;
             
            if(scope[0].What.Type == 'nu_dse__Prospect__c'){
                List<nu_dse__Prospect__c> lstPros = [SELECT Id,Best_Phone__c FROM nu_dse__Prospect__c WHERE id=:scope[0].whatid];
                if(!lstPros.isempty() && lstPros[0].Best_Phone__c != five9ANI  || lstPros[0].nu_dse__Cell_Phone__c!= five9ANI  ||  lstPros[0].CO_Best_Phone__c!= five9ANI  || lstPros[0].nu_dse__CO_Cell_Phone__c!= five9ANI  ||  lstPros[0].nu_dse__CO_Home_Phone__c!= five9ANI  ||  lstPros[0].nu_dse__CO_Work_Phone__c!= five9ANI  ||  lstPros[0].nu_dse__Home_Phone__c!= five9ANI  ||  lstPros[0].nu_dse__Work_Phone__c!= five9ANI ){
                    scope[0].whatid = null;  
                }
            }else if(scope[0].What.Type == 'nu_dse__Program__c'){
                List<nu_dse__Program__c> lstProg = [SELECT Id,nu_dse__Account__c FROM nu_dse__Program__c  WHERE id=:scope[0].whatid];
                List<Account> lstAccount = [SELECT Id,Phone FROM account WHERE id=:lstProg[0].id];
                if(!lstAccount.isempty() && (lstAccount[0].phone != five9ANI || lstAccount[0].PersonAssistantPhone!= five9ANI ||  lstAccount[0].PersonHomePhone!= five9ANI ||  lstAccount[0].PersonMobilePhone!= five9ANI ||  lstAccount[0].PersonOtherPhone!= five9ANI ||  lstAccount[0].nu_dse__Best_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__Cell_phone__c!= five9ANI ||  lstAccount[0].nu_dse__co_other_phone__c!= five9ANI ||  lstAccount[0].nu_dse__CO_Best_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__CO_Cell_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__CO_Home_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__Co_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__CO_Work_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__Home_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__Other_Phone__c!= five9ANI ||  lstAccount[0].nu_dse__Work_Phone__c!= five9ANI)){
                    scope[0].whatid = null;  
                }
            }
        }
        update scope;
    }  
    
    global void finish(Database.BatchableContext BC){
        
    }
  
}