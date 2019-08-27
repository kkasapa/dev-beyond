/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for EnrollmentAgreementDetailsTrigger, extends the Trigger framework. 
*
* After a EA is generated, and a record created in EA details object. This trigger will create EA Tradeline object records.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-08-16
* @modified       2019-08-16
* @systemLayer    Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class EnrollmentAgreementDetailsTriggerHandler extends TriggerHandler{
    private Map<Id, Enrolled_Agreement_Details__c> newEAMap;
    private Map<Id, Enrolled_Agreement_Details__c> oldEAMap;
    List<Enrolled_Agreement_Tradeline__c> EATradelinesToInsert = new List<Enrolled_Agreement_Tradeline__c>();  //EATradelines to be inserted 

    public EnrollmentAgreementDetailsTriggerHandler() {
        this.newEAMap = (Map<Id, Enrolled_Agreement_Details__c>) Trigger.newMap;
        this.oldEAMap = (Map<Id, Enrolled_Agreement_Details__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        for(Enrolled_Agreement_Details__c newEA : (List<Enrolled_Agreement_Details__c>)Trigger.New){
            String t = newEA.Prospect_Lookup__c;
            for(nu_dse__TradeLine__c enrolledTL : [SELECT Id, Name, Current_Creditor_to_merge_in_docs__c, Original_Creditor_to_merge_in_Docs__c, account_number_to_merge_in_docs__c, nu_dse__original_debt__c, nu_dse__Include_In_The_Program__c FROM nu_dse__TradeLine__c WHERE nu_dse__Include_In_The_Program__c = true and nu_dse__Prospect__c = :newEA.Prospect_Lookup__c]){
                
                Enrolled_Agreement_Tradeline__c EAtradeLine = new Enrolled_Agreement_Tradeline__c(
                    Enrolled_Agreement_Details__c = newEA.Id,
                    Tradeline_Id__c = enrolledTL.Id, 
                    Tradeline_Name__c = enrolledTL.Name, Original_Creditor__c = enrolledTL.Original_Creditor_to_merge_in_Docs__c, Current_Creditor__c = enrolledTL.Current_Creditor_to_merge_in_docs__c, Account_Number__c = enrolledTL.account_number_to_merge_in_docs__c, Balance_Owed__c = enrolledTL.nu_dse__original_debt__c, TL_Included_in_Program__c = enrolledTL.nu_dse__Include_In_The_Program__c);

                EATradelinesToInsert.add(EAtradeLine);
            }
        }
        insert EATradelinesToInsert;
    }
}