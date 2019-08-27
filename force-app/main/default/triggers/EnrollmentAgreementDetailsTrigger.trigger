/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Enrolled_Agreement_Details__c after insert
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-08-16
* @modified       2019-08-16
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger EnrollmentAgreementDetailsTrigger on Enrolled_Agreement_Details__c (after insert) {
    new EnrollmentAgreementDetailsTriggerHandler().run();
}