/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Account after insert, after update
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-08-16
* @modified       2019-08-16
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger accountTrigger on Account (after insert, after update) {
    new AccountHandler().run();
}