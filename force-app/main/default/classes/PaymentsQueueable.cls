/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Queueable class for update Offer First and Last Creditor Payment Completed Date. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-20
* @modified       2019-10-22
* @description    This Queueable will update Offer First and Last Creditor Payment Completed Date when settlement payment completed/Cleared.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class PaymentsQueueable implements Queueable {

    private List<nu_dse__Offer__c> offersList;
    Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
    Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();

    // query the Offers and related settlement payments based on offerIds. 
    public PaymentsQueueable(Set<Id> offerIds) {
        
        offersList = [SELECT Id, First_Creditor_Payment_Completed_Date__c,
                            (SELECT Id, nu_dse__Schedule_Date__c, nu_dse__Transaction_Status__c, RecordTypeId  
                            FROM nu_dse__Payments__r 
                            WHERE (RecordTypeId = :settlementRecordTypeId OR RecordTypeId = :feeRecordTypeId)
                            ORDER BY nu_dse__Schedule_Date__c)
                        FROM nu_dse__Offer__c 
                        WHERE Id IN :offerIds];

    }

    public void execute(QueueableContext context) {

        Boolean isUpdateOffer;
        List<nu_dse__Error_Log__c> errLogsToInsert = new List<nu_dse__Error_Log__c>();
        List<nu_dse__Offer__c> offerToUpdateList = new List<nu_dse__Offer__c>();
        system.debug('offersList:::'+offersList);
        // Itreate the Offer and Payment. Update the First and Last Creditor Payment Completed Date.
        for (nu_dse__Offer__c offer : offersList) {
            
            isUpdateOffer = false;
            Integer completedPaymentsCount = 0;
            Date firstCompletedPaymentDate;

            if(offer.First_Creditor_Payment_Completed_Date__c == null) {

                for(nu_dse__Payment__c payment : offer.nu_dse__Payments__r) {

                    if(payment.RecordTypeId == settlementRecordTypeId) { 
                       
                       if(payment.nu_dse__Transaction_Status__c == 'Completed'
                            || payment.nu_dse__Transaction_Status__c == 'Cleared'){
                            
                            if(completedPaymentsCount == 0) {
                            
                                offer.First_Creditor_Payment_Completed_Date__c = system.today();
                                firstCompletedPaymentDate = payment.nu_dse__Schedule_Date__c;
                            } else {
                                offer.First_Creditor_Payment_Completed_Date__c = firstCompletedPaymentDate;
                            }
                            isUpdateOffer = true;
                            completedPaymentsCount++;
                        }
                        
                        if(completedPaymentsCount > 1 
                            || (payment.nu_dse__Transaction_Status__c == 'Scheduled'
                                || payment.nu_dse__Transaction_Status__c == 'In Progress')) {
                            break;
                        }
                    }
                }
            }

            if(offer.nu_dse__Payments__r.isEmpty() == false
                && offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1] != null
                && (offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1].nu_dse__Transaction_Status__c == 'Completed'
                    || offer.nu_dse__Payments__r[offer.nu_dse__Payments__r.size() - 1].nu_dse__Transaction_Status__c == 'Cleared')) {

                offer.Last_Payment_Completed_Date__c = system.today();
                isUpdateOffer = true;
            }

            if(isUpdateOffer == true) {

                offerToUpdateList.add(offer);
            } 
        }

        errLogsToInsert.addAll(dmlRecords(offerToUpdateList));
        insert errLogsToInsert;
    }

    public List<nu_dse__Error_Log__c> dmlRecords(List<nu_dse__Offer__c> recordsToUpdateList) {

        List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();
        Integer count = 0;

        for (Database.SaveResult dmlResult: Database.update(recordsToUpdateList, false)) {

            if (dmlResult.isSuccess() == false) {
                nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'PaymentsQueueable.excute',nu_dse__Error_Causing_Record_Id__c = String.valueOf(recordsToUpdateList[count].Id), nu_dse__User_Context__c = UserInfo.getName());

                errLog.nu_dse__Message__c = '';
                for (Database.Error error: dmlResult.getErrors()) {
                    errLog.nu_dse__Message__c += error.getMessage();
                }
                errLogs.add(errLog);
            }
            count++;
        }
        return errLogs;
    }
}