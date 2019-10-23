@isTest 
public class LoanApplicationHandler_Test {
    
    static testmethod void createLoanApptest(){
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        
        insert testProgram;
        
        Loan_Application__c testLoan = new Loan_Application__c();
        testLoan.Application_Status__c = '01-Interested';
        testLoan.Program_Name__c = testProgram.Id;
        insert testLoan;
        
        testLoan.Application_status__c = '04-Preapproved';
        update testLoan;
    }
    
    // Test Calls Flow to Update Loan Application Record once Loan is Status = "04-Preapproved"
    public void updateLoan(Loan_Application__c newLoanApplication, Loan_Application__c oldLoanApplication){
        if (newLoanApplication.Application_Status__c == '04-Preapproved' && newLoanApplication.Application_Status__c != oldLoanApplication.Application_Status__c && Trigger.isUpdate){
            futureFlowCall(newLoanApplication.Id);
        }
    }
    
    // Future Call so that This will run when SF has the time
    @future(callout=true)
    public static void futureFlowCall(string LoanApplicationId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('LoanApplicationId', LoanApplicationId);
        try {
            Flow.Interview.Update_Loan Update_Loan = new Flow.Interview.Update_Loan(params);
            Update_Loan.start();
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }
    
}