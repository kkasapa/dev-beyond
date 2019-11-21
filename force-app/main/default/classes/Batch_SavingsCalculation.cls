/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch for running savings calculation for specific records(Supports onlt for Program and Tradeline)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-11-20
* @modified       2019-11-20
* @logic           
* @description    Batch for running savings calculation for specific records(Supports onlt for Program and Tradeline)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class Batch_SavingsCalculation implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public Set<Id> recordIds;
    public String sObjectType;
    PaymentsCalcService.SavingCalcSettings savingCalcSetting;

    public Batch_SavingsCalculation(String sObjectTypeParam) {

        if (String.isNotBlank(sObjectTypeParam) 
            && (sObjectTypeParam == 'nu_dse__Program__c' 
                || sObjectTypeParam == 'nu_dse__Tradeline__c')) {
            sObjectType = sObjectTypeParam;
        } else {
            throw new CustomException('sObjectTypeParam must have valid sObjectType.Supported types: nu_dse__Program__c, nu_dse__Tradeline__c');
        }

        savingCalcSetting = PaymentsCalcService.getSavingCalcSettings();
    }

    public Batch_SavingsCalculation(String sObjectTypeParam, Set<Id> recordIdsParam) {

        if (recordIdsParam.isEmpty() == false) {
            recordIds = recordIdsParam;
        } else {
            throw new CustomException('recordIdsParam must have valid Ids');
        }

        if (String.isNotBlank(sObjectTypeParam) 
            && (sObjectTypeParam == 'nu_dse__Program__c' 
                || sObjectTypeParam == 'nu_dse__Tradeline__c')) {
            sObjectType = sObjectTypeParam;
        } else {
            throw new CustomException('sObjectTypeParam must have valid sObjectType.Supported types: nu_dse__Program__c, nu_dse__Tradeline__c');
        }

        savingCalcSetting = PaymentsCalcService.getSavingCalcSettings();
        
        if(savingCalcSetting == null) {
            throw new CustomException('Savings Calculator API configurations unavailable.');
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        String queryString = '';
       
        if (sObjectType == 'nu_dse__Program__c') {
            queryString = 'SELECT Id, Original_Enrolled_Program_Debt__c FROM nu_dse__Program__c ';

            if (recordIds.isEmpty() == false) {
                queryString += ' WHERE Id IN :recordIds';
            } else {
                queryString += ' WHERE Savings_Months_to_Payoff_Original__c = 0 '+
                                        ' OR Savings_Months_to_Payoff_Original__c = null '+
                                        ' OR Savings_Payoff_Amount_Original__c = 0'+
                                        ' OR Savings_Payoff_Amount_Original__c = null'+
                                        ' OR Savings_Calculated_Savings_Original__c = 0'+
                                        ' OR Savings_Calculated_Savings_Original__c = null';
            }
        } else if(sObjectType == 'nu_dse__Tradeline__c'){
            queryString = 'SELECT Id, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c FROM nu_dse__Tradeline__c ';

            if (recordIds.isEmpty() == false) {
                queryString += ' WHERE Id IN :recordIds';
            } else {
                queryString += ' WHERE Savings_Months_to_Payoff__c = 0 '+
                                        ' OR Savings_Months_to_Payoff__c = null '+
                                        ' OR Savings_Payoff_Amount__c = 0'+
                                        ' OR Savings_Payoff_Amount__c = null'+
                                        ' OR Savings_Calculated_Savings__c = 0'+
                                        ' OR Savings_Calculated_Savings__c = null';
            }
        }
        
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>();
        List<nu_dse__Tradeline__c> tradelines = new List<nu_dse__Tradeline__c>();
        
        /*Savings_Calculator_Microservice__c savingCalcSettings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());
        String endpoint;
        Double interestRate;
        Decimal minimumPaymentPercent;
        
        List<nu_dse__Program__c> programsToUpdateList = new List<nu_dse__Program__c>(); 

        if (savingCalcSettings != null) {
            if (String.isNotBlank(savingCalcSettings.Endpoint__c) ) {
                endpoint = savingCalcSettings.Endpoint__c;
            } else {
                 endpoint = 'https://beyondfinance.com/api/v1/savings';
            }
            if (savingCalcSettings.InterestRate__c != null && savingCalcSettings.InterestRate__c > 0) {
                interestRate = savingCalcSettings.InterestRate__c;
            } else {
                interestRate = 16.4;  
            }
            if (savingCalcSettings.Minimum_Payment__c != null && savingCalcSettings.Minimum_Payment__c > 0) {
                minimumPaymentPercent = savingCalcSettings.Minimum_Payment__c/100;
            } else {
                minimumPaymentPercent = 0.02;
            }
        }*/

        for (sObject sObj: scope) {
            Double debt = 0; 
            if (sObjectType == 'nu_dse__Program__c') {

                nu_dse__Program__c program = (nu_dse__Program__c)sObj;
                
                if(program.Original_Enrolled_Program_Debt__c != null && program.Original_Enrolled_Program_Debt__c > 0) {
                    debt = program.Original_Enrolled_Program_Debt__c;
                }
                
                nu_dse__Program__c programToUpdate = (nu_dse__Program__c)PaymentsCalcService.savingsCalculatorExternalService(
                                                                        savingCalcSetting, debt, 'nu_dse__Program__c');
                programToUpdate.Id = program.Id;
                programs.add(programToUpdate);

            } else if(sObjectType == 'nu_dse__Tradeline__c'){
                nu_dse__Tradeline__c tradeline = (nu_dse__Tradeline__c)sObj;

                if((tradeline.nu_dse__Current_Balance__c == 0
                    || tradeline.nu_dse__Current_Balance__c == null)
                    && tradeline.nu_dse__Original_Debt__c != null) {

                    debt = tradeline.nu_dse__Original_Debt__c;

                } else if(tradeline.nu_dse__Current_Balance__c != null) {

                    debt = tradeline.nu_dse__Current_Balance__c;
                }
                
                nu_dse__TradeLine__c tradelineToUpdate = (nu_dse__Tradeline__c)PaymentsCalcService.savingsCalculatorExternalService(
                                                                                    savingCalcSetting, debt, 'nu_dse__Tradeline__c');
                tradelineToUpdate.Id = tradeline.Id;
                tradelines.add(tradelineToUpdate);
            }
        }
        update programs;
        update Tradelines;
    }

    public void finish(Database.BatchableContext BC) {

    }
}