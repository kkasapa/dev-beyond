/* Date : 13-12-2017
 * Description : Schedular to Initiate the Batch_UpdateOfferPaymentsScheduleDate batch class
 */

global class Schedule_UpdateOfferPaymentsBatch implements Schedulable {
    
    global Integer batchSize = 200;
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new Batch_UpdateOfferPaymentsScheduleDate(), batchSize);
    }
}