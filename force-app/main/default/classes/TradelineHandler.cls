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
        this.TLIds = trigger.newMap.keySet();
    }
    
    Set<Id> savignCalcTradelineIds = new Set<Id>();
    // List<nu_dse__Offer__c> offersToUpdate = new List<nu_dse__Offer__c>();
    List<nu_dse__TradeLine__c> TradelinesToUpdate = new List<nu_dse__TradeLine__c>();
    
    public override void afterInsert() {
    
        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {
            
            if(newTradeline.nu_dse__Program__c != null) {
                collectSavingCalcTradelines(newTradeline, null);
            }
            
            if(savignCalcTradelineIds.isEmpty() == false) {

                savingsCalc(savignCalcTradelineIds);
            }
        }
    }
    
    public override void afterUpdate() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectSavingCalcTradelines(newTradeline, oldTLMap.get(newTradeline.Id));
        }

        if(savignCalcTradelineIds.isEmpty() == false) {

            savingsCalc(savignCalcTradelineIds);
        }

        for( Id TLID : TLIds)
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
        }
        // update offersToUpdate;
        update TradelinesToUpdate;
    }

    public void collectSavingCalcTradelines(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {

        if(Trigger.isInsert
            || (newTradeline.nu_dse__Current_Balance__c != oldTradeline.nu_dse__Current_Balance__c
                || ((newTradeline.nu_dse__Current_Balance__c == null || newTradeline.nu_dse__Current_Balance__c == 0)
                    && newTradeline.nu_dse__Original_Debt__c != oldTradeline.nu_dse__Original_Debt__c))) {

            savignCalcTradelineIds.add(newTradeline.Id);
        }
    }

    @future(callout=true)
    public static void savingsCalc(Set<Id> tradlineRecordIds) {   

        List<nu_dse__TradeLine__c> tradelineToUpdateList = new List<nu_dse__TradeLine__c>(); 
        Savings_Calculator_Microservice__c settings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());

        string endpoint;
        double rate;

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
    }
}