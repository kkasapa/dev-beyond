/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for OfferTrigger, extends the TriggerHandler. 
*
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-29
* @modified       2019-08-29
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class OfferHandler extends TriggerHandler {
    
    private Map<Id, nu_dse__Offer__c> newOfferMap;
    private Map<Id, nu_dse__Offer__c> oldOfferMap;

    public OfferHandler() {
        this.newOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.newMap;
        this.oldOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.oldMap;
    }

    Set<Id> cancelledOfferIds = new Set<Id>();
	Set<Id> programIdWithLoan = new Set<Id>(); // programIds for Offer Loan Application field update

    public override void afterInsert() {

        //for (nu_dse__Offer__c newOffer : (List<nu_dse__Offer__c>)Trigger.New){
        	//addLoanAppLookup(newOffer, null, programIdWithLoan);
        //}
    }
        
    public override void afterUpdate() {

        for (nu_dse__Offer__c newOffer: (List<nu_dse__Offer__c>)Trigger.New) {

            // To collect the Cancelled offers Ids to delete the related payments 
            collectCancelledOffers(newOffer, oldOfferMap.get(newOffer.Id));
        }
        // Delete Cancelled Offer related Payments
        if(cancelledOfferIds.isEmpty() == false) {
            deletePayments(cancelledOfferIds);        
        }
    }
    // Method to collect the Cancelled offers Ids to delete the related payments 
    public void collectCancelledOffers(nu_dse__Offer__c newOffer, nu_dse__Offer__c oldOffer) {

        if(newOffer.nu_dse__Status__c == '01-Offer Canceled by Negotiator'
            && newOffer.nu_dse__Status__c != oldOffer.nu_dse__Status__c) {
            cancelledOfferIds.add(newOffer.Id);
        }
    }
    
    //delete all payments under cancelled offers
    public void deletePayments(Set<Id> cancelledOfferIds) {
        delete [SELECT Id FROM nu_dse__Payment__c WHERE nu_dse__Offer__c IN :cancelledOfferIds];
    }
    
    // Add Loan 
    public static void addLoanAppLookup(nu_dse__Offer__c newOffer, nu_dse__Offer__c oldOffer, Set<Id> programIdWithLoan){
        
        for (nu_dse__Program__c programId : [SELECT Id, Loan_Application_Status__c 
                                             FROM nu_dse__Program__c WHERE Id IN :programIdWithLoan]){ 
            system.debug('This works 1');
            if(programId.Loan_Application__c != '' && newOffer.Loan_Application__c != ''){
                system.debug('This works 2');
                newOffer.Loan_Application__c = programId.Loan_Application_Status__c;
                update newOffer;
            }
        }
    }    
}