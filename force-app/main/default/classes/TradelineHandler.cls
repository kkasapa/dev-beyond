/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for tradelineTrigger, extends the TriggerHandler. 
*
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
    
    public override void afterUpdate()
    {
     	for( Id TLID : TLIds)
        {
            if(oldTLMap.get(TLID).nu_dse__Current_Balance__c != newTLMap.get(TLID).nu_dse__Current_Balance__c || oldTLMap.get(TLID).nu_dse__Original_Debt__c != newTLMap.get(TLID).nu_dse__Original_Debt__c)
            {
                List<nu_dse__Offer__c> offers = [SELECT Id FROM nu_dse__Offer__c WHERE nu_dse__TradeLine__c = :TLID];
                for(nu_dse__Offer__c offer : offers)
                {
                    offer.Update_Savings_Calc__c = true;
                    update offer;
                }
            }
        }
    }
}