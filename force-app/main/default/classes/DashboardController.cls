public with sharing class DashboardController {
    public DashboardController() {

    }

    @AuraEnabled
    public static string getSettlementsOutforAuth(Id progId){
        List<TradelineSettlementWrapper> wrapperList = new List<TradelineSettlementWrapper>();
        Map<Id, nu_dse__Tradeline__c> tradelineMap = new Map<Id, nu_dse__Tradeline__c>([SELECT Id, Name, nu_dse__Original_Creditor__r.Name, nu_dse__Original_Debt__c, nu_dse__Current_balance__c 
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE nu_dse__Program__c = :progId]);
        Map<Id, nu_dse__Offer__c> offerMap = new Map<Id, nu_dse__Offer__c>([SELECT Id, Name, nu_dse__Offer_Amount__c 
                                            FROM nu_dse__Offer__c 
                                            WHERE nu_dse__Tradeline__c IN :tradelineMap.keySet() AND nu_dse__Status__c = 'Accepted']);
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, Name, nu_dse__Schedule_Date__c, nu_dse__Amount__c,nu_dse__Total_Amount__c, 
                                                    nu_dse__Offer__r.nu_dse__Tradeline__c, nu_dse__Payment_Sequence_Number__c
                                                    FROM nu_dse__Payment__c WHERE nu_dse__Offer__c IN :offerMap.keySet() and RecordType.Name = 'Settlement' 
                                                    and nu_dse__Transaction_Status__c in ('Pending','Scheduled') order by nu_dse__Schedule_Date__c asc /*LIMIT 1*/];
        for(nu_dse__Payment__c payment : paymentsList) {
            TradelineSettlementWrapper wrapInst = new TradelineSettlementWrapper();
            wrapInst.tradelineName = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).Name;
            wrapInst.paymentName = payment.Name;
            wrapInst.scheduleDate = payment.nu_dse__Schedule_Date__c;
            wrapInst.offerName = offerMap.get(payment.nu_dse__Offer__c).Name;
            wrapInst.paymentAmount = payment.nu_dse__Amount__c;
            wrapInst.paymentTotalAmount = payment.nu_dse__Total_Amount__c;
            wrapInst.paymentSequenceNumber = payment.nu_dse__Payment_Sequence_Number__c;
            wrapInst.originalBalance = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).nu_dse__Original_Debt__c;
            wrapInst.currentBalance = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).nu_dse__Current_Balance__c;
            wrapInst.offerAmount = offerMap.get(payment.nu_dse__Offer__c).nu_dse__Offer_Amount__c;
            wrapperList.add(wrapInst);
        }
        return JSON.serialize(wrapperList);
    }

    @AuraEnabled
    public static string getNewSettlementsfromTradeline(Id progId){
        List<TradelineSettlementWrapper> wrapperList = new List<TradelineSettlementWrapper>();
        Map<Id, nu_dse__Tradeline__c> tradelineMap = new Map<Id, nu_dse__Tradeline__c>([SELECT Id, Name, nu_dse__Original_Creditor__r.Name, nu_dse__Original_Debt__c, nu_dse__Current_balance__c 
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE nu_dse__Program__c = :progId]);
        Map<Id, nu_dse__Offer__c> offerMap = new Map<Id, nu_dse__Offer__c>([SELECT Id, Name, nu_dse__Offer_Amount__c 
                                            FROM nu_dse__Offer__c 
                                            WHERE nu_dse__Tradeline__c IN :tradelineMap.keySet() AND nu_dse__Status__c = 'Pending Client Approval']);
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, Name, nu_dse__Schedule_Date__c, nu_dse__Amount__c,nu_dse__Total_Amount__c, 
                                                    nu_dse__Offer__r.nu_dse__Tradeline__c, nu_dse__Payment_Sequence_Number__c
                                                    FROM nu_dse__Payment__c WHERE nu_dse__Offer__c IN :offerMap.keySet() and RecordType.Name = 'Settlement' 
                                                    and nu_dse__Transaction_Status__c in ('Pending','Scheduled') order by nu_dse__Schedule_Date__c asc /*LIMIT 1*/];
        for(nu_dse__Payment__c payment : paymentsList) {
            TradelineSettlementWrapper wrapInst = new TradelineSettlementWrapper();
            wrapInst.tradelineName = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).Name;
            wrapInst.paymentName = payment.Name;
            wrapInst.scheduleDate = payment.nu_dse__Schedule_Date__c;
            wrapInst.offerName = offerMap.get(payment.nu_dse__Offer__c).Name;
            wrapInst.paymentAmount = payment.nu_dse__Amount__c;
            wrapInst.paymentTotalAmount = payment.nu_dse__Total_Amount__c;
            wrapInst.paymentSequenceNumber = payment.nu_dse__Payment_Sequence_Number__c;
            wrapInst.originalBalance = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).nu_dse__Original_Debt__c;
            wrapInst.currentBalance = tradelineMap.get(payment.nu_dse__Offer__r.nu_dse__Tradeline__c).nu_dse__Current_Balance__c;
            wrapInst.offerAmount = offerMap.get(payment.nu_dse__Offer__c).nu_dse__Offer_Amount__c;
            wrapperList.add(wrapInst);
        }
        return JSON.serialize(wrapperList);
    }

    public class TradelineSettlementWrapper{
        public String tradelineName;
        public Decimal originalBalance;
        public Decimal currentBalance;
        public String offerName;
        public Decimal offerAmount;
        public Integer savingsPercent;
        public Decimal paymentSequenceNumber;
        public String paymentName;
        public Date scheduleDate;
        public Decimal paymentAmount;
        public Decimal paymentTotalAmount;
    }
}