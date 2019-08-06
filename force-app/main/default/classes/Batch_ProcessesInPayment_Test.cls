@isTest
public class Batch_ProcessesInPayment_Test {

    @testSetup static void methodName() {
        
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
        system.debug('Payment::'+payment);
        insert payment;
        
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
            Integer activityPaddingDays = 2;
            Database.executeBatch(new Batch_ProcessesInPayment(activityPaddingDays));
            
        Test.stopTest(); 
        
        List<nu_dse__Payment__c> paymentList = [SELECT Id, Create_Payment_Reminder_Tasks__c FROM nu_dse__Payment__c];
        
        system.assertEquals(false, paymentList[0].Create_Payment_Reminder_Tasks__c);
        
        List<Task> taskList = [SELECT Id, Subject FROM Task];
        
        system.assertEquals(2, taskList.size());
        system.assertEquals('Payment SMS Reminder', taskList[0].Subject);
        system.assertEquals('Payment Email Reminder', taskList[1].Subject);
    }
    
    static testMethod void paymentReminderTaskCreationExceptionTest() {
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'WhatId' LIMIT 1];
        delete emailfieldMapping;
        
        Test.startTest();
            
            try {
                Integer activityPaddingDays = 2;
                Database.executeBatch(new Batch_ProcessesInPayment(activityPaddingDays));
            } catch (exception e) {
                system.assert(e.getmessage() != '');
            }
            
        Test.stopTest(); 
    }
    
    static testMethod void paymentReminderTaskCreationExceptionTest2() {
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'ActivityDate' LIMIT 1];
        emailfieldMapping[0].nu_dse__setDefaultValue__c = true;
        emailfieldMapping[0].nu_dse__Default_Value__c = 'Test';
        update emailfieldMapping;
        
        Test.startTest();
            
            try {
                Integer activityPaddingDays = 2;
                Database.executeBatch(new Batch_ProcessesInPayment(activityPaddingDays));
            } catch (exception e) {
                system.assert(e.getmessage() != '');
            }
            
        Test.stopTest(); 
    }
    
    static testMethod void paymentReminderTaskCreationExceptionTest3() {
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        
        List<nu_dse__Field_mapping__c> emailfieldMapping = [SELECT Id FROM nu_dse__Field_mapping__c WHERE nu_dse__Target_Field__c = 'Status' LIMIT 1];
        emailfieldMapping[0].nu_dse__Target_Field__c = 'OwnerId';
        emailfieldMapping[0].nu_dse__setDefaultValue__c = true;
        emailfieldMapping[0].nu_dse__Default_Value__c = accList[0].Id;
        update emailfieldMapping;
        
        Test.startTest();
            
            try {
                Integer activityPaddingDays = 2;
                Database.executeBatch(new Batch_ProcessesInPayment(null));
            } catch (exception e) {
                system.assert(e.getmessage() != '');
            }
            
        Test.stopTest(); 
    }
}