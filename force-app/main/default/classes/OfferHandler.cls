/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for OfferTrigger, extends the TriggerHandler. 
*
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-29
* @modified       2019-08-29
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class OfferHandler extends TriggerHandler {
    
    private Map<Id, nu_dse__Offer__c> newOfferMap;
    private Map<Id, nu_dse__Offer__c> oldOfferMap;
    private Set<ID> offerIds;

    public OfferHandler() {
        this.newOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.newMap;
        this.oldOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.oldMap;
        this.offerIds = trigger.newMap.keySet();
    }

    public override void afterInsert()
    {
        //Run the savings calculator after offer create
        savingsCalc(offerIds);
    }
        
    public override void afterUpdate() {
        Set<ID> OfferstoUpdate = new Set<ID>();
        /*run savings calculator ONLY if enrolled balance is changed.
        for( Id offerId : offerIds)
        {
            if(newOfferMap.get(offerId).Update_Savings_Calc__c)
            {
                Set<ID> toUpdate = new Set<ID>();
                toUpdate.add(offerId);
                savingsCalc(toUpdate);    
            }
        }*/
        for (nu_dse__Offer__c newOffer: (List<nu_dse__Offer__c>)Trigger.New) 
        {
        	if(newOffer.Update_Savings_Calc__c)
            {
                OfferstoUpdate.add(newOffer.ID);  
            }
           
        }
        // Updated by Vignesh on 31-10-2019 to fix Future method cannot be called from a future or batch method
        if(OfferstoUpdate.isEmpty() == false) {
            savingsCalc(OfferstoUpdate);
        }
    }
    
 	@future(callout=true)
    public static void savingsCalc(Set<ID> recordIds)
    {   
        //Set up required variables, list of offers to be updated, list of offers to be modified 
        List<nu_dse__Offer__c> offers = [SELECT Name,Enrolled_Balance__c FROM nu_dse__Offer__c WHERE Id IN :recordIds];
        List<nu_dse__Offer__c> offersToUpdate = new List<nu_dse__Offer__c>();
        Double debt;
        Double payment;
        Double rate;
        SavingsCalcService api = new SavingsCalcService();
        HttpRequest send = new HttpRequest();
        System.debug('savings calc');
        
        //extract relevant info, run savings calc, and store value for each offer that triggered.
        for (nu_dse__Offer__c newOffer: offers)
        {
          	debt = newOffer.Enrolled_Balance__c;
            payment = 0.02*debt;
            send = api.BuildQuery(debt, payment);
            HttpResponse response;
            try{
                response = api.sendRequest(send);
                String resp = response.getStatus();
                String body = response.getBody();
                Double saved;
                Integer months;
                Double totalPayment;
                
                if (resp != 'OK')
                {
                    newOffer.Savings_Calculation__c = 0;
                    newOffer.Update_Savings_Calc__c = false;
                    offersToUpdate.add(newOffer);
                }
                else if(resp == 'OK')
                {
                    JSONParser parser = JSON.createParser(body);
                    while (parser.nextToken() != null)
                    {
                        if(parser.getText() == 'total-months')
                        {
                            parser.nextToken();
                            months = parser.getIntegerValue();
                            newOffer.Months_to_Payoff__c = months;
                            system.debug(months);
                        }
                        if(parser.getText() == 'total-payments')
                        {
                        	parser.nextToken();
                        	totalPayment = parser.getDoubleValue();
                            newOffer.Payoff_Amount__c = totalPayment;
                        	system.debug(totalPayment); 
                        }
                        if(parser.getText() == 'total-savings')
                        {
                                parser.nextToken();
                                saved = parser.getDoubleValue();
                                newOffer.Savings_Calculation__c = saved;
                                newOffer.Update_Savings_Calc__c = false;
                            	newOffer.Savings_Calc_Error__c = '';
                            	System.debug(newOffer);
                                offersToUpdate.add(newOffer);
                        }
                    }
                }
            }catch(CalloutException e){
                system.debug('whoops');
                newOffer.Savings_Calculation__c = 0;
                newOffer.Update_Savings_Calc__c = false;
                newOffer.Savings_Calc_Error__c = e.getTypeName()+ ' ' +e.getMessage();
                offersToUpdate.add(newOffer);
            }
            
        }
        update offersToUpdate;
    }
}