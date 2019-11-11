public with sharing class ProposalController {
    
    /**
* Method to retreive the Program records
*/
    
    @AuraEnabled
    public static ProgramWrapper getPgm(Id pgmId){
        nu_dse__Program__c programRec = [SELECT Id,Name,Work_Phone__c,Home_Phone__c,nu_dse__Program_Length__c,Current_Draft_Amount__c,
                                         nu_dse__Program_Status__c,nu_dse__Program_Sub_Status__c,
                                         Cell_Phone__c,Email_Address__c,nu_dse__Account__c,nu_dse__Account__r.PersonMailingAddress
                                         FROM nu_dse__Program__c  
                                         WHERE id =:pgmId LIMIT 1];
        ProgramWrapper pgmWrap = new ProgramWrapper();
        
        pgmWrap.paymRecord = programRec;
        
        Account acc = [SELECT id,Name,PersonMailingStreet,Phone,PersonOtherPostalCode,PersonEmail,PersonMailingCity,PersonMailingState, nu_dse__SSN__c,PersonBirthdate,RecordTypeId FROM Account WHERE id =: programRec.nu_dse__Account__c];
        string recordTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getName();
        
        
        pgmWrap.AccountName = acc.Name;
        pgmWrap.Address = acc.PersonMailingStreet;
        pgmWrap.SSN = acc.nu_dse__SSN__c;
        pgmWrap.Email = acc.PersonEmail;
        pgmWrap.DOB = String.ValueOf(acc.PersonBirthdate);
        pgmWrap.ProcessorType=  recordTypeName;
        pgmWrap.City = acc.PersonMailingCity;
        pgmWrap.ZipCode =  acc.PersonOtherPostalCode;
        pgmWrap.State = acc.PersonMailingState;
        pgmWrap.Phone = acc.Phone;
        system.debug('@@pgmWrap-->'+pgmWrap);
        return pgmWrap;
    }
    
    @AuraEnabled 
    public static List<PaymentWrapper> getPaym(Id pgmId){
        system.debug('In Pay Method');
        list<nu_dse__Payment__c> pList = [SELECT Id,nu_dse__Processor_Fee__c,nu_dse__Transaction_Method__c,
                                          name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,
                                          nu_dse__Payment_Type__c,nu_dse__Transaction_Status__c,nu_dse__Offer__c
                                          FROM nu_dse__Payment__c  
                                          WHERE nu_dse__Program__c =:pgmId ];
        List<PaymentWrapper> pWrapList = new List<PaymentWrapper>();
        
        for(nu_dse__Payment__c pl: PList){
            PaymentWrapper pWrap = new PaymentWrapper();            
            pWrap.paymRecord = pl;
            
            for(nu_dse__Offer__c ofr : [SELECT Id,nu_dse__TradeLine__c FROM nu_dse__Offer__c where id =: pl.nu_dse__Offer__c] ){
                for(nu_dse__TradeLine__c td :  [SELECT Id,nu_dse__Tradeline_Name__c FROM nu_dse__TradeLine__c where id =: ofr.nu_dse__TradeLine__c] ){
                    pWrap.creditor =  td.nu_dse__Tradeline_Name__c;
                }
            }
            pWrapList.add(pWrap);
        }        
        system.debug('@@pWrapList'+pWrapList);
        return pWrapList;        
    }
    
    /**
* Method to retreive the Tradelines
*/     
    @AuraEnabled
    public static List<String> getTradelines(Id pgmId) {
        List<String> tradeLines = new List<String>();        
        
        for(nu_dse__TradeLine__c tLine : [SELECT Id, Name 
                                          FROM nu_dse__TradeLine__c 
                                          WHERE nu_dse__Program__c =:pgmId])
        {
            tradeLines.add(tLine.Name);
        }       
        return tradeLines;        
    }
    
    /**
* Method to retreive the Offers
*/  
    @AuraEnabled
    public static List<String> getOffers(Id pgmId) {        
        List<String> offers = new List<String>();
        
        for(nu_dse__Offer__c offer : [SELECT Id, Name 
                                      FROM nu_dse__Offer__c 
                                      WHERE nu_dse__Program__c =:pgmId])
        {
            offers.add(offer.Name);
        }      
        return offers;
    }
    
    /**
* Method to retreive the PaymentMethods
*/  
    @AuraEnabled  
    public static List<String> getPaymentMethod(String objectName, String field_apiname){        
        List<String> pickListValuesList = new List<String>();        
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(field_apiname).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
    
    public class PaymentWrapper {
        @AuraEnabled
        public nu_dse__Payment__c paymRecord{get;set;}
        @AuraEnabled
        public String creditor{get;set;}       
        
    }
    public class ProgramWrapper {
        @AuraEnabled
        public nu_dse__Program__c paymRecord{get;set;}
        @AuraEnabled
        public String AccountName{get;set;} 
        @AuraEnabled
        public String Address{get;set;} 
        @AuraEnabled
        public String SSN{get;set;} 
        @AuraEnabled
        public String DOB{get;set;} 
        @AuraEnabled
        public String State{get;set;} 
        @AuraEnabled
        public String City{get;set;} 
        @AuraEnabled
        public String ZipCode{get;set;} 
        @AuraEnabled
        public String Email{get;set;} 
         @AuraEnabled
        public String Phone{get;set;} 
        @AuraEnabled
        public String ProcessorType{get;set;} 
        
    }
}