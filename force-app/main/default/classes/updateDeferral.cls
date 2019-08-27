/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Script for Data cleanup. Pull all programs created after July 1st 2019, and set the 'Fee Deferral'
* Checkbox to false. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-12
* @modified       2019-08-12
* @systemLayer    One-Time script.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class updateDeferral{
    
    public updateDeferral()
    {
        nu_dse__Program__c[] progs;
    
        progs = [SELECT Program_18_digit_Id__c FROM nu_dse__Program__c WHERE Enrolled_Date__c >= 2019-07-01];
    
        for(nu_dse__Program__c prog : progs)
        {
            prog.Fee_Deferral__c = false;
        }
        update progs;
    }
}