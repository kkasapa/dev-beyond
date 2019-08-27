public without sharing class EmailUnsubscriptionController {
    public static Id recId; 
    public nu_dse__Prospect__c prospect {get; set;}
    public EmailUnsubscriptionController() {
        Id recId = ApexPages.currentPage().getParameters().get('id');
        System.debug('recId-'+recId);
        if(String.isNotBlank(recId)){
            if(recId.getSobjectType().getDescribe().getName() == 'nu_dse__Prospect__c') {
                prospect = [SELECT Id, Name, nu_dse__First_Name__c, nu_dse__Last_Name__c, Unsubscribed_from_Emails__c
                            FROM nu_dse__Prospect__c WHERE Id = :recId];
                System.debug('prospect-'+prospect);
            }
        }        
    }

    public void unsubscribe() {
        prospect.Unsubscribed_from_Emails__c = true;
        update prospect;
    }
}