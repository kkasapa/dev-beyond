/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on ComvestDataSync after insert
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sai Reddy
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-05-29
* @modified       2019-05-29
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger ComvestDataSyncTrigger on Comvest_Data_Sync__c (after insert, after update) {
  new ComvestDataSyncTriggerHandler().run();
}