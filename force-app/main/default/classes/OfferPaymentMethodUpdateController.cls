public with sharing class OfferPaymentMethodUpdateController {
    
    //returns a Wrapper class list that has ancillary fees and settlement payments
    @AuraEnabled
    public static string getPageData(Id offerId){
        
        if(String.isNotBlank(offerId)) {
            AncillaryFeeAndSettlementPaymentsWrap responseWrap = new AncillaryFeeAndSettlementPaymentsWrap();
            nu_dse__Offer__c offer = [SELECT Id, nu_dse__Program__r.nu_dse__Processor__c 
                                        FROM nu_dse__Offer__c WHERE Id =:offerId];

            responseWrap.ancillaryFeesList = [SELECT Id, Name, nu_dse__Developer_Name__c, nu_dse__Transaction_Method_Name__c, nu_dse__Transaction_Method_API_Name__c FROM nu_dse__Ancillary_Fee__c 
                                                                WHERE nu_dse__Processor__c =:offer.nu_dse__Program__r.nu_dse__Processor__c];
            responseWrap.settlementPayments = getsettlementPaymentsList(offerId);
            System.debug('--->'+responseWrap);
            return JSON.serialize(responseWrap);
        } else {
            return null;
        }
    }

    //Updates transaction status of settlements payments underneath the offer
    @AuraEnabled
    public static void updatePaymentTransactionMethod(String paymentListStr){
        try {
            List<nu_dse__Payment__c> settlementPaymentsList = (List<nu_dse__Payment__c>)JSON.deserialize(paymentListStr, List<nu_dse__Payment__c>.class);
            update settlementPaymentsList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //returns list of settlement payments under a particular offer
    public static List<nu_dse__Payment__c> getsettlementPaymentsList(String offerId) { 
        return offerId != null ? [SELECT Id, Name, nu_dse__Amount__c, nu_dse__Schedule_Date__c, nu_dse__CFT_Synced__c,
                                    nu_dse__External_CFT_Id__c, nu_dse__Payment_Type__c,
                                    nu_dse__Total_Amount__c, nu_dse__Transaction_Status__c, nu_dse__Transaction_Method__c 
                                    FROM nu_dse__Payment__c WHERE nu_dse__Offer__c =:offerId] : null;
    }

    //wrapper class for holding page data onload
    public class AncillaryFeeAndSettlementPaymentsWrap{

        List<nu_dse__Ancillary_Fee__c> ancillaryFeesList;
        List<nu_dse__Payment__c> settlementPayments;
    }
}