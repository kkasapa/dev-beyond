@isTest
public class schedule_ProcessesInPaymentBatch_Test {

    static testMethod void scheduledWithPaddingTest() {
    
        Test.StartTest();
        
        schedule_ProcessesInPaymentBatch schedulerInst = new schedule_ProcessesInPaymentBatch(2);
        String schCronExp = '0 0 23 * * ?'; 
        system.schedule('Test ProcessesInPaymentBatch Schedule', schCronExp, schedulerInst); 
        
        Test.stopTest(); 
    }
    
    static testMethod void scheduledWithoutPaddingTest() {
    
        Test.StartTest();
        
        schedule_ProcessesInPaymentBatch schedulerInst = new schedule_ProcessesInPaymentBatch(null);
        String schCronExp = '0 0 23 * * ?'; 
        system.schedule('Test ProcessesInPaymentBatch Schedule', schCronExp, schedulerInst); 
        
        Test.stopTest(); 
    }
}