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
    
    List<nu_dse__Offer__c> offersToUpdate = new List<nu_dse__Offer__c>();
    List<nu_dse__TradeLine__c> TradelinesToUpdate = new List<nu_dse__TradeLine__c>();
    
    public override void afterUpdate()
    {
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
            //update the savings calculation on the offer if tradeline balance changes. 
            if(oldTLMap.get(TLID).nu_dse__Current_Balance__c != newTLMap.get(TLID).nu_dse__Current_Balance__c || oldTLMap.get(TLID).nu_dse__Original_Debt__c != newTLMap.get(TLID).nu_dse__Original_Debt__c)
            {
                List<nu_dse__Offer__c> offers = [SELECT Id FROM nu_dse__Offer__c WHERE nu_dse__TradeLine__c = :TLID];
                for(nu_dse__Offer__c offer : offers)
                {
                    offer.Update_Savings_Calc__c = true;
                    offersToUpdate.add(offer);
                }
            }
        }
        update offersToUpdate;
        update TradelinesToUpdate;
    }
}