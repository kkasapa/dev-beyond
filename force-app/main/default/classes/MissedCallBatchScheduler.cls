global class MissedCallBatchScheduler implements Schedulable {
  
   global void execute(SchedulableContext SC) {
       Batch_MissedCallsTaskAssignment b = new Batch_MissedCallsTaskAssignment();
            database.executebatch(b,1);
    }
}