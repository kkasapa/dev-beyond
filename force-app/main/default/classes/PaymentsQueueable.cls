public with sharing class PaymentsQueueable implements Queueable {

    private List<nu_dse__Offer__c> offersList;

    public PaymentsQueueable(Set<Id> offerIds) {
        
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();

        offersList = [SELECT Id, First_Creditor_Payment_Completed_Date__c,
                                                (SELECT Id, nu_dse__Schedule_Date__c, nu_dse__Transaction_Status__c 
                                                FROM nu_dse__Payments__r 
                                                WHERE RecordTypeId = :settlementRecordTypeId
                                                ORDER BY nu_dse__Schedule_Date__c)
                                            FROM nu_dse__Offer__c 
                                            WHERE Id IN :offerIds];

        system.debug('offerList:::'+offersList);

    }

    public void execute(QueueableContext context) {

        Boolean isUpdateOffer;
        List<nu_dse__Offer__c> offerToUpdateList = new List<nu_dse__Offer__c>();
        system.debug('offersList:::'+offersList);

        for (nu_dse__Offer__c offer : offersList) {
            
            isUpdateOffer = false;

            if(offer.First_Creditor_Payment_Completed_Date__c == null) {

                for(nu_dse__Payment__c payment : offer.nu_dse__Payments__r) {

                    if(payment.nu_dse__Transaction_Status__c == 'Completed'
                        || payment.nu_dse__Transaction_Status__c == 'Cleared'){

                        offer.First_Creditor_Payment_Completed_Date__c = payment.nu_dse__Schedule_Date__c;
                        isUpdateOffer = true;
                        break;
                    }
                }
            }

            if(offer.nu_dse__Payments__r.isEmpty() == false
                && offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1] != null
                && (offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1].nu_dse__Transaction_Status__c == 'Completed'
                    || offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1].nu_dse__Transaction_Status__c == 'Cleared')) {

                offer.Last_Creditor_Payment_Completed_Date__c = offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1].nu_dse__Schedule_Date__c;
                isUpdateOffer = true;
            }

            if(isUpdateOffer == true) {

                offerToUpdateList.add(offer);
            } 
        }

        update offerToUpdateList;
    }
}