public class CSDDashClsV2 {
    	
    @AuraEnabled
    public static list<CSDDashClsV2.TableOneDetails> getData(string strPgmId){
    	list<CSDDashClsV2.TableOneDetails> lstOfRetunrData = new list<CSDDashClsV2.TableOneDetails>();
        try { 
            map<string,list<Dashboard_Program__c>> mapOfObjFldsList = new map<string,list<Dashboard_Program__c>>();
            list<Dashboard_Program__c> lstOfDetails = [SELECT Id,Name,Field_API_Name__c,Field_Label__c,Field_Order__c,Object_API_Name__c 
                                                       FROM Dashboard_Program__c Order by Field_Order__c asc];
            for(Dashboard_Program__c dpObj : lstOfDetails){
                list<Dashboard_Program__c> lstOfFlds;
                if(mapOfObjFldsList.ContainsKey(dpObj.Object_API_Name__c)){
                	lstOfFlds = mapOfObjFldsList.get(dpObj.Object_API_Name__c);     
                }else{
                	lstOfFlds = new list<Dashboard_Program__c>();    
                }
                lstOfFlds.add(dpObj);
                mapOfObjFldsList.put(dpObj.Object_API_Name__c,lstOfFlds);
            }
            string strQry;
            for(string strObjName : mapOfObjFldsList.KeySet()){
                strQry = 'SELECT Id,';
                for(Dashboard_Program__c dpObj : mapOfObjFldsList.get(strObjName)){
             		strQry += dpObj.Field_API_Name__c+',';	  	    
                }
                strQry = strQry.substring(0,strQry.length()-1);
                strQry	+= ' FROM '+strObjName+' WHERE Id =:strPgmId';   
            }
            
            sObject sObj = database.query(strQry);
            for(string strObjName : mapOfObjFldsList.KeySet()){
                Schema.SObjectType t = Schema.getGlobalDescribe().get(strObjName); 
                Schema.DescribeSObjectResult r = t.getDescribe();
                for(Dashboard_Program__c dpObj : mapOfObjFldsList.get(strObjName)){
            		Schema.DescribeFieldResult f = r.fields.getMap().get(dpObj.Field_API_Name__c).getDescribe();
                    CSDDashClsV2.TableOneDetails tObj = new CSDDashClsV2.TableOneDetails();	
                        tObj.labelName = dpObj.Field_Label__c;
                    	if (f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.Double || f.getType() == Schema.DisplayType.Integer){
                            tObj.isOpt = true;
                        }else if (f.getType() == Schema.DisplayType.Currency){
                        	tObj.isOpc = true;    
                        }
                        tObj.labelValue = string.valueOf(sObj.get(dpObj.Field_API_Name__c));
                    	 
                    lstOfRetunrData.add(tObj);        
                }    
            }
			
            return lstOfRetunrData;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }    
    }
    
    @AuraEnabled
    public static list<CSDDashClsV2.tradeLinesWrap> getTradeLineData(string strPgmId){        
        list<CSDDashClsV2.tradeLinesWrap> lstOfTradeLines = new list<CSDDashClsV2.tradeLinesWrap>();
        /*
        for(nu_dse__TradeLine__c tradeObj : [SELECT Id,nu_dse__Original_Creditor__r.Name,nu_dse__New_Creditor__r.Name,
                                             		nu_dse__Original_Debt__c,nu_dse__Verified_Balance__c,VerifiedBalance__c,
                                             (SELECT Id,nu_dse__Offer_Amount__c,nu_dse__Program_Fee__c,
                                              nu_dse__Total_Settlement_with_Fee__c,Savings_Percentage__c
                                              FROM nu_dse__Offers__r WHERE nu_dse__Status__c = 'Accepted')
                                             FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:strPgmId]){
        	CSDDashClsV2.tradeLinesWrap tObj = new CSDDashClsV2.tradeLinesWrap();
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
		*/
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
        public string OriginalEnrolledProgramDebt{get; set;} 
        @AuraEnabled 
        public decimal TotalDebtIncluded{get; set;} 
        @AuraEnabled 
        public decimal CurrentDraftAmount{get; set;} 
        @AuraEnabled 
        public string pgmLen{get; set;}      
    }
    
    public class TableOneDetails{
    	@AuraEnabled 
        public string labelName{get; set;} 
        @AuraEnabled 
        public string labelValue{get; set;} 
        @AuraEnabled
        public boolean isOpt{get;set;}
        @AuraEnabled
        public boolean isOpc{get;set;}
        @AuraEnabled
        public boolean isOpd{get;set;}               
    }
    
    
}