@isTest
public class ProgramViewExtTest {
    static testmethod void ProgramView(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'); 
        
       
        Account accObj = new Account();
        accObj.name = 'test ';
        insert accObj;
        
        nu_dse__Program__c pgm= new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accObj.id;
        insert pgm;
        
        nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = pgm.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        trd.nu_dse__Original_Account_Number__c='97786756497';
        insert trd;
        
        nu_dse__Offer__c ofr= new nu_dse__Offer__c();
        ofr.nu_dse__TradeLine__c = trd.id; 
        ofr.nu_dse__Program__c = pgm.id;
        insert ofr;
        
        nu_dse__Payment__c payment= new nu_dse__Payment__c();
        payment.nu_dse__Program__c = pgm.id;
        try{insert payment;}catch(exception e){}
        
        
     
        Test.setCurrentPageReference(new PageReference('Page.ProgramView')); 
        System.currentPageReference().getParameters().put('id', accObj.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(accObj);
        ProgramViewExt newProgramView = new ProgramViewExt(sc);

    }

}