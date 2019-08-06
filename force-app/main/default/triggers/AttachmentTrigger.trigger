/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Attachment after insert
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-04-08
* @modified       2019-04-08
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger AttachmentTrigger on Attachment (after insert) {
    new AttachmentTriggerHandler().run();
}