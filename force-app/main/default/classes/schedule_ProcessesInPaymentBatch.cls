global class schedule_ProcessesInPaymentBatch implements Schedulable {
   
    global Integer paddingDays;
    
    public schedule_ProcessesInPaymentBatch() {

        paddingDays = 2;
    }
  
    public schedule_ProcessesInPaymentBatch(Integer paddingDaysCount) {
   
        paddingDays = paddingDaysCount;
    }
    
    global void execute(SchedulableContext sc) {
    
        if(paddingDays == null) {
           
            paddingDays = 2;
        }   
       
        Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(paddingDays); 
        database.executebatch(paymentProcessBatch);
    }
}