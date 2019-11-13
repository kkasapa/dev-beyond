/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Service class for calcualtions on Payments 
* Program Estimated Balance.(Program)
* Creditor/Fee payment paid and outstanding calculations(Tradeline/Offer) 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-11-08
* @modified       2019-11-08
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

public without sharing class PaymentsCalcService {

    public static Set<String> programStatus = new Set<String>{'New Client', 'Active'};
    public static Date futureEstimateDate = system.today().toStartOfMonth().addMonths(12).addDays(-1);

    public static Map<Id, nu_dse__Program__c> programToUpdateMap = new Map<Id, nu_dse__Program__c>();
    public static Map<Id, nu_dse__TradeLine__c> tradelineIdRecMap = new Map<Id, nu_dse__TradeLine__c>();
    public static Map<Id, nu_dse__Offer__c> offerIdRecMap = new Map<Id, nu_dse__Offer__c>();
    public static List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();

    public static Id draftRecordTypeId = getPaymentRecordTypeId('Draft'); // recordType Id for draft
    public static Id feeRecordTypeId = getPaymentRecordTypeId('Fee');  // recordType Id for fee
    public static Id settlementRecordTypeId = getPaymentRecordTypeId('Settlement');  // recordType Id for settlement


    public PaymentsCalcService() {

    }

    public static void calcProgramEstimatedBalance(Set<Id> programIds) {

        Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};

        for(nu_dse__Program__c program : [SELECT Id, nu_dse__Trust_Account_Balance__c, 
                                            (SELECT Id, nu_dse__Total_Amount__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c, 
                                                nu_dse__Payment_Type__c, nu_dse__Transaction_Status__c, RecordTypeId, nu_dse__Offer__c, 
                                                nu_dse__Offer__r.nu_dse__TradeLine__c FROM nu_dse__Payments__r 
                                            WHERE RecordTypeId IN :recordTypeIds AND (nu_dse__Transaction_Status__c = 'Scheduled' 
                                                OR nu_dse__Transaction_Status__c = 'In Progress' OR nu_dse__Transaction_Status__c = 'Completed' 
                                                OR nu_dse__Transaction_Status__c = 'Cleared') 
                                            ORDER BY nu_dse__Schedule_Date__c ASC)
                                        FROM nu_dse__Program__c WHERE Id IN :programIds]) {

            if(program.nu_dse__Payments__r.isEmpty() == false) {
                nu_dse__Program__c updateProgram = new nu_dse__Program__c(Id = program.Id);

                if(programToUpdateMap.containskey(updateProgram.Id) == true) {
                    updateProgram = programToUpdateMap.get(updateProgram.Id);
                }

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
                    //calc on Tradeline and Offer
                    calcPaidOutstandingForCreditorPayments(payment);
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
                programToUpdateMap.put(updateProgram.Id, updateProgram);
            }
        }
        updateRecords(programToUpdateMap.values());
        updateRecords(tradelineIdRecMap.values());
        updateRecords(offerIdRecMap.values());
        insert errLogs;
    } 

    public static void calcPaidOutstandingForCreditorPayments(nu_dse__Payment__c payment) {
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

    public static void calcPaidOutstandingForCreditor(Set<Id> tradelineIds) {

        Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};

        for (nu_dse__Payment__c payment: [SELECT Id, nu_dse__Total_Amount__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c, 
                                                nu_dse__Payment_Type__c, nu_dse__Transaction_Status__c, RecordTypeId, nu_dse__Offer__c, 
                                                nu_dse__Offer__r.nu_dse__TradeLine__c FROM nu_dse__Payment__c 
                                            WHERE nu_dse__Offer__r.nu_dse__TradeLine__c IN :tradelineIds 
                                                AND RecordTypeId IN :recordTypeIds 
                                                AND (nu_dse__Transaction_Status__c = 'Scheduled' 
                                                    OR nu_dse__Transaction_Status__c = 'In Progress' 
                                                    OR nu_dse__Transaction_Status__c = 'Completed' 
                                                    OR nu_dse__Transaction_Status__c = 'Cleared') 
                                            ORDER BY nu_dse__Schedule_Date__c ASC]) {
            calcPaidOutstandingForCreditorPayments(payment);
        }
        updateRecords(tradelineIdRecMap.values());
        updateRecords(offerIdRecMap.values());
        insert errLogs;
    }

    //common method for handling DML and process the result as error logs
    public static void updateRecords(List<Sobject> recordsToUpdateList) {
        Integer count = 0;
        if(recordsToUpdateList.isEmpty() == false) {
            for (Database.SaveResult dmlResult: Database.update(recordsToUpdateList, false)) {
                if (dmlResult.isSuccess() == false) {
                    nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(
                                                    nu_dse__Class_Method__c = 'Batch_ProgramEstimatedBalanceUpdate.excute',
                                                    nu_dse__Error_Causing_Record_Id__c = String.valueOf(recordsToUpdateList[count].get('Id')),
                                                    nu_dse__Stack_Trace__c = JSON.serialize(recordsToUpdateList[count]), 
                                                    nu_dse__User_Context__c = UserInfo.getName());
                    errLog.nu_dse__Message__c = '';
                    for (Database.Error error: dmlResult.getErrors()) {
                        errLog.nu_dse__Message__c += error.getMessage();
                    }
                    errLogs.add(errLog);
                } 
                count++;
            }
        }
    }

    //returns the recordType Id based on developerName 
    public static Id getPaymentRecordTypeId(String recordTypeDeveloperName) {
       return Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get(recordTypeDeveloperName).getRecordTypeId();
    }

}