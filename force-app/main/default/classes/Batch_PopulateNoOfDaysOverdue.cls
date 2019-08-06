/* Developed on Feb12-2018
To increment the number of days overdue in tradeline object on daily basis*/
public class Batch_PopulateNoOfDaysOverdue implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
    
        List<String> prgmStatusList = new List<String>{'Completed', 'Graduated', 'Cancelled'};
        
        String query = 'SELECT Id, Number_Of_Days_Overdue__c,Due_Date__c FROM nu_dse__TradeLine__c WHERE Number_Of_Days_Overdue__c != null ';
        query += '  AND Due_Date__c !=null  AND (NOT nu_dse__Program__r.nu_dse__Program_Status__c IN :prgmStatusList)';
        query += ' AND (NOT nu_dse__Current_Stage__c LIKE \'Settled%\')';
        system.debug('query--->'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__TradeLine__c> scope) {
    
        try {
        
            List<nu_dse__TradeLine__c> tradelineToUpdateList = new List<nu_dse__TradeLine__c>();
            
            for (nu_dse__TradeLine__c tradelineRec : scope) {
            
                nu_dse__TradeLine__c tradelineToUpdate = new nu_dse__TradeLine__c();
                tradelineToUpdate.Id = tradelineRec.Id;
                //tradelineToUpdate.Number_Of_Days_Overdue__c = tradelineRec.Number_Of_Days_Overdue__c + 1;
                System.debug('Days**:'+ tradelineRec.Due_Date__c.daysBetween(Date.today()));
                tradelineToUpdate.Number_Of_Days_Overdue__c = tradelineRec.Due_Date__c.daysBetween(Date.today());
                tradelineToUpdateList.add(tradelineToUpdate);
            }
            
            if (tradelineToUpdateList.isEmpty() == False) {
            
                update tradelineToUpdateList;
            }
        } catch(Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_PopulateNoOfDaysOverdue', nu_dse__Message__c = e.getMessage(), 
                                                                        nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
            insert errorlog;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    
    }
}