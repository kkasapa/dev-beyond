/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for tradelineTrigger, extends the TriggerHandler. 
* TestClass : SavingsCalcTest
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-27
* @modified       2019-08-27
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class TradelineHandler extends TriggerHandler {
    
    private Map<Id, nu_dse__TradeLine__c> newTLMap;
    private Map<Id, nu_dse__TradeLine__c> oldTLMap;
    private Set<ID> TLIds;

    public TradelineHandler() {
        this.newTLMap = (Map<Id, nu_dse__TradeLine__c>) Trigger.newMap;
        this.oldTLMap = (Map<Id, nu_dse__TradeLine__c>) Trigger.oldMap;
    }
    
    Static Set<Id> savignCalculatedTradelineIds = new Set<Id>();
    Set<Id> savignCalcTradelineIds = new Set<Id>();
    Set<Id> savingCalcUpdateProgramIds = new Set<Id>();
    Map<Id, List<nu_dse__TradeLine__c>> programIdTradelineMap = new Map<Id, List<nu_dse__TradeLine__c>>();
    // List<nu_dse__Offer__c> offersToUpdate = new List<nu_dse__Offer__c>();
    List<nu_dse__TradeLine__c> TradelinesToUpdate = new List<nu_dse__TradeLine__c>();
    Map<Id, nu_dse__Program__c> programsToUpdate = new Map<Id,nu_dse__Program__c>();
    
    public override void afterInsert() {
    
        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {
            
            collectSavingCalcTradelines(newTradeline, null);
        }
        
        if(savignCalcTradelineIds.isEmpty() == false) {

            calculateSavings(savignCalcTradelineIds);
        }
    }
    
    public override void beforeInsert() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectProgramIdsforSettlementOrder(newTradeline, null);
        }

        if(programIdTradelineMap.isEmpty() == false) {

            updateTradelineSettlementOrder();
        }
    }

    public override void beforeUpdate() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectProgramIdsforSettlementOrder(newTradeline, oldTLMap.get(newTradeline.Id));
        }

        if(programIdTradelineMap.isEmpty() == false) {

            updateTradelineSettlementOrder();
        }
    }

    public override void afterUpdate() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectSavingCalcTradelines(newTradeline, oldTLMap.get(newTradeline.Id));
            //on updates on saving calc field, rolling up to Program.
            collectsavingCalcUpdates(newTradeline, oldTLMap.get(newTradeline.Id));
        }

        if(savignCalcTradelineIds.isEmpty() == false) {

            calculateSavings(savignCalcTradelineIds);
        }

        if (savingCalcUpdateProgramIds.isEmpty() == false) {
            aggregateSavingsToProgram();
        } 

        update TradelinesToUpdate;
        update programsToUpdate.values();

        /*for( Id TLID : TLIds)
        {
            //check if the tradeline current stage changed.
            if(oldTLMap.get(TLID).nu_dse__Current_Stage__c != newTLMap.get(TLID).nu_dse__Current_Stage__c && oldTLMap.get(TLID).nu_dse__Current_Stage__c != 'Making Payments' && oldTLMap.get(TLID).nu_dse__Current_Stage__c != 'Settled - Legal' &&  oldTLMap.get(TLID).nu_dse__Current_Stage__c != 'Settled - Non Legal' )
            {
                //if the current stage is making payments, update the tradeline settlement order field
                if(newTLMap.get(TLID).nu_dse__Current_Stage__c == 'Making payments' || newTLMap.get(TLID).nu_dse__Current_Stage__c == 'Settled - Legal' || newTLMap.get(TLID).nu_dse__Current_Stage__c == 'Settled - Non Legal' )
                {
                    List<nu_dse__TradeLine__c> Tradelines = [SELECT Id, Program_Settlement_Order__c FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c = :newTLMap.get(TLID).nu_dse__Program__c ];
                    double biggestNo = 0; 
                    //loop through tradelines, find the biggest settlement order number and set ours to that + 1
                    for(nu_dse__TradeLine__c Tradeline : Tradelines)
                    {
                        if(Tradeline.Program_Settlement_Order__c > biggestNo)
                            biggestNo=Tradeline.Program_Settlement_Order__c;
                    }
                    nu_dse__TradeLine__c updTL = [SELECT Id, Program_Settlement_Order__c FROM nu_dse__TradeLine__c WHERE id = :TLID];
                    updTL.Program_Settlement_Order__c = biggestNo + 1;
                    TradelinesToUpdate.add(updTL);
                }
            }
            /*  Moved Saving calc update to tradeline level           
            //update the savings calculation on the offer if tradeline balance changes. 
            if(oldTLMap.get(TLID).nu_dse__Current_Balance__c != newTLMap.get(TLID).nu_dse__Current_Balance__c || oldTLMap.get(TLID).nu_dse__Original_Debt__c != newTLMap.get(TLID).nu_dse__Original_Debt__c)
            {
                List<nu_dse__Offer__c> offers = [SELECT Id FROM nu_dse__Offer__c WHERE nu_dse__TradeLine__c = :TLID];
                for(nu_dse__Offer__c offer : offers)
                {
                    offer.Update_Savings_Calc__c = true;
                    offersToUpdate.add(offer);
                }
            }*/
        //}
        // update offersToUpdate;
    }

    public void collectProgramIdsforSettlementOrder(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {
        
        Set<String> currentStageSet = new Set<String>{'Settled - Legal', 'Settled - Non Legal', 'Making payments'};
        if(newTradeline.nu_dse__Program__c != null
            && currentStageSet.contains(newTradeline.nu_dse__Current_Stage__c) == true
            && (Trigger.isInsert 
                || (newTradeline.nu_dse__Current_Stage__c != oldTradeline.nu_dse__Current_Stage__c
                    && currentStageSet.contains(oldTradeline.nu_dse__Current_Stage__c) == false))) {
            
            if(programIdTradelineMap.containsKey(newTradeline.nu_dse__Program__c) == false) {
                programIdTradelineMap.put(newTradeline.nu_dse__Program__c, new List<nu_dse__TradeLine__c> {newTradeline});
            } else {
                programIdTradelineMap.get(newTradeline.nu_dse__Program__c).add(newTradeline);
            }
        }
    }

    public void collectSavingCalcTradelines(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {

        if((newTradeline.nu_dse__Current_Balance__c  != null || newTradeline.nu_dse__Original_Debt__c != null
                || newTradeline.nu_dse__Current_Balance__c  != 0 || newTradeline.nu_dse__Original_Debt__c != 0)
                && (Trigger.isInsert 
                    || (savignCalculatedTradelineIds.contains(newTradeline.Id) == false
                        && (newTradeline.nu_dse__Current_Balance__c != oldTradeline.nu_dse__Current_Balance__c
                            || ((newTradeline.nu_dse__Current_Balance__c == null || newTradeline.nu_dse__Current_Balance__c == 0)
                                && newTradeline.nu_dse__Original_Debt__c != oldTradeline.nu_dse__Original_Debt__c))))) {

            savignCalcTradelineIds.add(newTradeline.Id);
            savignCalculatedTradelineIds.add(newTradeline.Id);
        }
    }

    public void collectsavingCalcUpdates(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {

        if(newTradeline.nu_dse__Program__c != null && (Trigger.isInsert
            || (newTradeline.nu_dse__Program__c != oldTradeline.nu_dse__Program__c
                || newTradeline.Savings_Months_to_Payoff__c != oldTradeline.Savings_Months_to_Payoff__c
                || newTradeline.Savings_Payoff_Amount__c != oldTradeline.Savings_Payoff_Amount__c
                || newTradeline.Savings_Calculated_Savings__c != oldTradeline.Savings_Calculated_Savings__c
                || newTradeline.nu_dse__Include_In_The_Program__c != oldTradeline.nu_dse__Include_In_The_Program__c ))) {

            savingCalcUpdateProgramIds.add(newTradeline.nu_dse__Program__c);
        }
    }

    public void updateTradelineSettlementOrder() {

        for(AggregateResult result: [SELECT count(Id) setteledTradelinesCount, nu_dse__Program__c
                                     FROM nu_dse__Tradeline__c
                                     WHERE nu_dse__Program__c IN :programIdTradelineMap.keyset()
                                        AND (nu_dse__Current_Stage__c = 'Settled - Legal' OR nu_dse__Current_Stage__c = 'Settled - Non Legal'
                                            OR nu_dse__Current_Stage__c = 'Making payments')
                                     GROUP BY nu_dse__Program__c]) {

            Id programId = Id.valueOf(String.valueOf(result.get('nu_dse__Program__c')));
            Integer setteledTradelinesCount = Integer.valueOf(result.get('setteledTradelinesCount'));

            for (nu_dse__TradeLine__c newTradeLine : programIdTradelineMap.get(programId)) {

                setteledTradelinesCount++;
                newTradeLine.Program_Settlement_Order__c = setteledTradelinesCount;
            }
            programIdTradelineMap.remove(programId);
        }

        for(Id programId : programIdTradelineMap.keyset()) {

            Integer setteledTradelinesCount = 1;
            for(nu_dse__TradeLine__c newTradeLine : programIdTradelineMap.get(programId)){

                newTradeLine.Program_Settlement_Order__c = setteledTradelinesCount;
                setteledTradelinesCount++;
            }
        }
    }

    public void aggregateSavingsToProgram() {

        for (AggregateResult result: [SELECT sum(Savings_Months_to_Payoff__c) payOffMonthSum, 
                                        sum(Savings_Payoff_Amount__c) payOffAmountSum, 
                                        sum(Savings_Calculated_Savings__c) savingCalcSum , 
                                        nu_dse__Program__c 
                                        FROM nu_dse__Tradeline__c 
                                        WHERE nu_dse__Program__c IN :savingCalcUpdateProgramIds 
                                        AND nu_dse__Include_In_The_Program__c = true
                                        GROUP BY nu_dse__Program__c]) {
           
            Id programId = Id.valueOf(String.valueOf(result.get('nu_dse__Program__c')));
            nu_dse__Program__c program = new nu_dse__Program__c(Id = programId);                    
            if (programsToUpdate.containsKey(programId) == true) {
                program = programsToUpdate.get(programId);
            } 

            program.Savings_Payoff_Amount_TL__c = Integer.valueOf(result.get('payOffAmountSum'));
            program.Savings_Months_to_Payoff_TL__c = Integer.valueOf(result.get('payOffMonthSum'));
            program.Savings_Calculated_Savings_TL__c = Integer.valueOf(result.get('savingCalcSum'));
            program.Savings_Calculation_Timestamp_TL__c = System.now();
            programsToUpdate.put(programId, program);
        }
    }

    @future(callout=true)
    public static void calculateSavings(Set<Id> tradelineIds) {

        /*Savings_Calculator_Microservice__c savingCalcSettings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());
        String endpoint;
        Double interestRate;
        Decimal minimumPaymentPercent;*/
        
        List<nu_dse__TradeLine__c> tradelineToUpdateList = new List<nu_dse__TradeLine__c>(); 

        PaymentsCalcService.SavingCalcSettings savingCalcSetting = PaymentsCalcService.getSavingCalcSettings();

        /*if (savingCalcSettings != null) {
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

        for (nu_dse__TradeLine__c newTradeline : [SELECT Id, Name, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c 
                                                  FROM nu_dse__TradeLine__c WHERE Id IN :tradelineIds]) {
            
            Double debt = 0; 

            if((newTradeline.nu_dse__Current_Balance__c == 0
                || newTradeline.nu_dse__Current_Balance__c == null)
                && newTradeline.nu_dse__Original_Debt__c != null) {

                debt = newTradeline.nu_dse__Original_Debt__c;

            } else if(newTradeline.nu_dse__Current_Balance__c != null) {

                debt = newTradeline.nu_dse__Current_Balance__c;
            }
            
            nu_dse__TradeLine__c tradelineToUpdate = (nu_dse__Tradeline__c)PaymentsCalcService.savingsCalculatorExternalService(
                                                                    savingCalcSetting, debt, 'nu_dse__Tradeline__c');
            tradelineToUpdate.Id = newTradeline.Id;
            tradelineToUpdateList.add(tradelineToUpdate);
        }

        update tradelineToUpdateList;
    }

    /*@future(callout=true)
    public static void savingsCalc(Set<Id> tradlineRecordIds) {   

        List<nu_dse__TradeLine__c> tradelineToUpdateList = new List<nu_dse__TradeLine__c>(); 
        Savings_Calculator_Microservice__c settings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());

        String endpoint;
        Double rate;

        if(settings != null) {
            endpoint = settings.Endpoint__c;
            rate = settings.InterestRate__c;
        }
        if(endpoint == null) {
            endpoint = 'https://beyondfinance.com/api/v1/savings';
            rate = 16.4;           
        }
        
        //extract relevant info, run savings calc, and store value for each offer that triggered.
        for (nu_dse__TradeLine__c newTradeline : [SELECT Id, Name, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c 
                                                  FROM nu_dse__TradeLine__c WHERE Id IN :tradlineRecordIds]) {
            
            double debt = 0, payment = 0; 

            if((newTradeline.nu_dse__Current_Balance__c == 0
                || newTradeline.nu_dse__Current_Balance__c == null)
                && newTradeline.nu_dse__Original_Debt__c != null) {

                debt = newTradeline.nu_dse__Original_Debt__c;

            } else if(newTradeline.nu_dse__Current_Balance__c != null) {

                debt = newTradeline.nu_dse__Current_Balance__c;
            }
            
            payment = 0.02 * debt;

            JSONGenerator requestBodyJson = JSON.createGenerator(true);
            requestBodyJson.writeStartObject();
            requestBodyJson.writeFieldName('data');
            requestBodyJson.writeStartObject();
            requestBodyJson.writeStringField('type', 'savings');
            requestBodyJson.writeFieldName('attributes');
            requestBodyJson.writeStartObject();
            requestBodyJson.writeNumberField('current_balance', debt);
            requestBodyJson.writeNumberField('minimum_payment', payment);
            requestBodyJson.writeNumberField('annual_interest_rate', rate);
            requestBodyJson.writeEndObject();
            requestBodyJson.writeEndObject();
            requestBodyJson.writeEndObject();

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setTimeout(2000);
            request.setHeader('Content-Type','application/vnd.api+json');
            // body = '{"data":{"type":"savings","attributes":{"current_balance":'+ debt +',"minimum_payment":'+ payment +',"annual_interest_rate":"'+ rate +'"}}}';
            request.setBody(requestBodyJson.getAsString());
            system.debug('requestBody-->'+request.getBody());

            nu_dse__TradeLine__c tradelineToUpdate = new nu_dse__TradeLine__c(Id = newTradeline.Id, Savings_Calculation__c = 0);
            try{

                HTTP http = new http();
                HTTPResponse response = http.send(request);
                String resp = response.getStatus();
                String body = response.getBody();
                system.debug('responseStatus-->'+response.getStatus());
                system.debug('responseBody-->'+response.getBody());
                if(resp == 'OK') {

                    JSONParser parser = JSON.createParser(body);
                    
                    while (parser.nextToken() != null) {

                        if(parser.getText() == 'total-months') {

                            parser.nextToken();
                            tradelineToUpdate.Months_to_Payoff__c = parser.getIntegerValue();
                        }

                        if(parser.getText() == 'total-payments') {

                            parser.nextToken();
                            tradelineToUpdate.Payoff_Amount__c = parser.getDoubleValue();
                        }

                        if(parser.getText() == 'total-savings') {
                                parser.nextToken();
                                tradelineToUpdate.Savings_Calculation__c = parser.getDoubleValue();
                        }
                    }
                    tradelineToUpdate.Savings_Calc_Error__c = '';
                    tradelineToUpdate.Saving_Calculation_Timestamp__c = system.now();
                } 
                tradelineToUpdateList.add(tradelineToUpdate);

            } catch(CalloutException e){

                tradelineToUpdate.Savings_Calc_Error__c = e.getTypeName()+ ' ' +e.getMessage();
                tradelineToUpdate.Saving_Calculation_Timestamp__c = system.now();
                tradelineToUpdateList.add(tradelineToUpdate);
            }
            
        }
        update tradelineToUpdateList;
    }*/
    
    public void loanAppCalcUpdate(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {
        
    	if((oldTradeline.Creditor_Payments_Made__c != newTradeline.Creditor_Payments_Made__c
        	|| oldTradeline.Creditor_Payments_Outstanding__c != newTradeline.Creditor_Payments_Outstanding__c
            || oldTradeline.Fees_Collected__c != newTradeline.Fees_Collected__c
            || oldTradeline.Fees_Outstanding__c != newTradeline.Fees_Outstanding__c)
        	&& newTradeline.Loan_Application__c != ''){
                //for (nu_dse__TradeLine__c loanId : [SELECT Loan_Application__c.Id FROM nu_dse__TradeLine__c WHERE Id = newTradeline.Id]){ 
                    //futureFlowCall(newTradeline.Id);
                //}
            }
    }   
}