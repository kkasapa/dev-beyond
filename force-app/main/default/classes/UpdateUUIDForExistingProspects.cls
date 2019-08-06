public class UpdateUUIDForExistingProspects {
    public static void call() {
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, uuid__c FROM nu_dse__Prospect__c WHERE uuid__c = NULL];
        update prospectList;
    }
}