@isTest
public with sharing class SSNDuplicateManagement_Test {
    
    @isTest
    static void getSSNduplicates_Test(){

        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>();

        nu_dse__Prospect__c prospectInstance2 = TestRecordCreator.createProspect();
        prospectInstance2.nu_dse__First_Name__c = 'Duplicate_SSN';
        prospectInstance2.nu_dse__SSN__c = '111-11-1111';
        prospectInstance2.nu_dse__Co_SSN__c = '222-22-2222';
        prospectList.add(prospectInstance2);

        nu_dse__Prospect__c prospectInstance3 = TestRecordCreator.createProspect();
        prospectInstance3.nu_dse__First_Name__c = 'Duplicate_SSN';
        prospectInstance3.nu_dse__SSN__c = '111-11-1111';
        prospectInstance3.nu_dse__Co_SSN__c = '222-22-2222';
        prospectList.add(prospectInstance3);

        nu_dse__Prospect__c prospectInstance4 = TestRecordCreator.createProspect();
        prospectInstance4.nu_dse__First_Name__c = 'Duplicate_SSN';
        prospectInstance4.nu_dse__SSN__c = '111-11-1111';
        prospectInstance4.nu_dse__Co_SSN__c = '222-22-2223';
        prospectList.add(prospectInstance4);


        insert prospectList;

        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType 
                                    WHERE sObjectType = 'Account' AND isPersonType = true 
                                        AND DeveloperName = 'Client' LIMIT 1];


        Account acc = TestRecordCreator.createAccount('Account1', accRecTypeList[0].Id);
        acc.nu_dse__SSN__c = '111-11-1111';
        acc.nu_dse__Co_SSN__c = '222-22-2222';
        insert acc; 
        Account acc1 = TestRecordCreator.createAccount('Account1', accRecTypeList[0].Id);
        acc1.nu_dse__SSN__c = '111-11-1112';
        acc1.nu_dse__Co_SSN__c = '222-22-2222';
        insert acc1; 
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('GCS');
        insert processor;

        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, processor.Id);
        program.nu_dse__Program_Status__c = 'Active Client';
        insert program;
        nu_dse__Program__c program1 = TestRecordCreator.createProgram(acc1.Id, processor.Id);
        program1.nu_dse__Program_Status__c = 'Active Client';
        insert program1;

        Test.startTest();

            SSNDuplicateFinderService.SSNDuplicateManagmentRequest req1 = new SSNDuplicateFinderService.SSNDuplicateManagmentRequest();
            req1.clientType = SSNDuplicateFinderService.ClientType.CLIENT;
            req1.socialSecutityNumbers = new Set<String>{'111-11-1111'};

            SSNDuplicateFinderService.SSNDuplicateManagmentRequest req2 = new SSNDuplicateFinderService.SSNDuplicateManagmentRequest();
            req2.clientType = SSNDuplicateFinderService.ClientType.CO_CLIENT;
            req2.socialSecutityNumbers = new Set<String>{'222-22-2222'};

            //SSNDuplicateFinderService.SSNDuplicateManagmentRequest req3 = new SSNDuplicateFinderService.SSNDuplicateManagmentRequest();
            //req3.socialSecutityNumbers = new Set<String>{'222-22-2222'};
            RestRequest request = new RestRequest();
            request.requestUri ='https://test.salesforce.com/services/apexrest/v1/ssn/getDuplicates/';
            request.requestBody = Blob.valueOf(JSON.serialize(req1));
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = new RestResponse();
            SSNDuplicateManagement.getSSNduplicates();
            RestResponse res1 = RestContext.response;
            Map<String, List<SObject>> clientDuplicateRecMap = (Map<String, List<SObject>>)JSON.deserialize(res1.responseBody.toString(), Map<String, List<SObject>>.class);

            request.requestBody = Blob.valueOf(JSON.serialize(req2));
            SSNDuplicateManagement.getSSNduplicates();
            RestResponse res2 = RestContext.response;
            Map<String, List<SObject>> coClientDuplicateRecMap = (Map<String, List<SObject>>)JSON.deserialize(res2.responseBody.toString(), Map<String, List<SObject>>.class);
			
       		request.requestBody = Blob.valueOf('{"clientType": "new","socialSecutityNumbers": ["111-11-1111"]}');
            //request.requestBody = Blob.valueOf(JSON.serialize(req3));
            SSNDuplicateManagement.getSSNduplicates();
            RestResponse res3 = RestContext.response;

            SSNDuplicateFinderService.SSNDuplicateManagementResponse errorResponse = (SSNDuplicateFinderService.SSNDuplicateManagementResponse)
                JSON.deserialize(res3.responseBody.toString(), SSNDuplicateFinderService.SSNDuplicateManagementResponse.class);
            
        Test.stopTest();

        System.assertEquals(4 ,clientDuplicateRecMap.get('111-11-1111').size());
        System.assertEquals(4 ,coClientDuplicateRecMap.get('222-22-2222').size());
        System.assert(String.isNotBlank(errorResponse.message));
    }
}