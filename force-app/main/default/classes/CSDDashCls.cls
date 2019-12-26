public class CSDDashCls {
    	
    @AuraEnabled
    public static CSDDashCls.CSDDashwrap getData(string strPgmId){
    	try { 
            
            nu_dse__Program__c pgmObj = [SELECT Id,nu_dse__Account__r.FirstName,Original_Enrolled_Program_Debt__c,nu_dse__Total_Debt_Included__c,
                                         		Current_Draft_Amount__c,nu_dse__Program_Length__c                                         
                                         FROM nu_dse__Program__c WHERE Id =:strPgmId];
        	CSDDashCls.CSDDashwrap wrapObj = new CSDDashCls.CSDDashwrap();             	
           		wrapObj.firstName = pgmObj.nu_dse__Account__r.FirstName; 	
            	wrapObj.OriginalEnrolledProgramDebt = pgmObj.Original_Enrolled_Program_Debt__c; 
            	wrapObj.pgmLen = pgmObj.nu_dse__Program_Length__c+' Months';
            	wrapObj.TotalDebtIncluded = pgmObj.nu_dse__Total_Debt_Included__c;
            	wrapObj.CurrentDraftAmount = pgmObj.Current_Draft_Amount__c;            	
            	
            return wrapObj;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }    
    }
    
    @AuraEnabled
    public static list<CSDDashCls.tradeLinesWrap> getTradeLineData(string strPgmId){
        list<CSDDashCls.tradeLinesWrap> lstOfTradeLines = new list<CSDDashCls.tradeLinesWrap>();
        for(nu_dse__TradeLine__c tradeObj : [SELECT Id,nu_dse__Original_Creditor__r.Name,nu_dse__New_Creditor__r.Name,
                                             		nu_dse__Original_Debt__c,nu_dse__Verified_Balance__c,VerifiedBalance__c,
                                             (SELECT Id,nu_dse__Offer_Amount__c,nu_dse__Program_Fee__c,
                                              nu_dse__Total_Settlement_with_Fee__c,Savings_Percentage__c
                                              FROM nu_dse__Offers__r WHERE nu_dse__Status__c = 'Accepted')
                                             FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:strPgmId]){
        	CSDDashCls.tradeLinesWrap tObj = new CSDDashCls.tradeLinesWrap();
            	tObj.OriginalCreditor = tradeObj.nu_dse__Original_Creditor__r.Name;
            	tObj.NewCreditor = tradeObj.nu_dse__New_Creditor__r.Name;
            	tObj.OriginalBalance = tradeObj.nu_dse__Original_Debt__c;
            	tObj.VerifiedBalance = tradeObj.nu_dse__Verified_Balance__c;
            	tObj.CurrentBalance  = tradeObj.VerifiedBalance__c;
            if(!tradeObj.nu_dse__Offers__r.isEmpty()){
            	nu_dse__Offer__c OffObj = tradeObj.nu_dse__Offers__r[0];   
                tObj.OfferAmount  = OffObj.nu_dse__Offer_Amount__c;
                tObj.ProgramFee  = OffObj.nu_dse__Program_Fee__c;
                tObj.TotalSettlement  = OffObj.nu_dse__Total_Settlement_with_Fee__c;
                tObj.SavingsPercentage  = OffObj.Savings_Percentage__c;
            }
            
            lstOfTradeLines.add(tObj);
        }
    	return lstOfTradeLines;    
    }
    
    public class tradeLinesWrap{
    	@AuraEnabled 
        public string OriginalCreditor{get; set;}
        @AuraEnabled 
        public string NewCreditor{get; set;}
        @AuraEnabled 
        public decimal OriginalBalance{get; set;} 
        @AuraEnabled 
        public decimal VerifiedBalance{get; set;}
        @AuraEnabled 
        public decimal CurrentBalance{get; set;}
        @AuraEnabled 
        public decimal OfferAmount{get; set;} 
        @AuraEnabled 
        public decimal ProgramFee{get; set;}
        @AuraEnabled 
        public decimal TotalSettlement{get; set;}
        @AuraEnabled 
        public decimal SavingsPercentage{get; set;}
    }
    
    public class CSDDashwrap{
        @AuraEnabled 
        public string firstName{get; set;} 
        @AuraEnabled 
        public decimal OriginalEnrolledProgramDebt{get; set;} 
        @AuraEnabled 
        public decimal TotalDebtIncluded{get; set;} 
        @AuraEnabled 
        public decimal CurrentDraftAmount{get; set;} 
        @AuraEnabled 
        public string pgmLen{get; set;}      
    }
    
    
}