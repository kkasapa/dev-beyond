@isTest
public class OfferPaymentMethodUpdateController_Test {
    /*public OfferPaymentMethodUpdateController_Test() {

    }*/

    @TestSetup
    static void makeData(){
        Id clientAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Id settlmntPaymentRectypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        
        Account acc = TestRecordCreator.createAccount('Test', clientAccountRecId);
        insert acc;
        nu_dse__Processor__c processor =  TestRecordCreator.createProcessor('CFT_TEST');
        insert processor;
        List<nu_dse__Ancillary_Fee__c> ancillaryFees = new List<nu_dse__Ancillary_Fee__c>();
        nu_dse__Ancillary_Fee__c wireFee = new nu_dse__Ancillary_Fee__c(Name = 'WIRE',
                                                                                nu_dse__Developer_Name__c = 'WIRE',
                                                                                nu_dse__Transaction_Method_Name__c = 'WIRE', 
                                                                                nu_dse__Transaction_Method_API_Name__c = 'WIRE',
                                                                                nu_dse__Processor__c = processor.Id);
        nu_dse__Ancillary_Fee__c p_achFee = new nu_dse__Ancillary_Fee__c(Name = 'P_ACH',
                                                                                nu_dse__Developer_Name__c = 'P_ACH',
                                                                                nu_dse__Transaction_Method_Name__c = 'P_ACH', 
                                                                                nu_dse__Transaction_Method_API_Name__c = 'P_ACH',
                                                                                nu_dse__Processor__c = processor.Id);
        ancillaryFees.add(wireFee);
        ancillaryFees.add(p_achFee);
        insert ancillaryFees;
        nu_dse__Program__c prog = TestRecordCreator.createProgram(acc.Id, processor.Id);  
        insert prog;
        nu_dse__Tradeline__c tradeline = TestRecordCreator.createTradeLine(null, prog.Id);
        insert tradeline;
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(prog.Id, tradeline.Id, 1000, 250, 5, 5);
        insert offer;
        nu_dse__Payment__c settlementPayment = TestRecordCreator.createPayment(prog.Id, 'Tentative', 'Withdrawal', settlmntPaymentRectypeId , offer.Id);
        settlementPayment.nu_dse__Transaction_Method__c = 'P_ACH';
        insert settlementPayment;
    }

    @isTest
    public static void testGetPageData() {
        Test.startTest();
        //System.runAs(UserInfo.getUserId()){
        //}
        nu_dse__Offer__c offer = [SELECT Id, Name FROM nu_dse__Offer__c LIMIT 1];
        OfferPaymentMethodUpdateController.getPageData(offer.Id);
        Test.stopTest();
    }

    @isTest
    public static void testGetPageData_null() {
        Test.startTest();
        //System.runAs(UserInfo.getUserId()){
        //}
        nu_dse__Offer__c offer = [SELECT Id, Name FROM nu_dse__Offer__c LIMIT 1];
        OfferPaymentMethodUpdateController.getPageData(null);
        Test.stopTest();
    }

    @isTest
    public static void testUpdatePaymentTransactionMethod() {
        Test.startTest();
        //System.runAs(UserInfo.getUserId()){
        //}
        List<nu_dse__Payment__c> payments = [SELECT Id, Name, nu_dse__Transaction_Status__c, nu_dse__Transaction_Method__c,
                                        nu_dse__Payment_Type__c, nu_dse__Schedule_Date__c, nu_dse__Amount__c,
                                        nu_dse__Offer__c FROM nu_dse__Payment__c];
        
        System.assertEquals('P_ACH', payments[0].nu_dse__Transaction_Method__c);

        payments[0].nu_dse__Transaction_Method__c = 'WIRE';
        OfferPaymentMethodUpdateController.updatePaymentTransactionMethod(JSON.serialize(payments));

        List<nu_dse__Payment__c> updatedPayments = [SELECT Id, Name, nu_dse__Transaction_Status__c, nu_dse__Transaction_Method__c,
                                nu_dse__Payment_Type__c, nu_dse__Schedule_Date__c, nu_dse__Amount__c,
                                nu_dse__Offer__c FROM nu_dse__Payment__c];

        System.assertEquals('WIRE', updatedPayments[0].nu_dse__Transaction_Method__c);
        Test.stopTest();
    }

    @isTest
    public static void testUpdatePaymentTransactionMethod_Fail() {
        Test.startTest();
        //System.runAs(UserInfo.getUserId()){
        //}
        List<nu_dse__Payment__c> payments = [SELECT Id, Name, nu_dse__Transaction_Status__c, nu_dse__Transaction_Method__c,
                                        nu_dse__Payment_Type__c, nu_dse__Schedule_Date__c, nu_dse__Amount__c,
                                        nu_dse__Offer__c FROM nu_dse__Payment__c];
        
        System.assertEquals('P_ACH', payments[0].nu_dse__Transaction_Method__c);

        payments[0].nu_dse__Transaction_Method__c = 'TESTPAY';
        try {
            OfferPaymentMethodUpdateController.updatePaymentTransactionMethod(JSON.serialize(payments));
        } catch(Exception e) {
            System.assert(String.isNotBlank(e.getMessage()));
        }
        Test.stopTest();
    }
}