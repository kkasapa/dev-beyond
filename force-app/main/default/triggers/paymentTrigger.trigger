/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Payment after update
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-05-16
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger paymentTrigger on nu_dse__Payment__c (before insert, after insert, before update, after update) {
    new PaymentHandler().run();
}