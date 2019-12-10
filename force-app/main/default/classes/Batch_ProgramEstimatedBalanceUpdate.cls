/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for update Program Estimated Balance. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-08
* @modified       2019-10-31
* @logic          Program:
                  Balance = sum of all drafts(deposits.nu_dse__Amount) in the month - sum of all settlements(withrawals.nu_dse__Total_Amount__c) in the month - sum of all Fee(Fee withdrawals.nu_dse__Total_Amount__c) 
                  Tradeline:
                  Completed/Cleared Withdrawal/Fee Withdrawal payments aggregated to Creditor_Payments_Made, Creditor_Payments_Outstanding, Fees_Collected, Fees_Outstanding. And Timestamp in Creditor_Fee_Payments_Calculated_on
                  Offer:
                  Completed/Cleared Withdrawal/Fee Withdrawal payments aggregated to Creditor_Payments_Made, Creditor_Payments_Outstanding, Fees_Collected, Fees_Outstanding. And Timestamp in Creditor_Fee_Payments_Calculated_on
* @description    This batch will calculate the Estimated trust account balance at the end of current month, 2,3,6,9,12 months
                  and calculate the Creditor_Payments_Made, Creditor_Payments_Outstanding, Fees_Collected and Fees_Outstanding for Tradeline and Offer
* @IMPORTANT NOTE Only the Draft(Deposit) and Settlement(Customer Withdrawal) and Fee(Fee Withdrawal) are included in the calculation.
                  And nu_dse__Amount field will be used for Draft(Deposit) and nu_dse__Total_Amount__c will be used for Settlement(Customer Withdrawal) and Fee(Fee Withdrawal)
                  Because the nu_dse__Total_Amount__c field in Draft(Deposit) can contain other Fees such as Affiliate Fee, Maintainence Fee, etc.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_ProgramEstimatedBalanceUpdate implements Database.Batchable<sObject>, Database.stateful {
    
    Set<Id> programIds; //set of programIds to which the batch can be run
    Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId(); // recordType Id for draft
    Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();  // recordType Id for fee
    Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();  // recordType Id for settlement
    Integer successProgramRecordsCount, failedProgramRecordsCount, totalProgramRecordsCount, 
            totalTradelinesCount, updatedTradelinesCount, failedTradelinesCount,
            totalOffersCount, updatedOffersCount, failedOffersCount;
    String processStartTime;
    Integer programNumStartIndex, programNumEndIndex;

    public Batch_ProgramEstimatedBalanceUpdate() {

    }
    
    public Batch_ProgramEstimatedBalanceUpdate(Integer startIndex, Integer endIndex) {

        if(startIndex != null && endIndex != null && startIndex < endIndex) {

            programNumStartIndex = startIndex;
            programNumEndIndex = endIndex;

        } else {
             throw new CustomException('Incorrect program Number StartIndex and EndIndex value'); // needs to be changed
        }
    }
    //configurable contructor to run for set of programs
    public Batch_ProgramEstimatedBalanceUpdate(Set<Id> programIdSet) {
        programIds = new Set<Id>();
        if(programIdSet != null && programIdSet.isEmpty() == false) {
            programIds = programIdSet;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        successProgramRecordsCount = 0; failedProgramRecordsCount = 0; totalProgramRecordsCount = 0;
        updatedTradelinesCount = 0; failedTradelinesCount = 0; totalTradelinesCount = 0;
        totalOffersCount = 0; updatedOffersCount = 0; failedOffersCount = 0;
        processStartTime = system.now().format();

        Set<String> programStatus = new Set<String>{'New Client', 'Active'}; // by default, program status with New Client, Active will be processed
        //custom metadata type for having Program status to be included for calculations
        Program_Status_Configuration__mdt progStatusConfig = [SELECT Id, MasterLabel, Included_Statuses__c 
                                    FROM Program_Status_Configuration__mdt 
                                    WHERE DeveloperName = 'Estimated_Balance_Calculations' LIMIT 1];
        
        if(progStatusConfig != null
            && String.isNotBlank(progStatusConfig.Included_Statuses__c)) {
            programStatus = new Set<String>(progStatusConfig.Included_Statuses__c.split(',', 0));
        } 



        String queryStr = 'SELECT Id FROM nu_dse__Program__c WHERE nu_dse__Program_Status__c IN :programStatus';
        
        if(programIds != null && programIds.isEmpty() == false) {
            queryStr += ' AND Id IN :programIds';
        } else {

            queryStr += ' AND Term_Digit__c >= \''+ programNumStartIndex +'\' AND Term_Digit__c <= \'' + programNumEndIndex +'\'';
        }
        queryStr += ' ORDER BY nu_dse__Payment_Frequency__c DESC, nu_dse__Program_Length__c DESC';
        system.debug('queryStr-->'+queryStr);
        return Database.getQueryLocator(queryStr);
    }
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope) {
        
        try {
            
            Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};
            Date futureEstimateDate = system.today().toStartOfMonth().addMonths(36).addDays(-1); 
            
            Map<Id,nu_dse__Program__c> programIdsMap = new Map<Id,nu_dse__Program__c>(scope);

            //logic from the payment calc service is being referred. logic mvoved to service on 11/10/19
            PaymentsCalcService.futureEstimateDate = futureEstimateDate;
            PaymentsCalcService.PaymentCalcWrapper paymentCalcWrap = PaymentsCalcService.calcProgramEstimatedBalance(programIdsMap.keySet());

            List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();
            dmlResultWrapper programDmlResult = dmlRecords(paymentCalcWrap.programToUpdateMap.values());
            successProgramRecordsCount += programDmlResult.successRecordsCount;
            failedProgramRecordsCount += programDmlResult.failedRecordsCount;
            totalProgramRecordsCount += programDmlResult.totalRecordsCount;
            errLogs.addAll(programDmlResult.errorLogs);

            dmlResultWrapper tradelineDmlResult = dmlRecords(paymentCalcWrap.tradelineIdRecMap.values());
            updatedTradelinesCount += tradelineDmlResult.successRecordsCount;
            failedTradelinesCount += tradelineDmlResult.failedRecordsCount;
            totalTradelinesCount += tradelineDmlResult.totalRecordsCount;
            errLogs.addAll(tradelineDmlResult.errorLogs);

            dmlResultWrapper offerDmlResult = dmlRecords(paymentCalcWrap.offerIdRecMap.values());
            updatedOffersCount += offerDmlResult.successRecordsCount;
            failedOffersCount += offerDmlResult.failedRecordsCount;
            totalOffersCount += offerDmlResult.totalRecordsCount;
            errLogs.addAll(offerDmlResult.errorLogs);
            insert errLogs;

        } catch(Exception e) {

            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProgramEstimatedBalanceUpdate.Execute');
            
            insert errorLog;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
        Default_Task_Assignments_to_User__mdt taskAssignDefault = [SELECT Task_Assignement_User_Id__c 
                                                                   FROM Default_Task_Assignments_to_User__mdt
                                                                   WHERE DeveloperName = 'Estimated_Current_Balance_Task' LIMIT 1];
        //checks if the id is valid user id or else create error logs
        if(taskAssignDefault != null 
            && String.isNotBlank(taskAssignDefault.Task_Assignement_User_Id__c) == true
            && (taskAssignDefault.Task_Assignement_User_Id__c.length() == 15 
                || taskAssignDefault.Task_Assignement_User_Id__c.length() == 18)
            && Id.valueOf(taskAssignDefault.Task_Assignement_User_Id__c).getSobjectType().getDescribe().getName() == 'User') {                                                          
            
            String descripStr = 'PROGRAMS: \n'+
                                'Total Programs Processed: '+ totalProgramRecordsCount +'; \n'+ 'No of Programs Updated Successfully: '+
                                successProgramRecordsCount + '; \n' +'No of Programs Failed: '+ failedProgramRecordsCount + '; \n' + 
                                'TRADELINES: \n'+
                                'Total Tradelines Processed: '+ totalTradelinesCount +'; \n'+ 'No of Tradelines Updated Successfully: '+
                                updatedTradelinesCount + '; \n' +'No of Tradelines Failed: '+ failedTradelinesCount + '; \n' + 
                                'OFFERS: \n'+
                                'Total Offers Processed: '+ totalOffersCount +'; \n'+ 'No of Offers Updated Successfully: '+
                                updatedOffersCount + '; \n' +'No of Offers Failed: '+ failedOffersCount + '; \n' + 
                                'Process Start Time: ' + processStartTime + '; \n' + 
                                'Process End Time: ' + system.now().format() + ';';
                                
            Task taskRec = new Task(Subject = 'Estimated Balance Calculation/Tradeline/Offer Settlement Payments Calculations Job has been Completed!', ActivityDate = system.today(), 
                                    Description = descripStr, Status = 'Completed', OwnerId = taskAssignDefault.Task_Assignement_User_Id__c);
            insert taskRec;
        } else {
            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = 'Invalid User Id for task assignment', nu_dse__Stack_Trace__c = 'Please check Custom metadata record with Developer Name \'Estimated_Current_Balance_Task\'', nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProgramEstimatedBalanceUpdate.finish');
            insert errorLog;
        }
    } 

    public dmlResultWrapper dmlRecords(List<Sobject> recordsToUpdateList) {

        dmlResultWrapper recordsDmlResult = new dmlResultWrapper();
        Integer count = 0, successRecordsCount = 0, failedRecordsCount = 0;
        List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();

        for (Database.SaveResult dmlResult: Database.update(recordsToUpdateList, false)) {

            if (dmlResult.isSuccess() == false) {
                nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ProgramEstimatedBalanceUpdate.excute',nu_dse__Error_Causing_Record_Id__c = String.valueOf(recordsToUpdateList[count].get('Id')),nu_dse__Stack_Trace__c = JSON.serialize(recordsToUpdateList[count]), nu_dse__User_Context__c = UserInfo.getName());

                errLog.nu_dse__Message__c = '';
                for (Database.Error error: dmlResult.getErrors()) {
                    errLog.nu_dse__Message__c += error.getMessage();
                }
                errLogs.add(errLog);
                failedRecordsCount += 1;
            } else {
                successRecordsCount += 1;
            }
            count++;
        }

        recordsDmlResult.totalRecordsCount = count;
        recordsDmlResult.successRecordsCount = successRecordsCount;
        recordsDmlResult.failedRecordsCount = failedRecordsCount;
        recordsDmlResult.errorLogs = errLogs;
        return recordsDmlResult;
    }

    public class dmlResultWrapper {

        public Integer failedRecordsCount;
        public Integer successRecordsCount;
        public Integer totalRecordsCount;
        public List<nu_dse__Error_Log__c> errorLogs;
    }
}