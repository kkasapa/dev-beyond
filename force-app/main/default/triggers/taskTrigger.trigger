/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Task 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2017-05-11
* @modified       2019-06-11
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger taskTrigger on Task (before Insert, after insert, before Update, after update) {
    
    new TaskHandler().run();
}