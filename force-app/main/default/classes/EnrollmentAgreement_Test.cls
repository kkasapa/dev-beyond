@isTest
public class EnrollmentAgreement_Test
{
    public static testMethod void testEaSnap()
    {
        //Create test variables
        List<nu_dse__TradeLine__c> insertables = new List<nu_dse__TradeLine__c>();
       	nu_dse__Prospect__c testp = new nu_dse__Prospect__c();
        nu_dse__TradeLine__c testTL = new nu_dse__TradeLine__c();
        nu_dse__TradeLine__c testTL2 = new nu_dse__TradeLine__c();
        nu_dse__TradeLine__c testTL3 = new nu_dse__TradeLine__c();
        
        //Initiate test Prospect and get ID.
    	testp.nu_dse__First_Name__c = 'Test Prospect';
    	testp.nu_dse__Last_Name__c = 'Test Enrollement Agreement Trigger';  
        insert testp;
        
        //Initiate test tradelines and insert
        testTL.nu_dse__Prospect__c = testp.Id;
        testTL.nu_dse__Original_Debt__c = 10000;
        testTL.nu_dse__Original_Account_Number__c = '12345';
        insertables.add(testTL);
        testTL2.nu_dse__Prospect__c = testp.Id;
        testTL2.nu_dse__Original_Debt__c = 20000;
        testTL2.nu_dse__Original_Account_Number__c = '678910';
        insertables.add(testTL2);
        testTL3.nu_dse__Prospect__c = testp.Id;
        testTL3.nu_dse__Original_Debt__c = 30000;
        testTL3.nu_dse__Original_Account_Number__c = '1112131415';
        insertables.add(testTL3);
        insert insertables;
        
        //Create EnrollmentAgreementDetails object and ensure data is populated
        Enrolled_Agreement_Details__c eaTest = new Enrolled_Agreement_Details__c();
        eaTest.Prospect_Lookup__c = testp.Id;
        insert eaTest;
        
        
    }    
}