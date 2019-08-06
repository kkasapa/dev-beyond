@isTest
public class Batch_PopulateNoOfDaysOverdue_Test {

    static testMethod void testPopulateNoOfDaysOverdue() {
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('CFT');
        insert processorInstance;
        
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();    
        Id accountRecordTypeId;
        
        if (accountRecordTypeMap.containsKey('Client')) {
            
            accountRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        
        Map<String, Schema.RecordTypeInfo> paymentRecordTypeMap = nu_dse__Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        Account accountInstance = TestRecordCreator.createAccount('Account Name', accountRecordTypeId);
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);
        programInstance.nu_dse__Program_Status__c = 'Graduated';
        insert programInstance;
        
        system.debug('programInstance--->'+programInstance.nu_dse__Program_Status__c);
        
        nu_dse__TradeLine__c tradeLineInstance = TestRecordCreator.createTradeLine(accountInstance.Id,programInstance.id);
        //tradeLineInstance.Due_Date__c = Date.today().addDays(-6);
        tradeLineInstance.Number_Of_Days_Overdue__c = 6;
        tradeLineInstance.nu_dse__Current_Stage__c = 'Other';
        insert tradeLineInstance;
        
        nu_dse__TradeLine__c tradeLineInstance1 = TestRecordCreator.createTradeLine(accountInstance.Id,programInstance.id);
        tradeLineInstance1.nu_dse__Current_Stage__c = 'Settled - Non Legal';
        tradeLineInstance1.Number_Of_Days_Overdue__c = 5;
        tradeLineInstance.Due_Date__c = Date.today().addDays(-5);

        insert tradeLineInstance1;
        
        programInstance.nu_dse__Program_Status__c = 'Graduated';
        update programInstance;
        
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1); 
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
        system.schedule('Test ScheduledBatchClass', CRON_EXP, new Schedule_PopulateNoOfDaysOverdue());
        Database.executeBatch(new Batch_PopulateNoOfDaysOverdue());
        Test.stopTest();
       
       List<nu_dse__TradeLine__c> tradeLineList = [SELECT Id, Number_Of_Days_Overdue__c FROM nu_dse__TradeLine__c WHERE Id =:tradeLineInstance.Id ];
       System.assertEquals(6, tradeLineList[0].Number_Of_Days_Overdue__c);  
       
       List<nu_dse__TradeLine__c> tradeLineList1 = [SELECT Id, Number_Of_Days_Overdue__c FROM nu_dse__TradeLine__c WHERE Id =:tradeLineInstance1.Id ];
       System.assertEquals(5, tradeLineList1[0].Number_Of_Days_Overdue__c);  
    }
}