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
    }

    public override void afterInsert()
    {
        //Run the savings calculator after offer create
        this.offerIds = trigger.newMap.keySet();
        savingsCalc(offerIds);
    }
        
    public override void afterUpdate() {
    
        this.offerIds = trigger.newMap.keySet();
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
        savingsCalc(OfferstoUpdate);
    }
    
    @future(callout=true)
    public static void savingsCalc(Set<ID> recordIds)
    {   
        List<nu_dse__Offer__c> offers = [SELECT Name,Enrolled_Balance__c FROM nu_dse__Offer__c WHERE Id IN :recordIds];
        Double debt;
        Double payment;
        Double rate;
        SavingsCalcService api = new SavingsCalcService();
        HttpRequest send = new HttpRequest();
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
                System.debug(resp);
                Double saved; 
                
                if (resp != 'OK')
                {
                    newOffer.Savings_Calculation__c = 0;
                    newOffer.Update_Savings_Calc__c = false;
                    update newOffer;
                    //try{
                    //} catch (DmlException e){
                    //process exception
                    //}
                }
                else
                {
                    JSONParser parser = JSON.createParser(body);
                    while (parser.nextToken() != null)
                    {
                        if(parser.getText() == 'total-savings')
                        {
                                parser.nextToken();
                                saved = parser.getDoubleValue();
                                newOffer.Savings_Calculation__c = saved;
                                //try{
                                newOffer.Update_Savings_Calc__c = false;
                            	newOffer.Savings_Calc_Error__c = '';
                                    update newOffer;
                                //} catch (DmlException e){
                                    //process exception
                                //}
                        }
                    }
                }
            }catch(CalloutException e){
                system.debug('whoops');
                newOffer.Savings_Calculation__c = 0;
                newOffer.Update_Savings_Calc__c = false;
                String CalcError = e.getTypeName()+ ' ' +e.getMessage();
                if(CalcError.length() > 255 ){
                	newOffer.Savings_Calc_Error__c = CalcError.substring(0,254);
                }
                else{
                	newOffer.Savings_Calc_Error__c = CalcError;
                }
                update newOffer;
            }
            
        } 
    }
}