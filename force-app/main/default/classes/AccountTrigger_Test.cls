@isTest
public class AccountTrigger_Test implements HttpCalloutMock {
    @TestSetup
    static void makeData(){
        Id clientAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        List<Account> accList = new List<Account>();
        accList.add(TestRecordCreator.createAccount('Test1', clientAccountRecId));
        accList.add(TestRecordCreator.createAccount('Test2', clientAccountRecId));
        accList.add(TestRecordCreator.createAccount('Test3', clientAccountRecId));
        accList.add(TestRecordCreator.createAccount('Test4', clientAccountRecId));
        accList.add(TestRecordCreator.createAccount('Test5', clientAccountRecId));
        insert accList;
        nu_dse__Fee_Template__c feeTemp = TestRecordCreator.createFeeTemplate();
        feeTemp.Legal_Plan_Included__c = true;
        insert feeTemp;
        nu_dse__Processor__c processor =  TestRecordCreator.createProcessor('CFT_TEST');
        insert processor;
        List<nu_dse__Program__c> progList = new List<nu_dse__Program__c>();
        progList.add(TestRecordCreator.createProgram(accList[0].Id, processor.Id));  
        progList[0].nu_dse__Fee_Template__c = feeTemp.Id;
        progList.add(TestRecordCreator.createProgram(accList[1].Id, processor.Id));  
        progList[1].nu_dse__Fee_Template__c = feeTemp.Id;
        progList.add(TestRecordCreator.createProgram(accList[2].Id, processor.Id));  
        progList[2].nu_dse__Fee_Template__c = feeTemp.Id;
        progList.add(TestRecordCreator.createProgram(accList[3].Id, processor.Id));  
        progList[3].nu_dse__Fee_Template__c = feeTemp.Id;
        progList.add(TestRecordCreator.createProgram(accList[4].Id, processor.Id));  
        progList[4].nu_dse__Fee_Template__c = feeTemp.Id;
        insert progList;
    }

     @isTest
    public static void testPlatformEventpublish() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AccountTrigger_Test());
        AWS_SQS_Credentials__c cred = new AWS_SQS_Credentials__c();
        cred.accessKey__c = 'mockAccess';
        cred.endpointURL__c = 'https://www.mockaws.com/';
        cred.host__c = 'host';
        cred.Description__c = 'BLP SQS Queue';
        cred.region__c = 'TX';
        cred.secret_access_key__c = 'm0ck5amp13';
        insert cred;
        List<Account> accList = [SELECT Id, nu_dse__Co_First_Name__c, nu_dse__Co_Last_Name__c
                                FROM Account LIMIT 10];
        for(Account clientAcc: accList) {
            clientAcc.nu_dse__Co_State__c = 'TX';
        }
        update accList;
        Test.stopTest();
        //System.assert()
    }
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"SendMessageResponse":{"ResponseMetadata":{"RequestId":"5a237970-f9ad-5a48-a6ec-2cbd2e11fefa"},"SendMessageResult":{"MD5OfMessageAttributes":"98a205eeef15db2f82c491e26907f91e","MD5OfMessageBody":"786329b34bbe53ab40a54a19cd597f2d","MessageId":"1a757e5d-b424-4b0c-bb0b-efcaeb0969e0","SequenceNumber":null}}}');
        response.setStatusCode(200);
        return response; 
    }

}