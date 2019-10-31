public with sharing class SimulatorController {
    
   @AuraEnabled 
    public static list<nu_dse__Payment__c> getPayments(){
        
        list<nu_dse__Payment__c> Payments = [Select Id,name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,nu_dse__Transaction_Status__c From nu_dse__Payment__c  where nu_dse__Type__c != null and name != null  Limit 10];
        
        return Payments;
    }

}