/* Date : 12-12-2017
 * Description : To render the all settlement Payments whose Offer.Status is Accepted
 */

global class ActiveSettlementsComponentController {
    
    @RemoteAction
    global static List<SettlementPaymentWrapper> getSettlmentPayments(Id recordId) {
    
        List<SettlementPaymentWrapper> settlementPaymentList = new List<SettlementPaymentWrapper>();
        
        if(recordId != null) {
            
            List<nu_dse__Offer__c> offerList = [SELECT Id, Name, nu_dse__Tradeline__r.nu_dse__Tradeline_Name__c,
                                                    (SELECT Id, Name, nu_dse__Total_Amount__c, nu_dse__Schedule_Date__c,
                                                         nu_dse__Offer__c,nu_dse__Transaction_Method__c
                                                         FROM nu_dse__Payments__r
                                                         WHERE RecordType.DeveloperName = 'Settlement'
                                                         AND nu_dse__Transaction_Status__c = 'Pending'
                                                         ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 1)
                                                    FROM nu_dse__Offer__c 
                                                    WHERE nu_dse__Program__c = :recordId
                                                    AND nu_dse__Status__c = 'Accepted'];
            
            if(offerList.isEmpty() == FALSE) {
            
                for(nu_dse__Offer__c offer : offerList) {
                
                    settlementPaymentList.add(new SettlementPaymentWrapper(offer));
                }
            }
        }
        
        return settlementPaymentList;
    }
    
    global class SettlementPaymentWrapper {
        
        public String name;
        public Id paymentId;
        public String creditorName;
        public Decimal totalAmount;
        public String dateString;
        public string transactionmethod; 
        public Id paymentsOfferId;
        
        public SettlementPaymentWrapper(nu_dse__Offer__c offer) {
            
            List<nu_dse__Payment__c> paymentList = offer.nu_dse__Payments__r;
            
            if(paymentList != null && paymentList.isEmpty() == FALSE) {
                
                this.paymentId = paymentList[0].Id;
                this.name = paymentList[0].Name;
                this.transactionmethod = paymentList[0].nu_dse__Transaction_Method__c; 
                this.creditorName = offer.nu_dse__Tradeline__r.nu_dse__Tradeline_Name__c;
                this.totalAmount = paymentList[0].nu_dse__Total_Amount__c;
                this.paymentsOfferId = paymentList[0].nu_dse__Offer__c;
                
                this.dateString = toDateString(paymentList[0].nu_dse__Schedule_Date__c, 'MM/dd/yyyy');
            }
        }
    }
    
    global static String toDateString(Date scheduleDate, String dateFormat) {
        
        if(scheduleDate != null) {
            
            DateTime dt = DateTime.newInstance(scheduleDate.year(), scheduleDate.month(), scheduleDate.day());
            return dt.format(dateFormat);
        }
        return '';
    }
}