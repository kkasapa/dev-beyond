public with sharing class ProposalController {
    
    @AuraEnabled 
    public static list<nu_dse__Payment__c> getObjects(){
        
        list<nu_dse__Payment__c> Payments = [Select Id,name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,nu_dse__Transaction_Status__c From nu_dse__Payment__c  where nu_dse__Type__c != null and name != null  Limit 10];
        
        return Payments;  
    }
    @AuraEnabled 
    public static List<String> getFieldSet(String sObjectName){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        List<String> fieldSetList = new List<String>();
        FOR(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
            fieldSetList.add(fs.getName() +'####'+fs.getLabel());
        }
        return fieldSetList;
    }
    
    
     @AuraEnabled
    public static List < String >  getPgm(Id pgmId) {
        List < String > options = new list < String > ();
        system.debug('@@@pgmId'+pgmId);
        
        for(nu_dse__TradeLine__c tl : [SELECT Id, Name FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:pgmId])
        {
            options.add(tl.Name);
        }
        system.debug('@@@options'+options);
        return options;
        
    }
    
     @AuraEnabled
    public static nu_dse__TradeLine__c getTradeLine(Id pgmId) {
        return [
            SELECT Id, Name 
            FROM nu_dse__TradeLine__c
            WHERE nu_dse__Program__c =:pgmId
        ][0];
    }
}