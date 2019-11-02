@isTest
public class schedule_ProcessesInPaymentBatch_Test {

    @testSetup static void testRecordCreate() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        Account clientAccount = TestRecordCreator.createAccount('clientAcc', accRecordTypeId);
        insert clientAccount;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Type__c = 'CFT';
        insert processor;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        insert program;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(program.Id, tradeLine.Id, 2000, 200, 6, 15);
        insert offer;
        
        nu_dse__Payment__c payment = TestRecordCreator.createPayment(program.Id, 'Pending', 'Deposit', draftRecordTypeId, offer.Id);
        payment.nu_dse__Schedule_Date__c = system.today().addDays(5); 
        insert payment;
    }

    static testMethod void schedulerTest() {
    
        Test.StartTest();
        
        schedule_ProcessesInPaymentBatch schedulerInst = new schedule_ProcessesInPaymentBatch();
        String schCronExp = '0 0 23 * * ?'; 
        system.schedule('Test ProcessesInPaymentBatch Schedule', schCronExp, schedulerInst); 
        
        Test.stopTest(); 
    }

    static testMethod void scheduledWithIdsTest() {
    
        nu_dse__Payment__c paymentInst = [SELECT Id FROM nu_dse__Payment__c LIMIT 1]; 
        Test.StartTest();
        
        schedule_ProcessesInPaymentBatch schedulerInst = new schedule_ProcessesInPaymentBatch(new Set<Id>{paymentInst.Id});
        String schCronExp = '0 0 23 * * ?'; 
        system.schedule('Test ProcessesInPaymentBatch Schedule', schCronExp, schedulerInst); 
        
        Test.stopTest(); 
    }
    
    static testMethod void scheduledWithWhereClauseTest() {
    
        Test.StartTest();
        
        schedule_ProcessesInPaymentBatch schedulerInst = new schedule_ProcessesInPaymentBatch('nu_dse__Schedule_Date__c > TODAY');
        String schCronExp = '0 0 23 * * ?'; 
        system.schedule('Test ProcessesInPaymentBatch Schedule', schCronExp, schedulerInst); 
        
        Test.stopTest(); 
    }
}