public with sharing class ProposalController {
    
    /**
	* Method to retreive the Payment records
	*/
    @AuraEnabled 
    public static list<nu_dse__Payment__c> getPayments(Id pgmId){       
        list<nu_dse__Payment__c> Payments = [SELECT Id,nu_dse__Processor_Fee__c,nu_dse__Transaction_Method__c,
                                             name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,
                                             nu_dse__Payment_Type__c,nu_dse__Transaction_Status__c,nu_dse__Offer__r.nu_dse__TradeLine__r.nu_dse__Tradeline_Name__c,
                                             nu_dse__Offer__r.nu_dse__TradeLine__c,nu_dse__Offer__c
                                             FROM nu_dse__Payment__c  
                                             WHERE nu_dse__Program__c =:pgmId LIMIT 10];
        return Payments;  
    }   
    
    @AuraEnabled 
    public static List<PaymentWrapper> getPaym(Id pgmId){
        system.debug('In Pay Method');
        list<nu_dse__Payment__c> PList = [SELECT Id,nu_dse__Processor_Fee__c,nu_dse__Transaction_Method__c,
                                             name,nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Type__c,
                                             nu_dse__Payment_Type__c,nu_dse__Transaction_Status__c,nu_dse__Offer__r.nu_dse__TradeLine__r.nu_dse__Tradeline_Name__c,
                                             nu_dse__Offer__r.nu_dse__TradeLine__c,nu_dse__Offer__c
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
}