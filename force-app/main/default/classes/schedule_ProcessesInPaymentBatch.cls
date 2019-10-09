public class schedule_ProcessesInPaymentBatch implements Schedulable {
   
    public Integer paddingDays;
    
    public schedule_ProcessesInPaymentBatch() {

        paddingDays = 2;
    }
  
    public schedule_ProcessesInPaymentBatch(Integer paddingDaysCount) {
   
        paddingDays = paddingDaysCount;
    }
    
    public void execute(SchedulableContext sc) {
    
        if(paddingDays == null) {
           
            paddingDays = 2;
        }   
       
        Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(paddingDays, new Set<Id>()); 
        database.executebatch(paymentProcessBatch);
    }
}