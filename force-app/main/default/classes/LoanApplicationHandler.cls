/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for LoanApplicationTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Le  <ple@beyondfinance.com>
* @modifiedBy     Peter Le  <ple@beyondfinance.com>
* @maintainedBy   Peter Le  <ple@beyondfinance.com>
* @version        1.0
* @created        2019-10-23
* @modified       2019-10-28
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
            updateLoanEstimator(newLoanApplication, oldLoanApplicationMap.get(newLoanApplication.Id));
        }
    }
    
    // Calls Flow to Update Loan Application Record once Loan is Status = "04-Preapproved"
    public void updateLoan(Loan_Application__c newLoanApplication, Loan_Application__c oldLoanApplication){
        if ((newLoanApplication.Application_Status__c == '04-Preapproved' && newLoanApplication.Application_Status__c != oldLoanApplication.Application_Status__c && Trigger.isUpdate)
           || (newLoanApplication.Application_Status__c == '04-Preapproved' && newLoanApplication.Re_Calculate_Loan_Operations_Details__c == true)){
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
    
     // Calls Flow to Update Running Schedule
    public void updateLoanEstimator(Loan_Application__c newLoanApplication, Loan_Application__c oldLoanApplication){
        if (newLoanApplication.Estimated_Funded_Date__c != oldLoanApplication.Estimated_Funded_Date__c && Trigger.isUpdate){
            Map<String, Object> params = new Map<String, Object>();
        	params.put('LoanApplicationId', newLoanApplication.Id);
        	try {
            	Flow.Interview.Loan_Running_Schedule Loan_Running_Schedule = new Flow.Interview.Loan_Running_Schedule(params);
            	Loan_Running_Schedule.start();
        	} catch (Exception e){
            	system.debug('Exception caught: ' + e.getMessage());
        	}
        }
    }    
}