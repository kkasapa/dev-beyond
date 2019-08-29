public class TradelineRelatedListExtension {
 
    public nu_dse__tradeline__c[] lstOfTradeLines{get;set;}
     
    public TradelineRelatedListExtension (ApexPages.standardController std){
        lstOfTradeLines=new nu_dse__tradeline__c[]{};
        string strPgmId=ApexPages.currentPage().getParameters().get('id');
        if(strPgmId==NULL){
            system.debug('No Id available');
        }
        else{
            for(nu_dse__TradeLine__c tradeObj : [SELECT Id,name,nu_dse__Original_Creditor__r.Name,nu_dse__New_Creditor__r.Name,
                                                nu_dse__Original_Debt__c,nu_dse__Verified_Balance__c,VerifiedBalance__c,
                                                (SELECT Id,nu_dse__Offer_Amount__c,nu_dse__Program_Fee__c,
                                                nu_dse__Total_Settlement_with_Fee__c,Savings_Percentage__c
                                                FROM nu_dse__Offers__r WHERE nu_dse__Status__c = 'Accepted')
                                                FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:strPgmId]){  
            lstOfTradeLines.add(tradeObj);
            }
        }
    }
}