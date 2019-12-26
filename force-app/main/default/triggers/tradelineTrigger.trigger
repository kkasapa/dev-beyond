/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on TradeLine before Insert, before Update, after update and after Insert events
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-27
* @modified       2019-11-14
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger tradelineTrigger on nu_dse__TradeLine__c (before Insert, before Update, after Update, after Insert) {
        new TradelineHandler().run();
}