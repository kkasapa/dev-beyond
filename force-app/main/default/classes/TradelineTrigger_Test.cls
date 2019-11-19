@isTest
public with sharing class TradelineTrigger_Test implements HttpCalloutMock {


    @testsetup
    public static void testDataCreation(){

        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType 
                                           WHERE sObjectType = 'Account' AND isPersonType = true 
                                               AND DeveloperName = 'Client' LIMIT 1];
        
        Account acc = TestRecordCreator.createAccount('Account1', accRecTypeList[0].Id);
        insert acc; 
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('GCS');
        insert processor;

        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, processor.Id);
        insert program;

        Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, program.Id);
        insert tradeLine;

        //custom settings for saving calc API
        Savings_Calculator_Microservice__c savingCalcSettings = new Savings_Calculator_Microservice__c();
        savingCalcSettings.Endpoint__c = 'https://beyondfinance.com/api/v1/savings';
        savingCalcSettings.InterestRate__c = 16.4;
        savingCalcSettings.Minimum_Payment__c = 2;
        insert savingCalcSettings;
    }

    Public static testmethod void calculateSavings_Test(){
        
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, program.Id);
        tradeLine.nu_dse__Current_Balance__c = 1500;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            insert tradeLine;
        Test.stopTest();

        nu_dse__TradeLine__c updatedTradeLine = [SELECT Savings_Months_to_Payoff__c, Savings_Payoff_Amount__c, 
                                                    Savings_Calculated_Savings__c
                                                FROM nu_dse__TradeLine__c WHERE Id = :tradeLine.Id LIMIT 1];

        system.assertEquals(18, updatedTradeLine.Savings_Months_to_Payoff__c);   
        system.assertEquals(1071.0, updatedTradeLine.Savings_Payoff_Amount__c);  
        system.assertEquals(271.0, updatedTradeLine.Savings_Calculated_Savings__c);                                      
    }

    Public static testmethod void calculateSavingsUpdate_Test(){
        
        nu_dse__TradeLine__c tradeLine = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            tradeLine.nu_dse__Current_Balance__c = 0;
            tradeLine.nu_dse__Original_Debt__c = 1500;
            update tradeline;
        Test.stopTest();

        nu_dse__TradeLine__c updatedTradeLine = [SELECT Savings_Months_to_Payoff__c, Savings_Payoff_Amount__c, 
                                                    Savings_Calculated_Savings__c
                                                FROM nu_dse__TradeLine__c LIMIT 1];

        system.assertEquals(18, updatedTradeLine.Savings_Months_to_Payoff__c);   
        system.assertEquals(1071.0, updatedTradeLine.Savings_Payoff_Amount__c);  
        system.assertEquals(271.0, updatedTradeLine.Savings_Calculated_Savings__c); 
    }

    Public static testmethod void calculateSavingsUpdateFail_Test(){
        
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, program.Id);
       
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            tradeLine.nu_dse__Current_Balance__c = -500;
            insert tradeLine;
        Test.stopTest();

        nu_dse__TradeLine__c updatedTradeLine = [SELECT Savings_Calc_Error__c
                                                FROM nu_dse__TradeLine__c WHERE Id = :tradeLine.Id LIMIT 1];

        system.assertEquals('Balance must be greater than 0', updatedTradeLine.Savings_Calc_Error__c);
    }

    Public static testmethod void calculateSavingsUpdateException_Test(){
        
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, program.Id);
       
        Test.startTest();

            Savings_Calculator_Microservice__c savingCalcSettings = [SELECT Id FROM Savings_Calculator_Microservice__c WHERE InterestRate__c = 16.4 LIMIT 1];
            savingCalcSettings.Endpoint__c = 'http://';
            savingCalcSettings.InterestRate__c = null;
            savingCalcSettings.Minimum_Payment__c = null;
            update savingCalcSettings;

            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            tradeLine.nu_dse__Current_Balance__c = 200;
            insert tradeLine;
        Test.stopTest();

        nu_dse__TradeLine__c updatedTradeLine = [SELECT Savings_Calc_Error__c
                                                FROM nu_dse__TradeLine__c WHERE Id = :tradeLine.Id LIMIT 1];

        system.assertEquals('System.CalloutException Unauthorized endpoint, please check Setup->Security->Remote site settings.',
                         updatedTradeLine.Savings_Calc_Error__c);
    }

    public HTTPResponse respond(HTTPRequest req) {

        String body = req.getBody();
        HTTPResponse resp = new HTTPResponse();

        if(req.getEndpoint().contains('savings') == true) {
            
            if(Integer.valueOf(body.substringBetween('"current_balance" : ', ',')) > 0) {

                resp.setStatus('OK');
                resp.setBody('{"data": {"id": "772285","type": "savings","links": {"self": "/api/v1/savings/772285"},"attributes": {"current-balance": 1000.0,"annual-interest-rate": "16.41","minimum-percentage-principle": "20.0","minimum-payment": 200.0,"total-savings": 271.0,"total-months": 18,"total-payments": 1071.0,"absolute-minimum-payment": 15.0}}}');
                
            } else {

                resp.setStatus('400');
                resp.setBody('Balance must be greater than 0');
                
            } 

        } else {

            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }
        return resp;
    }
}