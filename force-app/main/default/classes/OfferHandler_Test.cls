@istest
public class OfferHandler_Test {

    @testsetup
    public static void testDataSetup(){
        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND isPersonType = true and DeveloperName = 'Client' LIMIT 1];
        
        Account acc = new Account(firstName = 'Test', lastname = 'IDR', Phone = '6784567890', personemail = 'test@idr.com', Preferred_Payment_Method__c = 'PHONE',
                                  recordTypeId = accRecTypeList[0].id);
        insert acc; 
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c> {
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 1, Last_Call_Recording__c = 'Test NSF Record'),
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 2, Last_Call_Recording__c = 'Test NSF Record'),
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 3, Last_Call_Recording__c = 'Test NSF Record')
        };
        insert programList; 

        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, programList[0].Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(programList[0].Id, tradeLine.Id, 100, 10, 25, 10);
        insert offer;

        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        List<nu_dse__Offer__c> offerList = [SELECT Id FROM nu_dse__Offer__c LIMIT 1];
        nu_dse__Program__c Program = [SELECT Id, nu_dse__In_Settlement__c FROM nu_dse__Program__c LIMIT 1];
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c> {
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today(), 
                                   nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, 
                                   nu_dse__Program__c = programList[0].id, 
                                   RecordTypeId = settlementRecordTypeId, 
                                   nu_dse__Transaction_Status__c = 'Failed', 
                                   Verbal_Authorization_Received__c = true, 
                                   nu_dse__Offer__c = offerList[0].Id),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addMonths(2), 
                                   nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, 
                                   nu_dse__Program__c = programList[0].id, 
                                   RecordTypeId = settlementRecordTypeId, 
                                   nu_dse__Transaction_Status__c = 'Failed', 
                                   Verbal_Authorization_Received__c = true, 
                                   nu_dse__Offer__c = offerList[0].Id),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addMonths(3), 
                                   nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, 
                                   nu_dse__Program__c = programList[0].id, 
                                   RecordTypeId = settlementRecordTypeId, 
                                   nu_dse__Transaction_Status__c = 'Failed', 
                                   Verbal_Authorization_Received__c = true, 
                                   nu_dse__Offer__c = offerList[0].Id),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addMonths(4), 
                                   nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, 
                                   nu_dse__Program__c = programList[0].id, 
                                   RecordTypeId = settlementRecordTypeId, 
                                   nu_dse__Transaction_Status__c = 'Failed', 
                                   Verbal_Authorization_Received__c = true, 
                                   nu_dse__Offer__c = offerList[0].Id)
        };
        insert paymentList;                                                         

    }

    
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

    static testMethod void testpaymentDeletionOnCancelingOffer() {
        Test.startTest();
        List<nu_dse__Offer__c > offerList = new List<nu_dse__Offer__c >();
        for (nu_dse__Offer__c offer: [SELECT Id FROM nu_dse__Offer__c LIMIT 1]) {
            offer.nu_dse__Status__c = '01-Offer Canceled by Negotiator';
            offerList.add(offer);
        }
        update offerList;
        Test.stopTest();

        List<nu_dse__Payment__c> paymentList = [SELECT Id FROM nu_dse__Payment__c WHERE nu_dse__Offer__c IN :offerList];
        System.assert(paymentList.isEmpty() == true);

    }
}