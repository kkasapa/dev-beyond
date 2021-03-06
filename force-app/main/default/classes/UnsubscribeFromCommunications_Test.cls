@isTest
public class UnsubscribeFromCommunications_Test {
    
    @isTest
    static void CommunicationSubscriptionService_Test(){

        Id recAccTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>();
        nu_dse__Prospect__c prospect1 = TestRecordCreator.createProspect();
        nu_dse__Prospect__c prospect2 = TestRecordCreator.createProspect();
        prospect2.Unsubscribed_from_Emails__c = true;
        nu_dse__Prospect__c prospect3 = TestRecordCreator.createProspect();
        prospect3.nu_dse__Email_Address__c = 'test@test.com';
        nu_dse__Prospect__c prospect4 = TestRecordCreator.createProspect();
        prospect4.nu_dse__Email_Address__c = 'test1@test.com';
        prospect4.Unsubscribed_from_Emails__c = true;
        prospectList.add(prospect1);
        prospectList.add(prospect2);
        prospectList.add(prospect3);
        prospectList.add(prospect4);
        insert prospectList;

        List<Account> accList = new List<Account>();
        Account acc1 = TestRecordCreator.createAccount('Test Acc1', recAccTypeId);
        Account acc2 = TestRecordCreator.createAccount('Test Acc2', recAccTypeId);
        acc2.PersonEmail = 'test@test.com';
        Account acc3 = TestRecordCreator.createAccount('Test Acc3', recAccTypeId);
        acc3.Unsubscribed_from_Emails__c = true;
        Account acc4 = TestRecordCreator.createAccount('Test Acc3', recAccTypeId);
        acc4.PersonEmail = 'test1@test.com';
        acc4.Unsubscribed_from_Emails__c = true;
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        accList.add(acc4);
        insert accList;   
        
        List<CommunicationSubscriptionService.CommunicationNotificatioWrap> reqList = new List<CommunicationSubscriptionService.CommunicationNotificatioWrap>();
        
        CommunicationSubscriptionService.CommunicationNotificatioWrap req1 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req1.clientId = prospectList[0].Id;
        CommunicationSubscriptionService.CommunicationNotificatioWrap req2 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req2.clientEmail = 'test@test.com';
        CommunicationSubscriptionService.CommunicationNotificatioWrap req3 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req3.clientId = prospectList[1].Id;

        CommunicationSubscriptionService.CommunicationNotificatioWrap req4 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req4.clientId = accList[0].Id;
        CommunicationSubscriptionService.CommunicationNotificatioWrap req5 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req5.clientId = accList[2].Id;

        CommunicationSubscriptionService.CommunicationNotificatioWrap req6 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req6.clientId = 'testInvalidId';
        CommunicationSubscriptionService.CommunicationNotificatioWrap req7 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req7.clientEmail = 'testInvalidEmail';
        CommunicationSubscriptionService.CommunicationNotificatioWrap req8 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req8.clientId = '';
        CommunicationSubscriptionService.CommunicationNotificatioWrap req9 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req9.clientEmail = 'test1@test.com';
        CommunicationSubscriptionService.CommunicationNotificatioWrap req10 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req10.clientId = UserInfo.getUserId();
        CommunicationSubscriptionService.CommunicationNotificatioWrap req11 = new CommunicationSubscriptionService.CommunicationNotificatioWrap();
        req11.clientId = UserInfo.getUserId();

        reqList.add(req1);
        reqList.add(req2);
        reqList.add(req3);
        reqList.add(req4);
        reqList.add(req5);
        reqList.add(req6);
        reqList.add(req7);
        reqList.add(req8);
        reqList.add(req9);
        reqList.add(req10);
        reqList.add(req11);

        Test.startTest();

            RestRequest request = new RestRequest();
            request.requestUri ='https://test.salesforce.com/services/apexrest/v1/email/unsubscribe/';
            request.requestBody = Blob.valueOf(JSON.serialize(reqList));
            request.httpMethod = 'POST';
            RestContext.request = request;
            RestContext.response = new RestResponse();
            UnsubscribeFromCommunications.unsubscribe();

            reqList.remove(reqList.size() - 1);
            request.requestBody = Blob.valueOf(JSON.serialize(reqList));
            UnsubscribeFromCommunications.unsubscribe();
            
        Test.stopTest();
        
    }
}