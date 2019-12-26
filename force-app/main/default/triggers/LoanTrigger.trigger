/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Trigger on Loans
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Le  <ple@beyondfinance.com>
* @modifiedBy     Peter Le  <ple@beyondfinance.com>
* @maintainedBy   Peter Le  <ple@beyondfinance.com>
* @version        1.0
* @created        2019-10-23
* @modified       2019-10-23
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger LoanTrigger on Loan_Application__c (after insert, before update, after update) {
    new LoanApplicationHandler().run();
}