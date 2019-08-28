/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on TradeLine after update
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-27
* @modified       2019-08-27
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger tradelineTrigger on nu_dse__TradeLine__c (after Update) {
        new TradelineHandler().run();
}