@isTest
public class Batch_UpdateOfferPymntsScheduleDte_Test {
    
    @isTest 
    public static void testBatchUpdateOfferPayments() {
        
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
        
        insert programInstance;
        
        nu_dse__TradeLine__c tradeLineInstance = TestRecordCreator.createTradeLine(accountInstance.Id,programInstance.id);
        
        insert tradeLineInstance;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id, tradeLineInstance.Id, 1000, 1000, 2, 2);
        offerInstance.Sub_Status__c = 'Out For Authorization';
        insert offerInstance;
        
        Id offerId = offerInstance.Id;
        
        Id recordTypeId;
        
        if(paymentRecordTypeMap.containsKey('Fee')) {
        
            recordTypeId = paymentRecordTypeMap.get('Fee').getRecordTypeId();
        }
        
        nu_dse__Payment__c paymentWithdraw1 = TestRecordCreator.createPayment(programInstance.Id, 'Pending', 'Fee Withdrawal', recordTypeId, offerId);
        nu_dse__Payment__c paymentWithdraw2 = TestRecordCreator.createPayment(programInstance.Id, 'Pending', 'Fee Withdrawal', recordTypeId, offerId);
        
        if(paymentRecordTypeMap.containsKey('Fee')) {
        
            recordTypeId = paymentRecordTypeMap.get('Fee').getRecordTypeId();
        }
        
        nu_dse__Payment__c paymentFeeWithdraw1 = TestRecordCreator.createPayment(programInstance.Id, 'Pending', 'Fee Withdrawal', recordTypeId, offerId);
        nu_dse__Payment__c paymentFeeWithdraw2 = TestRecordCreator.createPayment(programInstance.Id, 'Pending', 'Fee Withdrawal', recordTypeId, offerId);
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        paymentList.add(paymentWithdraw1);
        paymentList.add(paymentWithdraw2);
        
        paymentList.add(paymentFeeWithdraw1);
        paymentList.add(paymentFeeWithdraw2);
        
        insert paymentList;
        
        Test.startTest();
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobid = System.Schedule('schedule offer payments batch', CRON_EXP, new Schedule_UpdateOfferPaymentsBatch());
        
        Database.executeBatch(new Batch_UpdateOfferPaymentsScheduleDate());
        
        Test.stopTest();
        
        List<nu_dse__Payment__c> updatedPaymentList = [SELECT Id, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c WHERE Id = :paymentList[0].Id];
        
        System.assertEquals(paymentList[0].nu_dse__Schedule_Date__c.addDays(7), updatedPaymentList[0].nu_dse__Schedule_Date__c);
        
    }
}