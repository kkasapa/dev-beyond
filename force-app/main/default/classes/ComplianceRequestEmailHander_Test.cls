@isTest
public with sharing class ComplianceRequestEmailHander_Test {
    
    static testMethod void testComplianceRequestCreation() {
    
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
        // Create a new test lead and insert it in the test method.
        Contact contactRec = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'user@test.com');
        insert contactRec;

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        email.fromName = 'Test user';
        env.fromAddress = 'user@test.com';
        email.toAddresses = new List<String>{'user1@test.com', 'user2@test.com'};

        // Call the class and test it with the data in the testMethod.
        ComplianceRequestEmailHander complianceReqObj = new ComplianceRequestEmailHander();
        complianceReqObj.handleInboundEmail(email, env);

        Compliance_Request__c createdComplianceReq = [SELECT Id, Description__c FROM Compliance_Request__c 
                                                      WHERE Contact__c = :contactRec.Id LIMIT 1];
                                    
        system.assertEquals(email.subject+'\n'+email.plainTextBody, createdComplianceReq.Description__c);

        EmailMessage emailRec = [SELECT Id, TextBody FROM EmailMessage WHERE RelatedToId =:createdComplianceReq.Id LIMIT 1];
        system.assertEquals(email.plainTextBody, emailRec.TextBody);                
    }

    static testMethod void testComplianceRequestCreation2() {
        
        Contact ContactRec = new Contact(FirstName = 'Test', LastName = 'Default Contact', Email = 'user@test.com');
        insert ContactRec;
        
        Compliance_Request__c complianceReq = new Compliance_Request__c(Description__c = 'Test Call', Name__c= 'Test', 
            From_Address__c = 'user@test.com', Contact__c = ContactRec.Id);
        insert complianceReq;

        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';
        email.fromName = 'Test user';

        // Call the class and test it with the data in the testMethod.
        ComplianceRequestEmailHander inboundTaskCreationObj = new ComplianceRequestEmailHander();
        inboundTaskCreationObj.handleInboundEmail(email, env);

        List<Compliance_Request__c> createdComplianceReqList = [SELECT Id, Description__c FROM Compliance_Request__c 
                                                                WHERE Contact__c = :ContactRec.Id];

        system.assertEquals(email.subject+'\n'+email.plainTextBody, createdComplianceReqList[1].Description__c);
        //system.assertEquals(email.plainTextBody, createdComplianceReq.Description__c);                
    }   

    static testMethod void testComplianceRequestCreation3() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Test inbound email task creation';
        email.plainTextBody = 'Inbound email test text body';
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';
        email.fromName = 'Test user';

        // Call the class and test it with the data in the testMethod.
        ComplianceRequestEmailHander complianceReqObj = new ComplianceRequestEmailHander();
        complianceReqObj.handleInboundEmail(email, env);     

        Contact createdCon = [SELECT Id, Email FROM Contact LIMIT 1];      

        system.assertEquals('user@test.com', createdCon.Email);   
    
        Compliance_Request__c createdComplianceReq = [SELECT Id, Description__c FROM Compliance_Request__c 
                                                      WHERE Contact__c = :createdCon.Id LIMIT 1];
                                    
        system.assertEquals(email.subject+'\n'+email.plainTextBody, createdComplianceReq.Description__c);

        EmailMessage emailRec = [SELECT Id, TextBody FROM EmailMessage WHERE RelatedToId =:createdComplianceReq.Id LIMIT 1];
        system.assertEquals(email.plainTextBody, emailRec.TextBody);   
    }   

    static testMethod void testComplianceRequestException() {
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        // Test with the subject that matches the unsubscribe statement.
        email.subject = null;
        email.plainTextBody = null;
        email.fromAddress = 'user@test.com';
        env.fromAddress = 'user@test.com';

        // Call the class and test it with the data in the testMethod.
        ComplianceRequestEmailHander complianceReqObj = new ComplianceRequestEmailHander();
        complianceReqObj.handleInboundEmail(email, env);  

        nu_dse__Error_Log__c errLog = [SELECT Id FROM nu_dse__Error_Log__c];
        system.assert(errLog != null); 
    }   
}