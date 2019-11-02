public class schedule_ProcessesInPaymentBatch implements Schedulable {
   
    public Set<Id> paymentIds;
    public String whereConditionStr;
    
    public schedule_ProcessesInPaymentBatch() {
    }
    public schedule_ProcessesInPaymentBatch(Set<Id> processPaymentIds) {

        paymentIds = new Set<Id>();
        if(processPaymentIds != null 
            && processPaymentIds.isEmpty() == false) {
            
            paymentIds.addAll(processPaymentIds);
        }
    }  

    public schedule_ProcessesInPaymentBatch(String whereCondition) {
        
        if(String.isNotBlank(whereCondition) == true) {
        
            whereConditionStr = whereCondition;
        }
    }

    public void execute(SchedulableContext sc) {

        if(paymentIds != null 
            && paymentIds.isEmpty() == false) {   
            Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(paymentIds); 
            database.executebatch(paymentProcessBatch);
        } else if(String.isNotBlank(whereConditionStr) == true) {
            Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(whereConditionStr); 
            database.executebatch(paymentProcessBatch);
        } else {
            Batch_ProcessesInPayment paymentProcessBatch = new Batch_ProcessesInPayment(''); 
            database.executebatch(paymentProcessBatch);
        }
    }
}