@isTest
public with sharing class Batch_SavingsCalculation_Test {
    
    //setting up data for running tests
    @testSetup static void dataCreator() {
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

        Account clientAccount = TestRecordCreator.createAccount('clientAcc', accRecordTypeId);
        insert clientAccount;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Type__c = 'CFT';
        insert processor;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        program.Original_Enrolled_Program_Debt__c = 1500;
        insert program;
        
        nu_dse__Program__c program2 = TestRecordCreator.createProgram(clientAccount.Id, processor.Id);
        program.Original_Enrolled_Program_Debt__c = 100;
        insert program2;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        tradeLine.nu_dse__Current_Balance__c = 1500;
        insert tradeLine;
        
        nu_dse__TradeLine__c tradeLine2 = TestRecordCreator.createTradeLine(clientAccount.id, program.Id);
        tradeLine2.nu_dse__Current_Balance__c = 100;
        insert tradeLine2;
    }
    
    Public static testmethod void calculateSavingsTradelineWF_Test(){
        
        nu_dse__TradeLine__c tradeLine = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];
        
        Test.startTest();
            Database.executeBatch(new Batch_SavingsCalculation('nu_dse__Tradeline__c', new Set<Id>{tradeLine.Id}));
        Test.stopTest();

        nu_dse__TradeLine__c updatedTradeLine = [SELECT Savings_Months_to_Payoff__c, Savings_Payoff_Amount__c, 
                                                    Savings_Calculated_Savings__c,nu_dse__Include_In_The_Program__c,nu_dse__Prospect__r.Accepted_Quote_Count__c
                                                FROM nu_dse__TradeLine__c LIMIT 1];

        system.assertEquals(18, updatedTradeLine.Savings_Months_to_Payoff__c);   
        system.assertEquals(1071.0, updatedTradeLine.Savings_Payoff_Amount__c);  
        system.assertEquals(271.0, updatedTradeLine.Savings_Calculated_Savings__c);                                      
    }
    
    Public static testmethod void calculateSavingsTradeline_Test(){
        
        Test.startTest();
            Database.executeBatch(new Batch_SavingsCalculation('nu_dse__Tradeline__c'));
        Test.stopTest();

        List<nu_dse__TradeLine__c> updatedTradeLine = [SELECT Savings_Months_to_Payoff__c, Savings_Payoff_Amount__c, 
                                                    Savings_Calculated_Savings__c, Savings_Calc_Error__c,nu_dse__Include_In_The_Program__c,nu_dse__Prospect__r.Accepted_Quote_Count__c
                                                FROM nu_dse__TradeLine__c LIMIT 2];

        system.assertEquals(18, updatedTradeLine[0].Savings_Months_to_Payoff__c);   
        system.assertEquals(1071.0, updatedTradeLine[0].Savings_Payoff_Amount__c);  
        system.assertEquals(271.0, updatedTradeLine[0].Savings_Calculated_Savings__c);  
        system.assertEquals('Balance must be greater than 0', updatedTradeLine[1].Savings_Calc_Error__c);                                  
    }
    
    Public static testmethod void calculateSavingsProgram_Test(){
        
        Test.startTest();
            
            Savings_Calculator_Microservice__c savingCalcSettings = new Savings_Calculator_Microservice__c();
            savingCalcSettings.Endpoint__c = 'https://beyondfinance.com/api/v1/savings';
            savingCalcSettings.InterestRate__c = 16.4;
            savingCalcSettings.Minimum_Payment__c = 2;
            insert savingCalcSettings;

            Database.executeBatch(new Batch_SavingsCalculation('nu_dse__Program__c'));
            
        Test.stopTest();

        List<nu_dse__Program__c> updatedProgram = [SELECT Savings_Calculated_Savings_Original__c, Savings_Months_to_Payoff_Original__c,
                                                Savings_Payoff_Amount_Original__c, Savings_Calculation_Error_Original__c,Prospect_Lookup__r.Accepted_Quote_Count__c
                                            FROM nu_dse__Program__c LIMIT 2];

        system.assertEquals(18, updatedProgram[0].Savings_Months_to_Payoff_Original__c);   
        system.assertEquals(1071.0, updatedProgram[0].Savings_Payoff_Amount_Original__c);  
        system.assertEquals(271.0, updatedProgram[0].Savings_Calculated_Savings_Original__c); 
        //system.assertEquals('Balance must be greater than 0', updatedProgram[1].Savings_Calculation_Error_Original__c);
    }   
    
    Public static testmethod void calculateSavingsProgramWF_Test(){
        
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Test.startTest();
            Database.executeBatch(new Batch_SavingsCalculation('nu_dse__Program__c', new Set<Id>{program.Id}));
        Test.stopTest();

        List<nu_dse__Program__c> updatedProgram = [SELECT Savings_Calculated_Savings_Original__c, Savings_Months_to_Payoff_Original__c,
                                                Savings_Payoff_Amount_Original__c,Prospect_Lookup__r.Accepted_Quote_Count__c
                                            FROM nu_dse__Program__c LIMIT 1];

        system.assertEquals(18, updatedProgram[0].Savings_Months_to_Payoff_Original__c);   
        system.assertEquals(1071.0, updatedProgram[0].Savings_Payoff_Amount_Original__c);  
        system.assertEquals(271.0, updatedProgram[0].Savings_Calculated_Savings_Original__c);                                      
    }
    
    Public static testmethod void calculateSavingsFail_Test(){
        
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Test.startTest();
            try {
                Database.executeBatch(new Batch_SavingsCalculation(''));
            } catch (exception e) {
                system.assert(e.getMessage().contains('sObjectTypeParam must have valid sObjectType.Supported types: nu_dse__Program__c, nu_dse__Tradeline__c'));
            }
            try {
                Database.executeBatch(new Batch_SavingsCalculation('', new Set<Id>{program.Id}));
            } catch (exception e) {
                system.assert(e.getMessage().contains('sObjectTypeParam must have valid sObjectType.Supported types: nu_dse__Program__c, nu_dse__Tradeline__c'));
            }
            try {
                Database.executeBatch(new Batch_SavingsCalculation('nu_dse__Program__c', new Set<Id>()));
            } catch (exception e) {
                system.assert(e.getMessage().contains('recordIdsParam must have valid Ids'));
            }
        Test.stopTest();                                     
    }
}