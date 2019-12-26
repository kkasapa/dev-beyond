/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Program 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2017-05-11
* @modified       2019-06-26
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger ProgramTrigger on nu_dse__Program__c (before insert, after insert, before update, after update) {
    new ProgramHandler().run();
}