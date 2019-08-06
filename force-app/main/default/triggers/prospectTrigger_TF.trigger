/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Prospect
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2018-02-04
* @modified       2019-06-11
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger prospectTrigger_TF on nu_dse__Prospect__c (before insert, before update, after update) {
    
    new ProspectHandler().run();
}