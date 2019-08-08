public class CSDDashCls {
    	
    @AuraEnabled
    public static CSDDashCls.CSDDashwrap getData(){
    	try { 
        	CSDDashCls.CSDDashwrap wrapObj = new CSDDashCls.CSDDashwrap();             	
           		wrapObj.paymentSavings = 71.41; 
            	wrapObj.pgmLen = '36 Months';
            	wrapObj.paymentSavings = 2570.76;
            	wrapObj.debtSavings = 4379.00;
            	wrapObj.interestSavings = 17537.38;
            	wrapObj.tpgmSavings = 21916.38;
            	wrapObj.timePgmLen = '36 Months';
            	wrapObj.pgmLenWithMinimums = '306 Months';
            	wrapObj.timeSavingspgm = '270 Months';
            	wrapObj.lastPayAmt = 366.99;
            	wrapObj.lastPayDue = '2022-02-23';
            	wrapObj.nextpayAmt = 366.99;
            	wrapObj.nextpayDt = '2019-06-08';
            	wrapObj.CFTactBal = 13502.64;
            return wrapObj;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }    
    }
    
    public class CSDDashwrap{
        @AuraEnabled 
        public decimal paymentSavings{get; set;} 
        @AuraEnabled 
        public string pgmLen{get; set;} 
		@AuraEnabled 
        public decimal tpaySaving{get; set;} 
		@AuraEnabled 
        public decimal debtSavings{get; set;} 
        @AuraEnabled 
        public decimal interestSavings{get; set;} 
		@AuraEnabled 
        public decimal tpgmSavings{get; set;} 
		@AuraEnabled 
        public string timePgmLen{get; set;} 
        @AuraEnabled 
        public string pgmLenWithMinimums{get; set;} 
		@AuraEnabled 
        public string timeSavingspgm{get; set;} 
		@AuraEnabled 
        public decimal lastPayAmt{get; set;} 
        @AuraEnabled 
        public string lastPayDue{get; set;} 
		@AuraEnabled 
        public decimal nextpayAmt{get; set;} 
		@AuraEnabled 
        public string nextpayDt{get; set;} 
		@AuraEnabled 
        public decimal CFTactBal{get; set;}
		
    }
}