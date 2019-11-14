/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on TradeLine after update and after Insert
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
trigger tradelineTrigger on nu_dse__TradeLine__c (after Update, after Insert) {
        new TradelineHandler().run();
}