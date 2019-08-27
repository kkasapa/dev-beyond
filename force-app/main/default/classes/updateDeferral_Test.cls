@isTest
private class updateDeferral_Test 
{
    static testMethod void validateUpdateDeferral()
    {
        nu_dse__Program__c prog = new nu_dse__Program__c();
        prog.Enrolled_Date__c = Date.newInstance(2019, 08, 5);
        prog.Fee_Deferral__c = true;
        insert prog;
        updateDeferral test = new updateDeferral();
    
    }
}