@isTest
public with sharing class ComplianceRequestEmailHander_Test {
    
    static testMethod void testComplianceRequestCreation() {
    
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
        // Create a new test lead and insert it in the test method.
        Contact contactRec = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'user@test.com');
        insert contactRec;
    
        /*nu_dse__Data_Mapping__c emailComplianceReqDataMapping = TestRecordCreator.createDataMapping('EmailToComplianceRequest', 'Messaging.inboundEmail', 'Compliance_Request__c');
        insert emailComplianceReqDataMapping;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMapping1 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'subject', 'Subject__c', false, '');
        nu_dse__Field_mapping__c fieldMapping2 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'plainTextBody', 'Description__c', false, '');
        nu_dse__Field_mapping__c fieldMapping3 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromAddress', 'Email_Address__c', false, '');
        nu_dse__Field_mapping__c fieldMapping4 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromName', 'Name__c', false, '');

        fieldMappingList.add(fieldMapping1);
        fieldMappingList.add(fieldMapping2);
        fieldMappingList.add(fieldMapping3);
        fieldMappingList.add(fieldMapping4);

        insert fieldMappingList;*/

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
                                    
        system.assertEquals(email.subject, createdComplianceReq.Description__c);

        EmailMessage emailRec = [SELECT Id, TextBody FROM EmailMessage WHERE RelatedToId =:createdComplianceReq.Id LIMIT 1];
        system.assertEquals(email.plainTextBody, emailRec.TextBody);                
    }

    static testMethod void testComplianceRequestCreationDefaultCon() {
        
        Contact defaultContactRec = new Contact(FirstName = 'Test', LastName = 'Default Contact', Email = 'info@test.com');
        insert defaultContactRec;

        /*nu_dse__Data_Mapping__c emailComplianceReqDataMapping = TestRecordCreator.createDataMapping('EmailToComplianceRequest', 'Messaging.inboundEmail', 'Compliance_Request__c');
        insert emailComplianceReqDataMapping;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMapping1 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'subject', 'Subject__c', false, '');
        nu_dse__Field_mapping__c fieldMapping2 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'plainTextBody', 'Description__c', false, '');
        nu_dse__Field_mapping__c fieldMapping3 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromAddress', 'Email_Address__c', false, '');
        nu_dse__Field_mapping__c fieldMapping4 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromName', 'Name__c', false, '');

        fieldMappingList.add(fieldMapping1);
        fieldMappingList.add(fieldMapping2);
        fieldMappingList.add(fieldMapping3);
        fieldMappingList.add(fieldMapping4);

        insert fieldMappingList;*/

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

        Compliance_Request__c createdComplianceReq = [SELECT Id, Description__c FROM Compliance_Request__c 
                                                      WHERE Contact__c = :defaultContactRec.Id LIMIT 1];

        system.assertEquals(email.subject, createdComplianceReq.Description__c);
        //system.assertEquals(email.plainTextBody, createdComplianceReq.Description__c);                
    }   

    static testMethod void testComplianceRequestCreationException() {
        
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
    
        /*nu_dse__Data_Mapping__c emailComplianceReqDataMapping = TestRecordCreator.createDataMapping('EmailToComplianceRequest', 'Messaging.inboundEmail', 'Compliance_Request__c');
        insert emailComplianceReqDataMapping;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMapping1 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'subject', 'Subject__c', false, '');
        nu_dse__Field_mapping__c fieldMapping2 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'plainTextBody', 'Description__c', false, '');
        nu_dse__Field_mapping__c fieldMapping3 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromAddress', 'Email_Address__c', false, '');
        nu_dse__Field_mapping__c fieldMapping4 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, 'fromName', 'Name__c', false, '');
        nu_dse__Field_mapping__c fieldMapping5 = TestRecordCreator.createFieldMapping(emailComplianceReqDataMapping.Id, '', 'Priority__c', true, 'Low');

        fieldMappingList.add(fieldMapping1);
        fieldMappingList.add(fieldMapping2);
        fieldMappingList.add(fieldMapping3);
        fieldMappingList.add(fieldMapping4);
        fieldMappingList.add(fieldMapping5);

        insert fieldMappingList;

        complianceReqObj.handleInboundEmail(email, env);*/

        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Message__c 
                                                   FROM nu_dse__Error_Log__c LIMIT 1];

        //system.assertEquals('Mapping records not available. Please create Data and field mappings.', errorLogList[0].nu_dse__Message__c);
        system.assertEquals('Invalid Contact Id for task assignment. Please check Custom metadata record with Developer Name \'Complaince_Request_Email\'',
                     errorLogList[0].nu_dse__Message__c);
    }   
}