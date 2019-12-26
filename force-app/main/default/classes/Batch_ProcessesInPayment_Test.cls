@isTest
public class Batch_ProcessesInPayment_Test {
    
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
        
        nu_dse__Payment__c payment2 = TestRecordCreator.createPayment(program.Id, 'Pending', 'Deposit', draftRecordTypeId, offer.Id);
        payment2.nu_dse__Schedule_Date__c = system.today().addDays(2); 
        insert payment2;
        
        nu_dse__Data_Mapping__c smsDataMapping = TestRecordCreator.createDataMapping('Create Payments SMS Reminders', 'nu_dse__Payment__c', 'Task');
        smsDataMapping.External_Id__c = 'Create_Payments_SMS_Reminders';
        insert smsDataMapping;
        
        nu_dse__Data_Mapping__c emailDataMapping = TestRecordCreator.createDataMapping('Create Payments Email Reminders', 'nu_dse__Payment__c', 'Task');
        emailDataMapping.External_Id__c = 'Create_Payments_Email_Reminders';
        insert emailDataMapping;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c smsfieldMapping1 = TestRecordCreator.createFieldMapping(smsDataMapping.Id, 'Id', 'WhatId', false, '');
        nu_dse__Field_mapping__c smsfieldMapping2 = TestRecordCreator.createFieldMapping(smsDataMapping.Id, '', 'Subject', true, 'Payment SMS Reminder');
        nu_dse__Field_mapping__c smsfieldMapping3 = TestRecordCreator.createFieldMapping(smsDataMapping.Id, 'nu_dse__Schedule_Date__c', 'ActivityDate', false, '');
        nu_dse__Field_mapping__c smsfieldMapping4 = TestRecordCreator.createFieldMapping(smsDataMapping.Id, '', 'nu_dse__Is_System_Task__c', true, 'true');
        
        nu_dse__Field_mapping__c emailfieldMapping1 = TestRecordCreator.createFieldMapping(emailDataMapping.Id, 'Id', 'WhatId', false, '');
        nu_dse__Field_mapping__c emailfieldMapping2 = TestRecordCreator.createFieldMapping(emailDataMapping.Id, '', 'Subject', true, 'Payment Email Reminder');
        nu_dse__Field_mapping__c emailfieldMapping3 = TestRecordCreator.createFieldMapping(emailDataMapping.Id, 'nu_dse__Schedule_Date__c', 'ActivityDate', false, '');
        nu_dse__Field_mapping__c emailfieldMapping4 = TestRecordCreator.createFieldMapping(emailDataMapping.Id, '', 'nu_dse__Is_System_Task__c', true, 'true');
        nu_dse__Field_mapping__c emailfieldMapping5 = TestRecordCreator.createFieldMapping(emailDataMapping.Id, '', 'Status', true, 'Not Started');
        
        smsfieldMapping1.Target_Field_Data_Type__c = 'Id';
        smsfieldMapping2.Target_Field_Data_Type__c = 'String';
        smsfieldMapping3.Target_Field_Data_Type__c = 'Date';
        smsfieldMapping4.Target_Field_Data_Type__c = 'Boolean';
        emailfieldMapping1.Target_Field_Data_Type__c = 'Id';
        emailfieldMapping2.Target_Field_Data_Type__c = 'String';
        emailfieldMapping3.Target_Field_Data_Type__c = 'Date';
        emailfieldMapping4.Target_Field_Data_Type__c = 'Boolean';
        emailfieldMapping5.Target_Field_Data_Type__c = 'String';
        fieldMappingList.add(smsfieldMapping1);
        fieldMappingList.add(smsfieldMapping2);
        fieldMappingList.add(smsfieldMapping3);
        fieldMappingList.add(smsfieldMapping4);
        fieldMappingList.add(emailfieldMapping1);
        fieldMappingList.add(emailfieldMapping2);
        fieldMappingList.add(emailfieldMapping3);
        fieldMappingList.add(emailfieldMapping4);
        fieldMappingList.add(emailfieldMapping5);
        insert fieldMappingList;
    }

    static testMethod void paymentReminderTaskCreation() {
        
        Test.startTest();
        Database.executeBatch(new Batch_ProcessesInPayment(''));
        
        Test.stopTest(); 
        
        List<nu_dse__Payment__c> paymentList = [SELECT Id, Create_Payment_Reminder_Tasks__c FROM nu_dse__Payment__c];
        
        system.assertEquals(false, paymentList[0].Create_Payment_Reminder_Tasks__c);
        
        List<Task> taskList = [SELECT Id, Subject, ActivityDate FROM Task];
        
        system.assertEquals(4, taskList.size());
        system.assert(taskList[0].Subject.contains('Payment SMS Reminder'));
        system.assert(taskList[1].Subject.contains('Payment Email Reminder'));
        system.assertEquals(system.today().addDays(3), taskList[0].ActivityDate);
        system.assertEquals(system.today().addDays(1), taskList[2].ActivityDate);
    }
    
    static testMethod void deleteMappingExceptionTest() {
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'WhatId' LIMIT 1];
        delete emailfieldMapping;
        
        Test.startTest();
            Database.executeBatch(new Batch_ProcessesInPayment('nu_dse__Schedule_Date__c > TODAY'));
        Test.stopTest(); 
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id FROM nu_dse__Error_Log__c];
        system.assert(errorLogList.isEmpty() == false);
    }
    
    static testMethod void invalidValueMappingExceptionTest() {
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'ActivityDate' LIMIT 1];
        emailfieldMapping[0].nu_dse__setDefaultValue__c = true;
        emailfieldMapping[0].nu_dse__Default_Value__c = 'Test';
        update emailfieldMapping;
        
        Test.startTest();
            Database.executeBatch(new Batch_ProcessesInPayment('Id != null'));
        Test.stopTest(); 
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id FROM nu_dse__Error_Log__c];
        system.assert(errorLogList.isEmpty() == false);
    }
    
    static testMethod void defaultValueExceptionTest() {
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'Status' LIMIT 1];
        emailfieldMapping[0].nu_dse__Target_Field__c = 'OwnerId';
        emailfieldMapping[0].nu_dse__setDefaultValue__c = true;
        emailfieldMapping[0].nu_dse__Default_Value__c = accList[0].Id;
        update emailfieldMapping;
        
        Test.startTest();
            Database.executeBatch(new Batch_ProcessesInPayment(''));
        Test.stopTest(); 
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id FROM nu_dse__Error_Log__c];
        system.assert(errorLogList.isEmpty() == false);
    }
    
    static testMethod void paymentRemiderbasedOnIdSet() {
        
        List<nu_dse__Payment__c> paymentList = [SELECT Id, Create_Payment_Reminder_Tasks__c FROM nu_dse__Payment__c];        
        Database.executeBatch(new Batch_ProcessesInPayment(new Set<Id>{paymentList[0].Id}));
        
    }
    
    //Check SMS/EMail Task Deleted while Status Updation
    static testMethod void checkTaskDelete(){

        nu_dse__Payment__c paymentInst = [SELECT Id, nu_dse__Transaction_Status__c
                                          FROM nu_dse__Payment__c LIMIT 1];
        paymentInst.nu_dse__Transaction_Status__c = 'Cancelled';
        update paymentInst;

        List<Task> taskList = new List<Task>();
        for(Integer i = 1; i <= 4; i ++){
            Task taskInst = new Task();
            taskInst.WhatId = paymentInst.Id;
            if(math.mod(i, 2) == 0){
                taskInst.Subject = 'SMS REMINDER';
            }
            else{
                taskInst.Subject = 'EMAIL REMINDER';
            }
            taskList.add(taskInst);
        }
        insert taskList;
        
        Test.startTest();
            Database.executeBatch(new Batch_ProcessesInPayment(''));
        Test.stopTest();
        
        List<Task> taskList3 = [SELECT Id, ActivityDate, WhatId, Subject FROM Task 
                                WHERE WhatId = :paymentInst.Id];
        System.assertEquals(taskList3.size(), 0);  
    }
    //Check Task Scheduled Date updated or not while Payment Scheduled Date update
    static testMethod void checkTaskScheduledDateUpdate(){
        
        nu_dse__Payment__c paymentInst = [SELECT Id, nu_dse__Schedule_Date__c 
                                          FROM nu_dse__Payment__c LIMIT 1];
        paymentInst.nu_dse__Schedule_Date__c = Date.today().addDays(7);
        update paymentInst;
        
        Test.startTest();
            Set<Id> paymentIdSet = new Set<Id>{paymentInst.Id};
            Database.executeBatch(new Batch_ProcessesInPayment(paymentIdSet));
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, ActivityDate, WhatId, Subject FROM Task 
                               WHERE WhatId = :paymentInst.Id];
        System.assertEquals(Date.today().addDays(5), taskList[0].ActivityDate);
    }
}