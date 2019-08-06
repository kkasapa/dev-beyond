@isTest
public class PreLeadController_Test2 implements HttpCalloutMock {

    public static testmethod void testCallout(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                        
        insert preLeadSettingList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        preLeadController preLead = new preLeadController(); 
        preLead.mailerId = '1';
        preLead.callout();
        
        preLeadController preLead2 = new preLeadController(); 
        preLead2.mailerId = '2';
        preLead2.callout();
        
        Test.stopTest();   
        // Created on 20th Jun 2017 
        System.assertEquals('John123' , preLead.preLeadWrapper.FirstName);
    }
    
    public static testmethod void testLeadMG(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                    
        insert preLeadSettingList;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        preLeadController preLead = new preLeadController(); 
        preLead.preLeadWrapper.FirstName = 'Test';
        preLead.preLeadWrapper.LastName = 'LastName';
        preLead.preLeadWrapper.Address1 = 'Address1';
        preLead.preLeadWrapper.Address2 = 'Address2';
        preLead.preLeadWrapper.EmailAddress = 'a@test.com';
        preLead.preLeadWrapper.PhoneNumber = '7271341234';
        preLead.preLeadWrapper.HasIncomeSource = true; 
        preLead.preLeadWrapper.BestTimeToCall = 'Evening';
        preLead.preLeadWrapper.UnsecuredDebtAmount = 10000.00;
        preLead.preLeadWrapper.MailerId = '1';
        preLead.leadMG(); 
        
        Test.stopTest();
        
        List<nu_dse__Prospect__c> prospectList = [SELECT Id FROM nu_dse__Prospect__c];
        
        System.assertEquals(1, prospectList.size());
    
    }
    
    public static testmethod void testPostCallback(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                    
        insert preLeadSettingList;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        preLeadController preLead = new preLeadController(); 
        preLead.preLeadWrapper.FirstName = 'Test';
        preLead.preLeadWrapper.LastName = 'LastName';
        preLead.preLeadWrapper.MiddleName = 'm';
        preLead.preLeadWrapper.Address1 = 'Address1';
        preLead.preLeadWrapper.Address2 = 'Address2';
        preLead.preLeadWrapper.City = 'city'; 
        preLead.preLeadWrapper.State='state';
        preLead.preLeadWrapper.zip='56764';
        preLead.preLeadWrapper.PardotId = '123';
        preLead.preLeadWrapper.EmailAddress = 'a@test.com';
        preLead.preLeadWrapper.PhoneNumber = '7271341234';
        preLead.preLeadWrapper.HasIncomeSource = true; 
        preLead.preLeadWrapper.BestTimeToCall = 'Evening';
        preLead.preLeadWrapper.UnsecuredDebtAmount = 10000.00;
        preLead.preLeadWrapper.StateQualification = '100';
        preLead.preLeadWrapper.DebtAmountQualification = '10000'; 
        preLead.preLeadWrapper.MetaData = 'http://uat.beyondfinance.com/odata/$metadata#PreLead/$entity';
        preLead.preLeadWrapper.MailerId = '1';
        preLead.preLeadWrapper.MailDate = System.Date.today(); 
        preLead.preLeadWrapper.ExpirationDate = System.Date.today().addDays(1);
        preLead.preLeadWrapper.InsertDate = System.Date.today(); 
        
        // Created on 20th Jun 2017 
        preLead.genLead = False;
        preLead.postBack();
        
        Test.stopTest();
        
        // Created on 20th Jun 2017 
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, nu_dse__First_Name__c FROM nu_dse__Prospect__c];
        System.assertEquals(0 , prospectList.size());
    }
    
    // Created on 20th Jun 2017 
    public static testmethod void testPreLeadCallout(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                    
        insert preLeadSettingList;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        preLeadController preLead = new preLeadController(); 
        preLead.mailerId = '1';
        preLead.preLeadWrapper.Id = 12345;
        preLead.preLeadWrapper.MailerId = '2';
        preLead.preLeadWrapper.FirstName = 'Test';
        preLead.preLeadWrapper.LastName = 'LastName';
        preLead.preLeadWrapper.MiddleName = 'm';
        preLead.preLeadWrapper.Address1 = 'Address1';
        preLead.preLeadWrapper.Address2 = 'Address2';
        preLead.preLeadWrapper.City = 'city'; 
        preLead.preLeadWrapper.State='state';
        preLead.preLeadWrapper.zip='56764';
        preLead.preLeadWrapper.PardotId = '123';
        preLead.preLeadWrapper.EmailAddress = 'a@test.com';
        preLead.preLeadWrapper.PhoneNumber = '7271341234';
        preLead.preLeadWrapper.HasIncomeSource = true; 
        preLead.preLeadWrapper.BestTimeToCall = 'Evening';
        preLead.preLeadWrapper.UnsecuredDebtAmount = 10000.00;
        preLead.preLeadWrapper.StateQualification = '100';
        preLead.preLeadWrapper.DebtAmountQualification = '10000'; 
        preLead.preLeadWrapper.MetaData = 'http://uat.beyondfinance.com/odata/$metadata#PreLead/$entity';
        preLead.preLeadWrapper.MailDate = System.Date.today(); 
        preLead.preLeadWrapper.ExpirationDate = System.Date.today().addDays(1);
        preLead.preLeadWrapper.InsertDate = System.Date.today(); 
        preLead.genLead = TRUE;
        preLead.postBack();
        
        Test.stopTest();
        
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, nu_dse__First_Name__c FROM nu_dse__Prospect__c];
        System.assertEquals( False , prospectList.isEmpty());
        
    }
    
    // Created on 20th Jun 2017 
    public static testmethod void testPreLeadCallout_Failure(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                    
        insert preLeadSettingList;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new PreLeadController_Test2());
        
        preLeadController preLead = new preLeadController(); 
        preLead.preLeadWrapper.Id = 123;
        
        preLead.postBack();
        preLead.mailerId = '1';
        preLead.callout();
        
        Test.stopTest();
        
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, nu_dse__First_Name__c FROM nu_dse__Prospect__c];
        System.assertEquals( True , prospectList.isEmpty());
        
    }
    
    // Created on 20th Jun 2017 
    public static testmethod void testCallout_Failure(){
    
        List<PreLeadSettigs__c> preLeadSettingList = new List<PreLeadSettigs__c>{ 
                                                     new PreLeadSettigs__c(EndPointURL__c = 'http://uat.beyondfinance.com/odata/PreLead',
                                                                            UserName__c = 'SalesforceUser',
                                                                            Password__c = '33rs3pJHKW8J3DuU')};
                                                    
        insert preLeadSettingList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PreLeadController_Test2());
        
        preLeadController preLead = new preLeadController(); 
        preLead.mailerId = '1';
        preLead.callout();
        
        preLeadController preLead2 = new preLeadController(); 
        preLead2.mailerId = '2';
        preLead2.callout();
        
        Test.stopTest();   
        System.assertEquals(null , preLead.preLeadWrapper.FirstName);     
    }
    
    // Created on 20th Jun 2017 
    public static HTTPResponse respond(HTTPRequest req) {
                
        preLeadController.InnerErrorClass data2 = new preLeadController.InnerErrorClass();
        data2.message = 'Test Error';
        data2.type = 'Test';
        
        preLeadController.ErrorClass data1 = new preLeadController.ErrorClass();
        data1.code = '123';
        data1.message = 'Test Error';
        data1.innerError = data2;
        
        preLeadController.PostCallError data = new preLeadController.PostCallError();
        data.error = data1;
        
        if(req.getBody().containsIgnoreCase('MailerId=1')){
        
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(data));
            res.setStatusCode(123);
            return res;
        }else{
        
            HttpResponse res2 = new HttpResponse();
            res2.setHeader('Content-Type', 'application/json');
            res2.setBody(JSON.serialize(data));
            res2.setStatusCode(123);
            return res2;  
        }
    }
}