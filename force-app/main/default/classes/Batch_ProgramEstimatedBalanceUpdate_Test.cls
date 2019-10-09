@isTest
public with sharing class Batch_ProgramEstimatedBalanceUpdate_Test {
    
    //setting up data for running tests
    @testSetup static void dataCreator() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();

        Account clientAccount = TestRecordCreator.createAccount('clientAcc', accRecordTypeId);
        insert clientAccount;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Type__c = 'CFT';
        insert processor;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        program.nu_dse__Trust_Account_Balance__c = 1000;
        insert program;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(program.Id, tradeLine.Id, 2000, 200, 6, 15);
        insert offer;
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        nu_dse__Payment__c draftPayment1 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        draftPayment1.nu_dse__Amount__c = 5000;
        draftPayment1.nu_dse__Schedule_Date__c  = system.today().addMonths(1);
        nu_dse__Payment__c draftPayment2 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        draftPayment2.nu_dse__Amount__c = 4000;
        draftPayment2.nu_dse__Schedule_Date__c  = system.today().addMonths(2).addDays(10);
        nu_dse__Payment__c draftPayment3 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        draftPayment3.nu_dse__Amount__c = 3000;
        draftPayment3.nu_dse__Schedule_Date__c  = system.today().addMonths(4);
        nu_dse__Payment__c draftPayment4 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        draftPayment4.nu_dse__Amount__c = 2000;
        draftPayment4.nu_dse__Schedule_Date__c  = system.today().addMonths(7);
        nu_dse__Payment__c draftPayment5 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        draftPayment5.nu_dse__Amount__c = 1000;
        draftPayment5.nu_dse__Schedule_Date__c  = system.today().addMonths(10);

        nu_dse__Payment__c feepPayment1 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Fee Withdrawal', feeRecordTypeId, offer.Id);
        feepPayment1.nu_dse__Amount__c = 500;
        feepPayment1.nu_dse__Schedule_Date__c  = system.today().addMonths(1);
        nu_dse__Payment__c feepPayment2 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Fee Withdrawal', feeRecordTypeId, offer.Id);
        feepPayment2.nu_dse__Amount__c = 400;
        feepPayment2.nu_dse__Schedule_Date__c  = system.today().addMonths(2).addDays(10);
        nu_dse__Payment__c feepPayment3 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Fee Withdrawal', feeRecordTypeId, offer.Id);
        feepPayment3.nu_dse__Amount__c = 300;
        feepPayment3.nu_dse__Schedule_Date__c  = system.today().addMonths(4);
        nu_dse__Payment__c feepPayment4 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Fee Withdrawal', feeRecordTypeId, offer.Id);
        feepPayment4.nu_dse__Amount__c = 200;
        feepPayment4.nu_dse__Schedule_Date__c  = system.today().addMonths(7);
        nu_dse__Payment__c feepPayment5 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Fee Withdrawal', feeRecordTypeId, offer.Id);
        feepPayment5.nu_dse__Amount__c = 100;
        feepPayment5.nu_dse__Schedule_Date__c  = system.today().addMonths(10);
        
        nu_dse__Payment__c settlementPayment1 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Withdrawal', settlementRecordTypeId, offer.Id);
        settlementPayment1.nu_dse__Amount__c = 100;
        nu_dse__Payment__c settlementPayment2 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Withdrawal', settlementRecordTypeId, offer.Id);
        settlementPayment2.nu_dse__Amount__c = 100;
        settlementPayment2.nu_dse__Schedule_Date__c  = system.today().addMonths(2).addDays(10);
        nu_dse__Payment__c settlementPayment3 = TestRecordCreator.createPayment(program.Id, 'Scheduled', 'Withdrawal', settlementRecordTypeId, offer.Id);
        settlementPayment3.nu_dse__Amount__c = 100;
        settlementPayment3.nu_dse__Schedule_Date__c  = system.today().addMonths(10);

        paymentList.add(draftPayment1);
        paymentList.add(draftPayment2);
        paymentList.add(draftPayment3);
        paymentList.add(draftPayment4);
        paymentList.add(draftPayment5);
        paymentList.add(feepPayment1);
        paymentList.add(feepPayment2);
        paymentList.add(feepPayment3);
        paymentList.add(feepPayment4);
        paymentList.add(feepPayment5);
        paymentList.add(settlementPayment1);
        paymentList.add(settlementPayment2);
        paymentList.add(settlementPayment3);
        insert paymentList;
    }

    static testMethod void ProgramEstimatedBalanceUpdate() {
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];

        Test.startTest();
            // executing the batch to calculate the estimated balance of 2,3,6,9,12 months
            Database.executeBatch(new Batch_ProgramEstimatedBalanceUpdate(new Set<Id>{programList[0].Id}));

            Schedule_ProgramEstimatedBalanceUpdate schedulerInst = new Schedule_ProgramEstimatedBalanceUpdate();
            String schCronExp = '0 0 23 * * ?'; 
            system.schedule('Test Schedule ProgramEstimatedBalanceUpdateBatch', schCronExp, schedulerInst); 
            
        Test.stopTest(); 
        
        List<nu_dse__Program__c> updatedProgramList = [SELECT Id, Estimated_Month_2_Balance__c, Estimated_Month_3_Balance__c,
                                                    Estimated_Month_6_Balance__c, Estimated_Month_9_Balance__c, Estimated_Month_12_Balance__c
                                                FROM nu_dse__Program__c WHERE Id =: programList[0].Id LIMIT 1];
        //checking the program's estimated balance fields after the batch run
        system.assertEquals(5400, updatedProgramList[0].Estimated_Month_2_Balance__c);
        system.assertEquals(8900, updatedProgramList[0].Estimated_Month_3_Balance__c);
        system.assertEquals(11600, updatedProgramList[0].Estimated_Month_6_Balance__c);
        system.assertEquals(13400, updatedProgramList[0].Estimated_Month_9_Balance__c);
        system.assertEquals(14200, updatedProgramList[0].Estimated_Month_12_Balance__c);
    }
}