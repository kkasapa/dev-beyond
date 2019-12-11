@isTest
public with sharing class InboundEmailTaskCreation_Test {
    
    static testMethod void testTaskCreation() {
    
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
        // Create a new test lead and insert it in the test method.
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account accRec = TestRecordCreator.createAccount('Test Acc', accRecordTypeId);
        accRec.PersonEmail = 'user@test.com';
        insert accRec;
    
        Account defaulAccountRec = TestRecordCreator.createAccount('Email Task Default Account', accRecordTypeId);
        defaulAccountRec.PersonEmail = 'info@test.com';
        insert defaulAccountRec;

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';

        // Call the class and test it with the data in the testMethod.
        InboundEmailTaskCreation inboundTaskCreationObj = new InboundEmailTaskCreation();
        inboundTaskCreationObj.handleInboundEmail(email, env);

        Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE whatId = :accRec.Id LIMIT 1];

        system.assertEquals(email.subject, createdTask.Subject);
        system.assertEquals(email.plainTextBody, createdTask.Description);                
    }

    static testMethod void testTaskCreationDefaultAcc() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

        Account defaulAccountRec = TestRecordCreator.createAccount('Email Task Default Account', accRecordTypeId);
        defaulAccountRec.PersonEmail = 'info@test.com';
        insert defaulAccountRec;

        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';

        // Call the class and test it with the data in the testMethod.
        InboundEmailTaskCreation inboundTaskCreationObj = new InboundEmailTaskCreation();
        inboundTaskCreationObj.handleInboundEmail(email, env);

        Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE whatId = :defaulAccountRec.Id LIMIT 1];

        system.assertEquals(email.subject, createdTask.Subject);
        system.assertEquals(email.plainTextBody, createdTask.Description);                
    }   

    static testMethod void testTaskCreationException() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';

        // Call the class and test it with the data in the testMethod.
        InboundEmailTaskCreation inboundTaskCreationObj = new InboundEmailTaskCreation();
        inboundTaskCreationObj.handleInboundEmail(email, env);

        nu_dse__Error_Log__c errorLog = [SELECT Id, nu_dse__Message__c FROM nu_dse__Error_Log__c LIMIT 1];

        system.assertEquals('Email Task Default Account is not available. Please create Account with Last name as Email Task Default Account.', errorLog.nu_dse__Message__c);              
    }   
}
