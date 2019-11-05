public with sharing class ProposalController {
    
    @AuraEnabled 
    public static list<nu_dse__Payment__c> getObjects(Id pgmId){
        system.debug('@@@pgmId'+pgmId);
        list<nu_dse__Payment__c> Payments = [Select Id,nu_dse__Transaction_Method__c,name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,nu_dse__Payment_Type__c,nu_dse__Transaction_Status__c From nu_dse__Payment__c  WHERE nu_dse__Program__c =:pgmId];
        system.debug('@@@Payments'+Payments);
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
    public static  List<String> getPgm(Id pgmId) {
        List<String> tradeOptions = new List<String>();
        system.debug('@@@pgmId'+pgmId);
        
        for(nu_dse__TradeLine__c tl : [SELECT Id, Name FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:pgmId])
        {
            tradeOptions.add(tl.Name);
        }
        system.debug('@@@options'+tradeOptions);
        return tradeOptions;        
    }
    
    @AuraEnabled
    public static  List<String> getOffers(Id pgmId) {
        List<String> options = new List<String>();
        for(nu_dse__Offer__c ofrs : [SELECT Id, Name FROM nu_dse__Offer__c WHERE nu_dse__Program__c =:pgmId])
        {
            options.add(ofrs.Name);
        }
        system.debug('@@@options'+options);
        return options;
    }
   
    @AuraEnabled  
    public static List<String> getPickListValuesIntoList(String objectName, String field_apiname){
        system.debug('@@@Imethod'+objectName);
        system.debug('@@@Imethod2'+field_apiname);
        List<String> pickListValuesList = new List<String>();
        
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(field_apiname).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }   
        system.debug('@@@pickListValuesList'+pickListValuesList);
        return pickListValuesList;
    }
    
    
}