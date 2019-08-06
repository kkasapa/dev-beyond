global class OfferStatusComponentController {

    @RemoteAction
    global static List<Offer> getOffer(Id recordId) {
        
        List<nu_dse__Offer__c> records = [SELECT Id, Name, nu_dse__Status__c, nu_dse__Offer_Amount__c, Sub_Status__c,
                                            nu_dse__Program_Fee__c, nu_dse__Number_of_Payments__c, 
                                            nu_dse__Number_of_Fee_payments__c, nu_dse__TradeLine__r.nu_dse__Tradeline_Name__c,
                                            nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c,
                                            nu_dse__TradeLine__r.nu_dse__New_Account_Number__c, nu_dse__TradeLine__c  
                                            FROM nu_dse__Offer__c 
                                            WHERE nu_dse__Program__c = :recordId
                                            AND Sub_Status__c IN ('Out For Authorization', 'Authorization Obtained')
                                            ORDER BY CreatedDate DESC];
        
        List<Offer> offerList = new List<Offer>();
        
        for(nu_dse__Offer__c offer : records) {
            offerList.add(new Offer(offer));
        }
        
        return offerList;
    }
    
    global class Offer {
       public String name;
       public Id recordId;
       public String offerStatus;
       public Decimal offerAmount;
       public Decimal programFee;
       public Integer noOfPayments;
       public Integer noOfFeePayments;
       public String creditorName;
       public String accountNumber;      
       public String offerSubStatus; 
       
       
       global Offer(nu_dse__Offer__c offer) {
           this.name = offer.Name;
           this.recordId = offer.Id;
           this.offerAmount = offer.nu_dse__Offer_Amount__c;
           this.programFee = offer.nu_dse__Program_Fee__c;
           this.noOfPayments = Integer.valueOf(offer.nu_dse__Number_of_Payments__c);
           this.noOfFeePayments = Integer.valueOf(offer.nu_dse__Number_of_Fee_payments__c);
           
           this.offerStatus = offer.nu_dse__Status__c;
           this.offerSubStatus = offer.Sub_Status__c;
           if(offer.nu_dse__TradeLine__c != null) {
           
               this.creditorName = offer.nu_dse__TradeLine__r.nu_dse__Tradeline_Name__c;
               
               if(offer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c != null) {
               
                   this.accountNumber = offer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c;
               } else {
               
                   this.accountNumber = offer.nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c;
               }
           }
       }
    }

}