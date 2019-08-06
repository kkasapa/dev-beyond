/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Offer after update
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-05-16
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger offerTrigger on nu_dse__Offer__c (before Update, after Update) {

    new OfferHandler_TF().run();
}