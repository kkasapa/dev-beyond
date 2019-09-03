@istest
public class OfferHandler_Test {
    
    static testMethod void validateSavingsCalc()
    {
        nu_dse__TradeLine__c testtl = new nu_dse__TradeLine__c();
        testtl.nu_dse__Original_Debt__c = 10000;
        testtl.Verified_Balance2__c = 9000;
        testtl.Call_Recording__c = 'Test Tradeline';
        testtl.nu_dse__Original_Account_Number__c = '123456789';
        insert testtl;
        //testtl = [SELECT ID, Verified_Balance2__c, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c from nu_dse__TradeLine__c wHERE Call_Recording__c = 'Test Tradeline'];
        nu_dse__Offer__c testo = new nu_dse__Offer__c();
        testo.nu_dse__TradeLine__c = testtl.Id;
        System.debug(testtl.ID);
        testo.Savings_Calculation__c = 0;
        testo.Update_Savings_Calc__c = false;
        insert testo;
        testtl.Verified_Balance2__c = 20000;
        testtl.nu_dse__Original_Debt__c = 20000;
        update testtl;

    }
}