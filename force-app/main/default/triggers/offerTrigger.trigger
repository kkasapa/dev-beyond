/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Offer after update
* Creating a new offerHandler Class 08/29/2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Vlad Polotsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-08-20
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger offerTrigger on nu_dse__Offer__c (after Update, after Insert) {
    if(!System.isFuture())
        new OfferHandler().run();
}