/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Schedule Class for Updating Metadata field - Business_Days.Business_Days
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