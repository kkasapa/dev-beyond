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

    //public static Set<String> programStatus = new Set<String>{'New Client', 'Active'};
    public static Date futureEstimateDate = system.today().toStartOfMonth().addMonths(36).addDays(-1);

    public static Id draftRecordTypeId = getPaymentRecordTypeId('Draft'); // recordType Id for draft
    public static Id feeRecordTypeId = getPaymentRecordTypeId('Fee');  // recordType Id for fee
    public static Id settlementRecordTypeId = getPaymentRecordTypeId('Settlement');  // recordType Id for settlement

    public static PaymentCalcWrapper calcProgramEstimatedBalance(Set<Id> programIds) {

        PaymentCalcWrapper paymentCalcWrap = new PaymentCalcWrapper();
        Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};

        for(nu_dse__Program__c program : [SELECT Id, nu_dse__Trust_Account_Balance__c, 
                                            (SELECT Id, nu_dse__Total_Amount__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c, 
                                                nu_dse__Payment_Type__c, nu_dse__Transaction_Status__c, RecordTypeId, nu_dse__Offer__c, 
                                                nu_dse__Offer__r.nu_dse__TradeLine__c FROM nu_dse__Payments__r 
                                            WHERE RecordTypeId IN :recordTypeIds AND (nu_dse__Transaction_Status__c = 'Scheduled' 
                                                OR nu_dse__Transaction_Status__c = 'In Progress' OR nu_dse__Transaction_Status__c = 'Completed' 
                                                OR nu_dse__Transaction_Status__c = 'Cleared' 
                                                OR (nu_dse__Transaction_Status__c = 'Tentative' 
                                                    AND (nu_dse__Offer__r.nu_dse__Status__c = '03-Offer Approved (Pre-payment setup)' 
                                                         OR nu_dse__Offer__r.nu_dse__Status__c = '04-Ready for Payment Setup')))
                                            ORDER BY nu_dse__Schedule_Date__c ASC)
                                        FROM nu_dse__Program__c WHERE Id IN :programIds]) {

            nu_dse__Program__c updateProgram = new nu_dse__Program__c(Id = program.Id);

            if(paymentCalcWrap.programToUpdateMap.containskey(updateProgram.Id) == true) {
                updateProgram = paymentCalcWrap.programToUpdateMap.get(updateProgram.Id);
            }

            Decimal programBal = 0;
            // Decimal programLowestAmount;
            //Date programLowestDate;
            
            //Map<String, Decimal> estimatedMonthBalancesMap = new Map<String, Decimal>();
            Map<Integer, EstimatedMonthBalance> estdMonthBalanceMap = new Map<Integer, EstimatedMonthBalance>(); 
            //String firstPaymentMonthYear;

            Decimal estimateLastPaymentBal; // estimated balance as per the last processed payment 
            Date estimateLastPaymentDate; // estimated date as per the last processed payment
            Decimal endOfMonthLowestBalance; // lowest balance at the end of the month
            Date endOfMonthLowestBalDate; // date of last payment in the month that has lowest balance at the end
            String paymentMonthIdentifier; // a string identifier for checking the last payment in the month, this id will be same for all payments in a month
            
            if(program.nu_dse__Trust_Account_Balance__c != null) {
                programBal = program.nu_dse__Trust_Account_Balance__c;
                // programLowestAmount = program.nu_dse__Trust_Account_Balance__c; // initially the current balance will be the lowest
                // programLowestDate = system.today(); // start of the calc, lowest amount and date will be current balance and today
                estimateLastPaymentBal = program.nu_dse__Trust_Account_Balance__c;  // initially the current balance will be the lowest
            }
            updateProgram.Estimated_Current_Month_Balance__c = programBal;
            estimateLastPaymentDate = system.today();
            paymentMonthIdentifier = system.today().month() + '-' + system.today().year(); // string UID for checking the last payment of month
            
            for(nu_dse__Payment__c payment : program.nu_dse__Payments__r) {
                // To calculate Program estimated balance
                if((payment.nu_dse__Schedule_Date__c >= system.today()
                    && payment.nu_dse__Transaction_Status__c == 'Scheduled') 
                    || payment.nu_dse__Transaction_Status__c == 'In Progress') {
                    
                    if(payment.RecordTypeId ==  draftRecordTypeId) {
                        programBal += payment.nu_dse__Amount__c;
                    } else if((payment.RecordTypeId == feeRecordTypeId 
                                && payment.nu_dse__Payment_Type__c == 'Fee Withdrawal')
                                || (payment.RecordTypeId == settlementRecordTypeId 
                                    && payment.nu_dse__Payment_Type__c == 'Withdrawal')) {

                        programBal -= payment.nu_dse__Total_Amount__c;
                    }

                    /*if(programLowestAmount == null || programLowestAmount > programBal) {

                        programLowestAmount = programBal;
                        programLowestDate = payment.nu_dse__Schedule_Date__c;
                    }*/
                    
                    // if the current payment processed is first payment of the month and the last payment is lowest amonge the schedule 
                    // then we are reserving that as lowest month end balance at this point
                    if(payment.nu_dse__Schedule_Date__c.month() +'-'+ payment.nu_dse__Schedule_Date__c.year() != paymentMonthIdentifier
                        && estimateLastPaymentBal != null 
                        && (endOfMonthLowestBalance == null || estimateLastPaymentBal < endOfMonthLowestBalance)) {  
                        
                        endOfMonthLowestBalance = estimateLastPaymentBal;
                        endOfMonthLowestBalDate = estimateLastPaymentDate;
                        paymentMonthIdentifier = payment.nu_dse__Schedule_Date__c.month() +'-'+ payment.nu_dse__Schedule_Date__c.year();
                    }
                    
                    estimateLastPaymentBal = programBal;
                    estimateLastPaymentDate = payment.nu_dse__Schedule_Date__c;

                    //if(payment.nu_dse__Schedule_Date__c <= futureEstimateDate) {
                        
                        if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(1).addDays(-1)) {

                            estdMonthBalanceMap.put(01,new EstimatedMonthBalance(01, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(2).addDays(-1)) {

                            estdMonthBalanceMap.put(02,new EstimatedMonthBalance(02, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_2_Balance__c = programBal;                             
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(3).addDays(-1)) {

                            estdMonthBalanceMap.put(03,new EstimatedMonthBalance(03, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_3_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(4).addDays(-1)) {

                            estdMonthBalanceMap.put(04,new EstimatedMonthBalance(04, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(5).addDays(-1)) {

                            estdMonthBalanceMap.put(05,new EstimatedMonthBalance(05, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(6).addDays(-1)) {

                            estdMonthBalanceMap.put(06,new EstimatedMonthBalance(06, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_6_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(7).addDays(-1)) {

                            estdMonthBalanceMap.put(07,new EstimatedMonthBalance(07, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(8).addDays(-1)) {

                            estdMonthBalanceMap.put(08,new EstimatedMonthBalance(08, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(9).addDays(-1)) {

                            estdMonthBalanceMap.put(09,new EstimatedMonthBalance(09, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_9_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(10).addDays(-1)) {

                            estdMonthBalanceMap.put(10,new EstimatedMonthBalance(10, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(11).addDays(-1)) {

                            estdMonthBalanceMap.put(11,new EstimatedMonthBalance(11, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(12).addDays(-1)) {

                            estdMonthBalanceMap.put(12,new EstimatedMonthBalance(12, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_12_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(13).addDays(-1)) {

                            estdMonthBalanceMap.put(13,new EstimatedMonthBalance(13, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(14).addDays(-1)) {

                            estdMonthBalanceMap.put(14,new EstimatedMonthBalance(14, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(15).addDays(-1)) {

                            estdMonthBalanceMap.put(15,new EstimatedMonthBalance(15, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(16).addDays(-1)) {

                            estdMonthBalanceMap.put(16,new EstimatedMonthBalance(16, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(17).addDays(-1)) {

                            estdMonthBalanceMap.put(17,new EstimatedMonthBalance(17, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_18_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(18).addDays(-1)) {

                            estdMonthBalanceMap.put(18,new EstimatedMonthBalance(18, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(19).addDays(-1)) {

                            estdMonthBalanceMap.put(19,new EstimatedMonthBalance(19, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(20).addDays(-1)) {

                            estdMonthBalanceMap.put(20,new EstimatedMonthBalance(20, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(21).addDays(-1)) {

                            estdMonthBalanceMap.put(21,new EstimatedMonthBalance(21, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(22).addDays(-1)) {

                            estdMonthBalanceMap.put(22,new EstimatedMonthBalance(22, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(23).addDays(-1)) {

                            estdMonthBalanceMap.put(23,new EstimatedMonthBalance(23, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_24_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(24).addDays(-1)) {

                            estdMonthBalanceMap.put(24,new EstimatedMonthBalance(24, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(25).addDays(-1)) {

                            estdMonthBalanceMap.put(25,new EstimatedMonthBalance(25, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(26).addDays(-1)) {

                            estdMonthBalanceMap.put(26,new EstimatedMonthBalance(26, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(27).addDays(-1)) {

                            estdMonthBalanceMap.put(27,new EstimatedMonthBalance(27, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(28).addDays(-1)) {

                            estdMonthBalanceMap.put(28,new EstimatedMonthBalance(28, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(29).addDays(-1)) {

                            estdMonthBalanceMap.put(29,new EstimatedMonthBalance(29, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_30_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(30).addDays(-1)) {

                            estdMonthBalanceMap.put(30,new EstimatedMonthBalance(30, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(31).addDays(-1)) {

                            estdMonthBalanceMap.put(31,new EstimatedMonthBalance(31, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(32).addDays(-1)) {

                            estdMonthBalanceMap.put(32,new EstimatedMonthBalance(32, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(33).addDays(-1)) {

                            estdMonthBalanceMap.put(33,new EstimatedMonthBalance(33, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(34).addDays(-1)) {

                            estdMonthBalanceMap.put(34,new EstimatedMonthBalance(34, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(35).addDays(-1)) {

                            estdMonthBalanceMap.put(35,new EstimatedMonthBalance(35, payment.nu_dse__Schedule_Date__c, programBal));
                            updateProgram.Estimated_Month_36_Balance__c = programBal;
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(36).addDays(-1)) {

                            estdMonthBalanceMap.put(36,new EstimatedMonthBalance(36, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(37).addDays(-1)) {

                            estdMonthBalanceMap.put(37,new EstimatedMonthBalance(37, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(38).addDays(-1)) {

                            estdMonthBalanceMap.put(38,new EstimatedMonthBalance(38, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(39).addDays(-1)) {

                            estdMonthBalanceMap.put(39,new EstimatedMonthBalance(39, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(40).addDays(-1)) {

                            estdMonthBalanceMap.put(40,new EstimatedMonthBalance(40, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(41).addDays(-1)) {

                            estdMonthBalanceMap.put(41,new EstimatedMonthBalance(41, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(42).addDays(-1)) {

                            estdMonthBalanceMap.put(42,new EstimatedMonthBalance(42, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(43).addDays(-1)) {

                            estdMonthBalanceMap.put(43,new EstimatedMonthBalance(43, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(44).addDays(-1)) {

                            estdMonthBalanceMap.put(44,new EstimatedMonthBalance(44, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(45).addDays(-1)) {

                            estdMonthBalanceMap.put(45,new EstimatedMonthBalance(45, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(46).addDays(-1)) {

                            estdMonthBalanceMap.put(46,new EstimatedMonthBalance(46, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(47).addDays(-1)) {

                            estdMonthBalanceMap.put(47,new EstimatedMonthBalance(47, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(48).addDays(-1)) {

                            estdMonthBalanceMap.put(48,new EstimatedMonthBalance(48, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(49).addDays(-1)) {

                            estdMonthBalanceMap.put(49,new EstimatedMonthBalance(49, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(50).addDays(-1)) {

                            estdMonthBalanceMap.put(50,new EstimatedMonthBalance(50, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(51).addDays(-1)) {

                            estdMonthBalanceMap.put(51,new EstimatedMonthBalance(51, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(52).addDays(-1)) {

                            estdMonthBalanceMap.put(52,new EstimatedMonthBalance(52, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(53).addDays(-1)) {

                            estdMonthBalanceMap.put(53,new EstimatedMonthBalance(53, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(54).addDays(-1)) {

                            estdMonthBalanceMap.put(54,new EstimatedMonthBalance(54, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(55).addDays(-1)) {

                            estdMonthBalanceMap.put(55,new EstimatedMonthBalance(55, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(56).addDays(-1)) {

                            estdMonthBalanceMap.put(56,new EstimatedMonthBalance(56, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(57).addDays(-1)) {

                            estdMonthBalanceMap.put(57,new EstimatedMonthBalance(57, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(58).addDays(-1)) {

                            estdMonthBalanceMap.put(58,new EstimatedMonthBalance(58, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(59).addDays(-1)) {

                            estdMonthBalanceMap.put(59,new EstimatedMonthBalance(59, payment.nu_dse__Schedule_Date__c, programBal));
                        } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(60).addDays(-1)) {

                            estdMonthBalanceMap.put(60,new EstimatedMonthBalance(60, payment.nu_dse__Schedule_Date__c, programBal));
                        }
                    //}
                }
                //calc on Tradeline and Offer
                calcPaidOutstandingForCreditorPayments(payment, paymentCalcWrap);
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
            if(updateProgram.Estimated_Month_18_Balance__c == null 
                && updateProgram.Estimated_Month_12_Balance__c != null) {
                updateProgram.Estimated_Month_18_Balance__c = updateProgram.Estimated_Month_12_Balance__c;
            }
            if(updateProgram.Estimated_Month_24_Balance__c == null 
                && updateProgram.Estimated_Month_18_Balance__c != null) {
                updateProgram.Estimated_Month_24_Balance__c = updateProgram.Estimated_Month_18_Balance__c;
            }
            if(updateProgram.Estimated_Month_30_Balance__c == null 
                && updateProgram.Estimated_Month_24_Balance__c != null) {
                updateProgram.Estimated_Month_30_Balance__c = updateProgram.Estimated_Month_24_Balance__c;
            }
            if(updateProgram.Estimated_Month_36_Balance__c == null 
                && updateProgram.Estimated_Month_30_Balance__c != null) {
                updateProgram.Estimated_Month_36_Balance__c = updateProgram.Estimated_Month_30_Balance__c;
            }
            
            if(estimateLastPaymentBal != null 
                && (endOfMonthLowestBalance == null || estimateLastPaymentBal < endOfMonthLowestBalance)) {
                endOfMonthLowestBalance = estimateLastPaymentBal;
                endOfMonthLowestBalDate = estimateLastPaymentDate;
            }

            System.debug('estimatedMonthBalancesMap->'+estdMonthBalanceMap);
            System.debug('estimatedMonthBalancesMap-JSON->'+ JSON.serialize(estdMonthBalanceMap));
            //final assignments as per the calc
            updateProgram.Estimated_Balances_RAW__c = JSON.serialize(estdMonthBalanceMap.values());
            updateProgram.Estimated_Current_Month_Balance__c = estdMonthBalanceMap.get(01).balance;
            updateProgram.Estimated_lowest_balance_amount__c = endOfMonthLowestBalance;
            updateProgram.Estimated_lowest_balance_date__c = endOfMonthLowestBalDate;
            updateProgram.Estimated_Balance_Calculations_Timestamp__c = System.now();
            paymentCalcWrap.programToUpdateMap.put(updateProgram.Id, updateProgram);
        }
        return paymentCalcWrap;
    } 

    public static void calcPaidOutstandingForCreditorPayments(nu_dse__Payment__c payment, PaymentCalcWrapper paymentCalcWrap) {

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

            if(paymentCalcWrap.tradelineIdRecMap.containsKey(tradeLineInst.Id) == true) {
                tradeLineInst = paymentCalcWrap.tradelineIdRecMap.get(tradeLineInst.Id);
            }

            if(paymentCalcWrap.offerIdRecMap.containsKey(offerInst.Id) == true) {
                offerInst = paymentCalcWrap.offerIdRecMap.get(offerInst.Id);
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
            
            paymentCalcWrap.tradelineIdRecMap.put(tradeLineInst.Id, tradeLineInst);
            paymentCalcWrap.offerIdRecMap.put(offerInst.Id, offerInst);
        }
    }

    public static PaymentCalcWrapper calcPaidOutstandingForCreditor(Set<Id> tradelineIds) {

        PaymentCalcWrapper paymentCalcWrap = new PaymentCalcWrapper();
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
            calcPaidOutstandingForCreditorPayments(payment, paymentCalcWrap);
        }
        return paymentCalcWrap;
    }

    public static SObject savingsCalculatorExternalService(SavingCalcSettings savingCalcSetting, Double debtAmount, String sObjectType) {

            Map<String, String> savingsCalcTradelineMappings = new Map<String,String> {
                                                                    'total-months' => 'Savings_Months_to_Payoff__c',
                                                                    'total-payments' => 'Savings_Payoff_Amount__c',
                                                                    'total-savings' => 'Savings_Calculated_Savings__c',
                                                                    'error' => 'Savings_Calc_Error__c',
                                                                    'timestamp' => 'Saving_Calculation_Timestamp__c'};
            Map<String, String> savingsCalcProgramMappings = new Map<String,String> {
                                                                    'total-months' => 'Savings_Months_to_Payoff_Original__c',
                                                                    'total-payments' => 'Savings_Payoff_Amount_Original__c',
                                                                    'total-savings' => 'Savings_Calculated_Savings_Original__c',
                                                                    'error' => 'Savings_Calculation_Error_Original__c',
                                                                    'timestamp' => 'Savings_Calculation_Timestamp_Original__c'};
            JSONGenerator requestBodyJson = JSON.createGenerator(true);
            requestBodyJson.writeStartObject();
            requestBodyJson.writeFieldName('data');
            requestBodyJson.writeStartObject();
            requestBodyJson.writeStringField('type', 'savings');
            requestBodyJson.writeFieldName('attributes');
            requestBodyJson.writeStartObject();
            requestBodyJson.writeNumberField('current_balance', debtAmount);
            requestBodyJson.writeNumberField('minimum_payment', debtAmount * savingCalcSetting.minimumPaymentPercent);
            requestBodyJson.writeNumberField('annual_interest_rate', savingCalcSetting.interestRate);
            requestBodyJson.writeEndObject();
            requestBodyJson.writeEndObject();
            requestBodyJson.writeEndObject();

            HttpRequest request = new HttpRequest();
            request.setEndpoint(savingCalcSetting.endpoint);
            request.setMethod('POST');
            request.setTimeout(2000);
            request.setHeader('Content-Type','application/vnd.api+json');
            // body = '{"data":{"type":"savings","attributes":{"current_balance":'+ debt +',"minimum_payment":'+ payment +',"annual_interest_rate":"'+ rate +'"}}}';
            request.setBody(requestBodyJson.getAsString());
            system.debug('requestBody-->'+request.getBody());

            SObject sObjInstance = Schema.getGlobalDescribe().get(sObjectType).newSObject();
            try{

                HTTP http = new http();
                HTTPResponse response = new HTTPResponse();
                
                if(Test.isRunningTest() == false) {

                    response = http.send(request);

                } else {
                    
                    if(request.getEndpoint().contains('savings') == true) {

                        if(Integer.valueOf(request.getbody().substringBetween('"current_balance" : ', ',')) > 100) {
                            
                            response.setStatus('OK');
                            response.setBody('{"data": {"id": "772285","type": "savings","links": {"self": "/api/v1/savings/772285"},'+
                                        '"attributes": {"current-balance": 1000.0,"annual-interest-rate": "16.41",'+
                                        '"minimum-percentage-principle": "20.0","minimum-payment": 200.0,"total-savings": 271.0,'+
                                        '"total-months": 18,"total-payments": 1071.0,"absolute-minimum-payment": 15.0}}}');
                        } else {

                            response.setStatus('400');
                            response.setBody('Balance must be greater than 0');
                        } 

                    } else {

                        CalloutException e = (CalloutException)CalloutException.class.newInstance();
                        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
                        throw e;
                    }
                }

                String resp = response.getStatus();
                String body = response.getBody();

                if(resp == 'OK') {

                    JSONParser parser = JSON.createParser(body);
                    
                    while (parser.nextToken() != null) {

                        if(parser.getText() == 'total-months') {

                            parser.nextToken();
                            if (sObjectType == 'nu_dse__Program__c' ) {
                                sObjInstance.put(savingsCalcProgramMappings.get('total-months'), parser.getIntegerValue());
                            } else if (sObjectType == 'nu_dse__Tradeline__c') {
                                sObjInstance.put(savingsCalcTradelineMappings.get('total-months'), parser.getIntegerValue());
                            }
                        }

                        if(parser.getText() == 'total-payments') {

                            parser.nextToken();
                            if (sObjectType == 'nu_dse__Program__c' ) {
                                sObjInstance.put(savingsCalcProgramMappings.get('total-payments'), parser.getDoubleValue());
                            } else if (sObjectType == 'nu_dse__Tradeline__c') {
                                sObjInstance.put(savingsCalcTradelineMappings.get('total-payments'), parser.getDoubleValue());
                            }
                        }

                        if(parser.getText() == 'total-savings') {
                            parser.nextToken();
                            if (sObjectType == 'nu_dse__Program__c' ) {
                                sObjInstance.put(savingsCalcProgramMappings.get('total-savings'), parser.getDoubleValue());
                            } else if (sObjectType == 'nu_dse__Tradeline__c') {
                                sObjInstance.put(savingsCalcTradelineMappings.get('total-savings'), parser.getDoubleValue());
                            }
                        }
                    }
                    if (sObjectType == 'nu_dse__Program__c' ) {
                        sObjInstance.put(savingsCalcProgramMappings.get('error'), '');
                        sObjInstance.put(savingsCalcProgramMappings.get('timestamp'), system.now());
                    } else if (sObjectType == 'nu_dse__Tradeline__c') {
                        sObjInstance.put(savingsCalcTradelineMappings.get('error'), '');
                        sObjInstance.put(savingsCalcTradelineMappings.get('timestamp'), system.now());
                    }
                } else {
                    if (sObjectType == 'nu_dse__Program__c' ) {
                        sObjInstance.put(savingsCalcProgramMappings.get('error'), body);
                        sObjInstance.put(savingsCalcProgramMappings.get('timestamp'), system.now());
                        sObjInstance.put(savingsCalcProgramMappings.get('total-savings'), 0);
                        sObjInstance.put(savingsCalcProgramMappings.get('total-payments'), 0);
                        sObjInstance.put(savingsCalcProgramMappings.get('total-months'), 0);
                    } else if (sObjectType == 'nu_dse__Tradeline__c') {
                        sObjInstance.put(savingsCalcTradelineMappings.get('error'), body);
                        sObjInstance.put(savingsCalcTradelineMappings.get('timestamp'), system.now());
                        sObjInstance.put(savingsCalcTradelineMappings.get('total-savings'), 0);
                        sObjInstance.put(savingsCalcTradelineMappings.get('total-payments'), 0);
                        sObjInstance.put(savingsCalcTradelineMappings.get('total-months'), 0);
                    }
                }

            } catch(CalloutException e){
                if (sObjectType == 'nu_dse__Program__c' ) {
                    sObjInstance.put(savingsCalcProgramMappings.get('error'), e.getTypeName()+ ' ' +e.getMessage());
                    sObjInstance.put(savingsCalcProgramMappings.get('timestamp'), system.now());
                    sObjInstance.put(savingsCalcProgramMappings.get('total-savings'), 0);
                    sObjInstance.put(savingsCalcProgramMappings.get('total-payments'), 0);
                    sObjInstance.put(savingsCalcProgramMappings.get('total-months'), 0);
                } else if (sObjectType == 'nu_dse__Tradeline__c') {
                    sObjInstance.put(savingsCalcTradelineMappings.get('error'), e.getTypeName()+ ' ' +e.getMessage());
                    sObjInstance.put(savingsCalcTradelineMappings.get('timestamp'), system.now());
                    sObjInstance.put(savingsCalcTradelineMappings.get('total-savings'), 0);
                    sObjInstance.put(savingsCalcTradelineMappings.get('total-payments'), 0);
                    sObjInstance.put(savingsCalcTradelineMappings.get('total-months'), 0);
                }
            }            
        return sObjInstance;
    }

    //returns the recordType Id based on developerName 
    public static Id getPaymentRecordTypeId(String recordTypeDeveloperName) {
       return Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get(recordTypeDeveloperName).getRecordTypeId();
    }

    public static SavingCalcSettings getSavingCalcSettings() {

        Savings_Calculator_Microservice__c savingCalcSettings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());
        SavingCalcSettings savingCalcSetting = new SavingCalcSettings();

        if (savingCalcSettings != null) {

            if (String.isNotBlank(savingCalcSettings.Endpoint__c) ) {
                savingCalcSetting.endpoint = savingCalcSettings.Endpoint__c;
            } else {
                savingCalcSetting.endpoint = 'https://beyondfinance.com/api/v1/savings';
            }
            if (savingCalcSettings.InterestRate__c != null && savingCalcSettings.InterestRate__c > 0) {
                savingCalcSetting.interestRate = savingCalcSettings.InterestRate__c;
            } else {
                savingCalcSetting.interestRate = 16.4;  
            }
            if (savingCalcSettings.Minimum_Payment__c != null && savingCalcSettings.Minimum_Payment__c > 0) {
                savingCalcSetting.minimumPaymentPercent = savingCalcSettings.Minimum_Payment__c/100;
            } else {
                savingCalcSetting.minimumPaymentPercent = 0.02;
            }
        } else {

            savingCalcSetting.endpoint = 'https://beyondfinance.com/api/v1/savings';
            savingCalcSetting.interestRate = 16.4;
            savingCalcSetting.minimumPaymentPercent = 0.02;
        }
        return savingCalcSetting;
    }

    //wrapper for Estimated balance calculations
    public class EstimatedMonthBalance{
        Integer monthOrder; 
        Date monthDate;
        Decimal balance;

        public EstimatedMonthBalance(Integer monthOrderParam, Date monthDateParam, Decimal balanceParam) {
            this.monthOrder = monthOrderParam;
            this.monthDate = monthDateParam;
            this.balance = balanceParam;
        }
    }

    //wrapper classes for savings calculations
    public class PaymentCalcWrapper{
        public Map<Id, nu_dse__Program__c> programToUpdateMap = new Map<Id, nu_dse__Program__c>();
        public Map<Id, nu_dse__TradeLine__c> tradelineIdRecMap = new Map<Id, nu_dse__TradeLine__c>();
        public Map<Id, nu_dse__Offer__c> offerIdRecMap = new Map<Id, nu_dse__Offer__c>();
    }

    public class SavingCalcSettings {

        public String endpoint;
        public Double interestRate;
        public Decimal minimumPaymentPercent;
    }

}