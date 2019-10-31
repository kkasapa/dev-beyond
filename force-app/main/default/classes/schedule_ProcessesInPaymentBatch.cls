public class schedule_ProcessesInPaymentBatch implements Schedulable {
   
    public Integer paddingDays;
    
    public schedule_ProcessesInPaymentBatch() {
    }
      
    public void execute(SchedulableContext sc) {
           
        Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(''); 
        database.executebatch(paymentProcessBatch);
    }
}