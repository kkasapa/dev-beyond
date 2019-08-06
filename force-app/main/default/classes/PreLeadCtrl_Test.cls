@isTest
public class PreLeadCtrl_Test implements HttpCalloutMock {

    public static testmethod void testPreLeadCtrl(){
        
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                        
        insert preLeadSettingList;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PreLeadCtrl_Test());
        
        PreLeadCtrl preleadCtrlStr = new PreLeadCtrl();
        preleadCtrlStr.selectedPreLeadWrapperId = 17;
        preleadCtrlStr.firstname = 'Test';
        preleadCtrlStr.mailerIdValue = '17';
        preleadCtrlStr.lastName = 'test131testing';
        preleadCtrlStr.mailer_Id = '17';
        preleadCtrlStr.settings = preLeadSettingList[0];
        preleadCtrlStr.getPreLeads();
        preleadCtrlStr.showEditModal();
        
        preleadCtrlStr.pre_lead = preleadCtrlStr.pre_leads[0];
        preleadCtrlStr.preLeadWrapper.isQualified = True;
        preleadCtrlStr.preLeadWrapper.HasIncomeSource = True;
        
        preleadCtrlStr.postBack();
        preleadCtrlStr.Save();
        preleadCtrlStr.hideEditModal();
        Test.stopTest();   
        
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, nu_dse__First_Name__c, nu_dse__Last_name__c FROM nu_dse__Prospect__c];
        System.assertEquals(False, prospectList.isEmpty());  
        System.assertEquals('test131testing', prospectList[0].nu_dse__Last_name__c);  
        System.assertEquals('test', prospectList[0].nu_dse__First_Name__c);  
        
    }
    public static HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"@odata.context":"http://uat.beyondfinance.com/odata/$metadata#PreLead","value":[{"Id":17,"MailerId":"17","MailDate":"2001-01-03T00:00:00Z","ExpirationDate":null,"InsertDate":"2001-01-03T00:00:00Z","FirstName":"test","MiddleName":"","LastName":"test131testing","Address1":"123 main st","Address2":"banana unit 2","City":"Gilbert","State":"AZ","Zip":"85296","EmailAddress":"test@test.com","PhoneNumber":"(949) 555-1234","UnsecuredDebtAmount":59000.00,"BestTimeToCall":"Morning","PardotId":"10860521","StateQualification":"pass","DebtAmountQualification":"pass","MetaData":"Test","PersonalizedUrl":null,"AffiliateId":null,"UTMCampaign":null,"UTMId":null,"UTMSource":null,"UTMMedium":null,"UTMContent":null,"UTMTerm":null,"OptimizelyExperimentID":null,"OptimizelyVariationID":null,"OptimizelyVariationName":null,"LandingPage":null}]}');
        res.setStatusCode(122);
        res.setStatus('OK');
        return res;  
    }
}