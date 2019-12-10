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
            Integer previousMonthCount = 1;

            Decimal estimatePreviousPaymentBal; // estimated balance as per the previously processed payment 
            Date estimatePreviousPaymentDate; // estimated date as per the previously processed payment
            Decimal endOfMonthLowestBalance; // lowest balance at the end of the month
            Date endOfMonthLowestBalDate; // date of last payment in the month that has lowest balance at the end
            String paymentMonthIdentifier; // a string identifier for checking the last payment in the month, this id will be same for all payments in a month
            
            if(program.nu_dse__Trust_Account_Balance__c != null) {
                programBal = program.nu_dse__Trust_Account_Balance__c;
                // programLowestAmount = program.nu_dse__Trust_Account_Balance__c; // initially the current balance will be the lowest
                // programLowestDate = system.today(); // start of the calc, lowest amount and date will be current balance and today
                estimatePreviousPaymentBal = program.nu_dse__Trust_Account_Balance__c;  // initially the current balance will be the lowest
            }
            updateProgram.Estimated_Current_Month_Balance__c = programBal;
            estimatePreviousPaymentDate = system.today();
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
                        && estimatePreviousPaymentBal != null 
                        && (endOfMonthLowestBalance == null || estimatePreviousPaymentBal < endOfMonthLowestBalance)) {  
                        
                        endOfMonthLowestBalance = estimatePreviousPaymentBal;
                        endOfMonthLowestBalDate = estimatePreviousPaymentDate;
                        paymentMonthIdentifier = payment.nu_dse__Schedule_Date__c.month() +'-'+ payment.nu_dse__Schedule_Date__c.year();
                    }
                    
                    estimatePreviousPaymentBal = programBal;
                    estimatePreviousPaymentDate = payment.nu_dse__Schedule_Date__c;

                    Integer paymentMonthCount =  system.today().monthsBetween(payment.nu_dse__Schedule_Date__c) + 1; 
                    for(Integer i = previousMonthCount+1; i < paymentMonthCount; i++) {

                        EstimatedMonthBalance previousMonthBal = estdMonthBalanceMap.get(previousMonthCount);
                        estdMonthBalanceMap.put(i, new EstimatedMonthBalance(i, previousMonthBal.monthDate, previousMonthBal.balance));
                    }

                    estdMonthBalanceMap.put(paymentMonthCount, new EstimatedMonthBalance(paymentMonthCount, payment.nu_dse__Schedule_Date__c, programBal));
                    previousMonthCount = paymentMonthCount;
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
            
            if(estimatePreviousPaymentBal != null 
                && (endOfMonthLowestBalance == null || estimatePreviousPaymentBal < endOfMonthLowestBalance)) {
                endOfMonthLowestBalance = estimatePreviousPaymentBal;
                endOfMonthLowestBalDate = estimatePreviousPaymentDate;
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
                                                    OR nu_dse__Transaction_Status__c = 'Cleared'
                                                    OR (nu_dse__Transaction_Status__c = 'Tentative' 
                                                    	AND (nu_dse__Offer__r.nu_dse__Status__c = '03-Offer Approved (Pre-payment setup)' 
                                                        	OR nu_dse__Offer__r.nu_dse__Status__c = '04-Ready for Payment Setup'))) 
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