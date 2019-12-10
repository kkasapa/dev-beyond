/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for LoanApplicationTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Le  <ple@beyondfinance.com>
* @modifiedBy     Peter Le  <ple@beyondfinance.com>
* @maintainedBy   Peter Le  <ple@beyondfinance.com>
* @version        1.0
* @created        2019-10-23
* @modified       2019-12-9
  @description	  Updated updateLoan Method by reducing OR statements comparing Status' to checking Active Lending Client.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class LoanApplicationHandler extends TriggerHandler {

    private Map<Id, Loan_Application__c> newLoanApplicationMap;
    private Map<Id, Loan_Application__c> oldLoanApplicationMap;

    public LoanApplicationHandler() {
        this.newLoanApplicationMap = (Map<Id, Loan_Application__c>) Trigger.newMap;
        this.oldLoanApplicationMap = (Map<Id, Loan_Application__c>) Trigger.oldMap;
    }
    
    public override void afterUpdate() {
        System.debug('after update');
        for (Loan_Application__c newLoanApplication : (List<Loan_Application__c>)Trigger.New) {
            // Update Loan Record based on Application Status
            updateLoan(newLoanApplication, oldLoanApplicationMap.get(newLoanApplication.Id));
            // updateLoanEstimator(newLoanApplication, oldLoanApplicationMap.get(newLoanApplication.Id));
        }
    }
    
    // Calls Flow to Update Loan Application Record once Loan is Status = 01-Interested || 02-UW Pending || 04-Preapproved
    public void updateLoan(Loan_Application__c newLoanApplication, Loan_Application__c oldLoanApplication){
        if ((newLoanApplication.Active_Lending_Client__c == true
              && newLoanApplication.Application_Status__c != oldLoanApplication.Application_Status__c)
              || (newLoanApplication.Active_Lending_Client__c == true
                && newLoanApplication.Re_Calculate_Loan_Operations_Details__c == true)){
                    System.debug('before flow');
                    updateLoanCalcs(newLoanApplication.Id);
                }
    }
    
    // Call to run Calculations update.
    public static void updateLoanCalcs(string LoanApplicationId){
        System.debug('flow working');
        Map<String, Object> params = new Map<String, Object>();
        params.put('LoanApplicationId', LoanApplicationId);
        try {
            Flow.Interview.Update_Loan Update_Loan = new Flow.Interview.Update_Loan(params);
            Update_Loan.start();
            System.debug('after flow');
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }   
}