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
    Set<String> programStatusInclusionSet = new Set<String>();// Set of Program status excludes in payment query

    public Batch_SavingsCalculation(String sObjectTypeParam) {

        if (String.isNotBlank(sObjectTypeParam) 
            && (sObjectTypeParam == 'nu_dse__Program__c' 
                || sObjectTypeParam == 'nu_dse__Tradeline__c')) {
            sObjectType = sObjectTypeParam;
        } else {
            throw new CustomException('sObjectTypeParam must have valid sObjectType.Supported types: nu_dse__Program__c, nu_dse__Tradeline__c');
        }
        //getting saving calc API configurations
        savingCalcSetting = PaymentsCalcService.getSavingCalcSettings();
        getProgramExclusionStatus();
    }

    public Batch_SavingsCalculation(String sObjectTypeParam, Set<Id> recordIdsParam) {

        if (recordIdsParam != null && recordIdsParam.isEmpty() == false) {
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
        getProgramExclusionStatus();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        String queryString = '';
       
        if (sObjectType == 'nu_dse__Program__c') { //building query for Program 
            queryString = 'SELECT Id, Original_Enrolled_Program_Debt__c FROM nu_dse__Program__c ';

            if (recordIds != null && recordIds.isEmpty() == false) { // with set of record Ids
                queryString += ' WHERE Id IN :recordIds';
            } else { // for all programs without saving calc values
                queryString += ' WHERE (Savings_Months_to_Payoff_Original__c = 0 '+
                                        ' OR Savings_Months_to_Payoff_Original__c = null '+
                                        ' OR Savings_Payoff_Amount_Original__c = 0'+
                                        ' OR Savings_Payoff_Amount_Original__c = null'+
                                        ' OR Savings_Calculated_Savings_Original__c = 0'+
                                        ' OR Savings_Calculated_Savings_Original__c = null)'+
                                        ' AND (nu_dse__Program_Status__c IN :programStatusInclusionSet)';
            }
            
        } else if(sObjectType == 'nu_dse__Tradeline__c'){ //building query for Tradeline 
            queryString = 'SELECT Id, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c FROM nu_dse__Tradeline__c ';

            if (recordIds != null && recordIds.isEmpty() == false) { // with set of record Ids
                queryString += ' WHERE Id IN :recordIds';
            } else { // for all tradelines without saving calc values
                queryString += ' WHERE (Savings_Months_to_Payoff__c = 0 '+
                                        ' OR Savings_Months_to_Payoff__c = null '+
                                        ' OR Savings_Payoff_Amount__c = 0'+
                                        ' OR Savings_Payoff_Amount__c = null'+
                                        ' OR Savings_Calculated_Savings__c = 0'+
                                        ' OR Savings_Calculated_Savings__c = null)'+
                                        ' AND (nu_dse__Program__c = null OR nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusInclusionSet)';
            }
        }
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>();
        List<nu_dse__Tradeline__c> tradelines = new List<nu_dse__Tradeline__c>();
        List<nu_dse__Error_Log__c> errLogsToInsert = new List<nu_dse__Error_Log__c>();
        
        for (sObject sObj: scope) {
            Double debt = 0; 
            if (sObjectType == 'nu_dse__Program__c') { // saving calc API for Program

                nu_dse__Program__c program = (nu_dse__Program__c)sObj;
                
                if(program.Original_Enrolled_Program_Debt__c != null && program.Original_Enrolled_Program_Debt__c > 0) {
                    debt = program.Original_Enrolled_Program_Debt__c; 
                }
                
                nu_dse__Program__c programToUpdate = (nu_dse__Program__c)PaymentsCalcService.savingsCalculatorExternalService(
                                                                        savingCalcSetting, debt, 'nu_dse__Program__c');
                programToUpdate.Id = program.Id;
                programs.add(programToUpdate);

            } else if(sObjectType == 'nu_dse__Tradeline__c'){ // saving calc API for Program
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

        errLogsToInsert.addAll(dmlRecords(programs));
        errLogsToInsert.addAll(dmlRecords(Tradelines));
        insert errLogsToInsert;
    }
    
    public void finish(Database.BatchableContext BC) {
        //not required
    }
    
    // Method to query Program_Status_Configuration meta data for get excluded program Statuses
    public void getProgramExclusionStatus() {
         
        Program_Status_Configuration__mdt progStatusConfig = new Program_Status_Configuration__mdt();

        if (Test.isRunningTest() == true) {
        
            progStatusConfig = new Program_Status_Configuration__mdt(
                                        MasterLabel = 'Savings Calculation', 
                                        DeveloperName = 'Savings_Calculation', 
                                        Included_Statuses__c = 'New Client,Active,Termination Pending,Graduation Pending');

        } else {
            progStatusConfig = [SELECT Label, DeveloperName, Included_Statuses__c 
                                        FROM Program_Status_Configuration__mdt 
                                        WHERE DeveloperName = 'Savings_Calculation' LIMIT 1];

        }

        if(progStatusConfig != null
            && String.isNotBlank(progStatusConfig.Included_Statuses__c)) {
            programStatusInclusionSet = new Set<String>(progStatusConfig.Included_Statuses__c.split(',', 0));
        }
    }

    public List<nu_dse__Error_Log__c> dmlRecords(List<Sobject> recordsToUpdateList) {

        List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();
        Integer count = 0;

        for (Database.SaveResult dmlResult: Database.update(recordsToUpdateList, false)) {

            if (dmlResult.isSuccess() == false) {
                nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_SavingsCalculation.excute',nu_dse__Error_Causing_Record_Id__c = String.valueOf(recordsToUpdateList[count].get('Id')),nu_dse__Stack_Trace__c = JSON.serialize(recordsToUpdateList[count]), nu_dse__User_Context__c = UserInfo.getName());

                errLog.nu_dse__Message__c = '';
                for (Database.Error error: dmlResult.getErrors()) {
                    errLog.nu_dse__Message__c += error.getMessage();
                }
                errLogs.add(errLog);
            }
            count++;
        }
        return errLogs;
    }
}