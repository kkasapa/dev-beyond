@isTest
public with sharing class Batch_OfferAuthReminder_Test {
    
    //setting up data for running tests
    @testSetup static void dataCreator() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        Account clientAccount = TestRecordCreator.createAccount('clientAcc', accRecordTypeId);
        insert clientAccount;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Type__c = 'CFT';
        insert processor;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        program.nu_dse__Total_Debt_Included__c = 100;
        insert program;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(program.Id, tradeLine.Id, 2000, 200, 6, 15);
        offer.nu_dse__Status__c = '03-Offer Approved (Pre-payment setup)';
        offer.Accepted_Date__c = system.today();
        insert offer;

        List<nu_dse__Communication_Template__c> commTempList = new List<nu_dse__Communication_Template__c>{
            new nu_dse__Communication_Template__c(Name = 'Get Offer Auth SMS'),
            new nu_dse__Communication_Template__c(Name = 'Get Offer Auth EMAIL')
        };
        insert commTempList;
    }

    static testMethod void offerAuthReminderTaskCreation_Test() {
        
        Test.startTest();
            Database.executeBatch(new Batch_OfferAuthReminder());
        Test.stopTest(); 

        List<Task> taskList = [SELECT Id, Subject FROM Task];
        
        system.assertEquals(4, taskList.size());
        system.assert(taskList[0].Subject.contains('Offer Auth SMS'));
        system.assert(taskList[1].Subject.contains('Offer Auth Email'));
    }

    static testMethod void offerAuthReminderTaskDelete_Test() {
        
        List<nu_dse__Offer__c> offerList = [SELECT Id FROM nu_dse__Offer__c LIMIT 1];
        offerList[0].Client_Authorization_Received__c = true;
        update offerList[0];

        List<Task> taskList = new List<Task>();
        for(Integer i = 1; i <= 4; i ++){
            Task taskInst = new Task();
            taskInst.WhatId = offerList[0].Id;
            if(math.mod(i, 2) == 0){
                taskInst.Subject = 'Offer Auth SMS DAY '+i;
            }
            else{
                taskInst.Subject = 'Offer Auth EMAIL DAY '+i;
            }
            taskList.add(taskInst);
        }
        insert taskList;

        Test.startTest();
            Database.executeBatch(new Batch_OfferAuthReminder(new Set<Id>{offerList[0].Id}));
        Test.stopTest(); 

        List<Task> newTaskList = [SELECT Id, Subject FROM Task WHERE Status != 'Completed'];
        
        system.assertEquals(0, newTaskList.size());
    }
}