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
    
    public Batch_ProgramEstimatedBalanceUpdate() {

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
        }

        return Database.getQueryLocator(queryStr);
    }
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope) {
        
        try {
            
            Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};
            Date futureEstimateDate = system.today().toStartOfMonth().addMonths(12).addDays(-1); 

            String queryStr = 'SELECT Id, nu_dse__Trust_Account_Balance__c, ' + 
                                '(SELECT Id, nu_dse__Total_Amount__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c, nu_dse__Payment_Type__c, nu_dse__Transaction_Status__c, '+ 
                                'RecordTypeId, nu_dse__Offer__c, nu_dse__Offer__r.nu_dse__TradeLine__c FROM nu_dse__Payments__r ' +
                                'WHERE RecordTypeId IN :recordTypeIds '+
                                    'AND (nu_dse__Transaction_Status__c = \'Scheduled\' OR nu_dse__Transaction_Status__c = \'In Progress\' '+
                                    'OR nu_dse__Transaction_Status__c = \'Completed\' OR nu_dse__Transaction_Status__c = \'Cleared\') ' +
                                    'ORDER BY nu_dse__Schedule_Date__c ASC) '+
                        'FROM nu_dse__Program__c ' +
                        'WHERE Id IN :scope';
            
            List<nu_dse__Program__c> programToUpdateList = new List<nu_dse__Program__c>();
            Map<Id, nu_dse__TradeLine__c> tradelineIdRecMap = new Map<Id, nu_dse__TradeLine__c>();
            Map<Id, nu_dse__Offer__c> offerIdRecMap = new Map<Id, nu_dse__Offer__c>();

            for(nu_dse__Program__c program : Database.query(queryStr)) {

                if(program.nu_dse__Payments__r.isEmpty() == false) {
                    nu_dse__Program__c updateProgram = new nu_dse__Program__c(Id = program.Id);

                    Decimal programBal = 0;
                    
                    if(program.nu_dse__Trust_Account_Balance__c != null) {
                        programBal = program.nu_dse__Trust_Account_Balance__c;
                    }
                    updateProgram.Estimated_Current_Month_Balance__c = programBal;

                    for(nu_dse__Payment__c payment : program.nu_dse__Payments__r) {
                        // To calculate Program estimated balance
                        if(payment.nu_dse__Schedule_Date__c >= system.today()
                            && payment.nu_dse__Schedule_Date__c < futureEstimateDate
                            && (payment.nu_dse__Transaction_Status__c == 'Scheduled' 
                                || payment.nu_dse__Transaction_Status__c == 'In Progress')) {
                            
                            if(payment.RecordTypeId ==  draftRecordTypeId) {
                                programBal += payment.nu_dse__Amount__c;
                            } else if((payment.RecordTypeId == feeRecordTypeId 
                                        && payment.nu_dse__Payment_Type__c == 'Fee Withdrawal')
                                        || (payment.RecordTypeId == settlementRecordTypeId 
                                            && payment.nu_dse__Payment_Type__c == 'Withdrawal')) {

                                programBal -= payment.nu_dse__Total_Amount__c;
                            }
                            
                            if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(1).addDays(-1)) {
                        
                                updateProgram.Estimated_Current_Month_Balance__c = programBal;
                            
                            } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(2).addDays(-1)) {

                                updateProgram.Estimated_Month_2_Balance__c = programBal;

                            } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(3).addDays(-1)) {

                                updateProgram.Estimated_Month_3_Balance__c = programBal;

                            } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(6).addDays(-1)) {

                                updateProgram.Estimated_Month_6_Balance__c = programBal;

                            } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(9).addDays(-1)) {

                                updateProgram.Estimated_Month_9_Balance__c = programBal;

                            } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(12).addDays(-1)) {

                                updateProgram.Estimated_Month_12_Balance__c = programBal;

                            }
                        }
                        // To calculate Tradeline and Offer Creditor_Payments_Made, Creditor_Payments_Outstanding, Fees_Collected and Fees_Outstanding
                        if(payment.RecordTypeId != draftRecordTypeId
                            && ((payment.RecordTypeId == feeRecordTypeId 
                                && payment.nu_dse__Payment_Type__c == 'Fee Withdrawal')
                                || (payment.RecordTypeId == settlementRecordTypeId 
                                    && payment.nu_dse__Payment_Type__c == 'Withdrawal'))
                            && payment.nu_dse__Offer__r.nu_dse__TradeLine__c != null) {
                            
                            nu_dse__TradeLine__c tradeLineInst = new nu_dse__TradeLine__c(Id = payment.nu_dse__Offer__r.nu_dse__TradeLine__c, 
                                Creditor_Payments_Made__c = 0, Creditor_Payments_Outstanding__c = 0, 
                                Fees_Collected__c = 0, Fees_Outstanding__c = 0);

                            nu_dse__Offer__c offerInst = new nu_dse__Offer__c(Id = payment.nu_dse__Offer__c, 
                                Creditor_Payments_Made__c = 0, Creditor_Payments_Outstanding__c = 0, 
                                Fees_Collected__c = 0, Fees_Outstanding__c = 0);

                            if(tradelineIdRecMap.containsKey(tradeLineInst.Id) == true) {
                                tradeLineInst = tradelineIdRecMap.get(tradeLineInst.Id);
                            }

                            if(offerIdRecMap.containsKey(offerInst.Id) == true) {
                                offerInst = offerIdRecMap.get(offerInst.Id);
                            }

                            if(payment.RecordTypeId == feeRecordTypeId) {
                                
                                if (payment.nu_dse__Transaction_Status__c == 'Completed'
                                    || payment.nu_dse__Transaction_Status__c == 'Cleared') {
                                    tradeLineInst.Fees_Collected__c += payment.nu_dse__Total_Amount__c;
                                    offerInst.Fees_Collected__c += payment.nu_dse__Total_Amount__c;
                                } else {
                                    tradeLineInst.Fees_Outstanding__c += payment.nu_dse__Total_Amount__c;
                                    offerInst.Fees_Outstanding__c += payment.nu_dse__Total_Amount__c;
                                }

                            } else {
                                
                                if (payment.nu_dse__Transaction_Status__c == 'Completed'
                                    || payment.nu_dse__Transaction_Status__c == 'Cleared') {
                                    tradeLineInst.Creditor_Payments_Made__c += payment.nu_dse__Total_Amount__c;
                                    offerInst.Creditor_Payments_Made__c += payment.nu_dse__Total_Amount__c;
                                } else {
                                    tradeLineInst.Creditor_Payments_Outstanding__c += payment.nu_dse__Total_Amount__c;
                                    offerInst.Creditor_Payments_Outstanding__c += payment.nu_dse__Total_Amount__c;
                                }
                            }
                            tradeLineInst.Creditor_Fee_Payments_Calculated_on__c = System.now();
                            offerInst.Creditor_Fee_Payments_Calculated_on__c = System.now();
                            tradelineIdRecMap.put(tradeLineInst.Id, tradeLineInst);
                            offerIdRecMap.put(offerInst.Id, offerInst);
                        }
                    }

                    if(updateProgram.Estimated_Month_2_Balance__c == null 
                        && updateProgram.Estimated_Current_Month_Balance__c != null) {
                        updateProgram.Estimated_Month_2_Balance__c = updateProgram.Estimated_Current_Month_Balance__c;
                    }
                    if(updateProgram.Estimated_Month_3_Balance__c == null 
                        && updateProgram.Estimated_Month_2_Balance__c != null) {
                        updateProgram.Estimated_Month_3_Balance__c = updateProgram.Estimated_Month_2_Balance__c;
                    }
                    if(updateProgram.Estimated_Month_6_Balance__c == null 
                        && updateProgram.Estimated_Month_3_Balance__c != null) {
                        updateProgram.Estimated_Month_6_Balance__c = updateProgram.Estimated_Month_3_Balance__c;
                    }
                    if(updateProgram.Estimated_Month_9_Balance__c == null 
                        && updateProgram.Estimated_Month_6_Balance__c != null) {
                        updateProgram.Estimated_Month_9_Balance__c = updateProgram.Estimated_Month_6_Balance__c;
                    }
                    if(updateProgram.Estimated_Month_12_Balance__c == null 
                        && updateProgram.Estimated_Month_9_Balance__c != null) {
                        updateProgram.Estimated_Month_12_Balance__c = updateProgram.Estimated_Month_9_Balance__c;
                    }
                    updateProgram.Estimated_Balance_Calculations_Timestamp__c = System.now();
                    programToUpdateList.add(updateProgram);
                }
            }

            List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();
            dmlResultWrapper programDmlResult = dmlRecords(programToUpdateList);
            successProgramRecordsCount += programDmlResult.successRecordsCount;
            failedProgramRecordsCount += programDmlResult.failedRecordsCount;
            totalProgramRecordsCount += programDmlResult.totalRecordsCount;
            errLogs.addall(programDmlResult.errorLogs);

            dmlResultWrapper tradelineDmlResult = dmlRecords(tradelineIdRecMap.values());
            updatedTradelinesCount += tradelineDmlResult.successRecordsCount;
            failedTradelinesCount += tradelineDmlResult.failedRecordsCount;
            totalTradelinesCount += tradelineDmlResult.totalRecordsCount;
            errLogs.addall(tradelineDmlResult.errorLogs);

            dmlResultWrapper offerDmlResult = dmlRecords(offerIdRecMap.values());
            updatedOffersCount += offerDmlResult.successRecordsCount;
            failedOffersCount += offerDmlResult.failedRecordsCount;
            totalOffersCount += offerDmlResult.totalRecordsCount;
            errLogs.addall(offerDmlResult.errorLogs);
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