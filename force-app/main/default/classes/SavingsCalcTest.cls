@istest
public class SavingsCalcTest {
    
    static testMethod void validateSavingsCalc()
    {
        nu_dse__TradeLine__c testtl = new nu_dse__TradeLine__c();
        testtl.nu_dse__Original_Debt__c = 10000;
        testtl.Verified_Balance2__c = 9000;
        testtl.Call_Recording__c = 'Test Tradeline';
        testtl.nu_dse__Original_Account_Number__c = '123456789';
        insert testtl;
        testtl = [SELECT ID, Verified_Balance2__c, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c from nu_dse__TradeLine__c wHERE Call_Recording__c = 'Test Tradeline'];
        nu_dse__Offer__c testo = new nu_dse__Offer__c();
        testo.nu_dse__TradeLine__c = testtl.ID;
        System.debug(testtl.ID);
        insert testo;
        testtl.Verified_Balance2__c = 20000;
        testtl.nu_dse__Original_Debt__c = 20000;
        //testtl.nu_dse__Current_Balance__c = 15000;
        update testtl;
        nu_dse__Program__c testpr = new nu_dse__Program__c();
        testpr.Prospect_Name__c = 'Test Program';
        insert testpr;
        testpr = [SELECT ID from nu_dse__Program__c WHERE Prospect_Name__c = 'Test Program'];
        testo.nu_dse__Status__c = 'Accepted';
        testo.nu_dse__Program__c = testpr.ID;
        testo.Bad_Debt__c = true;
        testo.First_Settlement_Date__c = '200';
       	nu_dse__Offer__c testo2 = new nu_dse__Offer__c();
        testo2.nu_dse__TradeLine__c = testtl.ID;
        testo2.nu_dse__Program__c = testpr.ID;
        testo2.First_Settlement_Date__c = '100';
        update testo;
        insert testo2;

    }
}