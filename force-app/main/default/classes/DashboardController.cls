public with sharing class DashboardController {
    public DashboardController() {

    }

    @AuraEnabled
    public static string getTradelinesandSettlements(){
        
        return '';
    }

    public class TradelineSettlementWrapper{
        public String tradelineName;
        public Decimal originalBalance;
        public Decimal currentBalance;
        public Decimal offerAmount;
        public Integer savingsPercent;
        public Integer paymentSequenceNumber;
        public Decimal paymentAmount;


    }
}