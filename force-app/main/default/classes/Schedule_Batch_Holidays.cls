/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Schedule Class for Updating Custom Setting field - BusinessDays__c.Three_Business_Days__c
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Avco Team - Karthik Kasapa <kkasapa@beyondfinance.com>
* @created        Nov 2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class Schedule_Batch_Holidays implements Schedulable {
    global void execute(SchedulableContext SC) {
        UpdateThreeBusinessdays.UpdateThreeBdays();
    }
}