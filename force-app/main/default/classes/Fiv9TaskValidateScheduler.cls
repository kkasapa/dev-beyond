global class Fiv9TaskValidateScheduler implements Schedulable {
  
   global void execute(SchedulableContext SC) {
       Batch_Fiv9TaskValidate b = new Batch_Fiv9TaskValidate();
            database.executebatch(b,1);
    }
}