@isTest
public with sharing class Batch_SavingsCalculation_Test {
    
    //setting up data for running tests
    @testSetup static void dataCreator() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        Account clientAccount = TestRecordCreator.createAccount('clientAcc', accRecordTypeId);
        insert clientAccount;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Type__c = 'CFT';
        insert processor;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        program.nu_dse__Trust_Account_Balance__c = 1000;
        program.Original_Enrolled_Program_Debt__c = 1500;
        insert program;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        insert tradeLine;
    }
}
