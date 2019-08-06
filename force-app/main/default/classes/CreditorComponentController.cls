global class CreditorComponentController {
    
    @RemoteAction
    global static List<Creditor> getCreditors(Id recordId) {
        
        List<Creditor> creditorList = new List<Creditor>();
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Name, nu_dse__Tradeline_Name__c,nu_dse__Current_Balance__c, nu_dse__Original_Creditor__c, nu_dse__Current_Stage__c,
                                                    nu_dse__Sales_Creditor_Name__c, nu_dse__Original_Debt__c, VerifiedBalance__c,
                                                    nu_dse__Original_Creditor__r.Name
                                                    FROM
                                                        nu_dse__Tradeline__c
                                                    WHERE
                                                        nu_dse__Program__c = :recordId
                                                        /*AND
                                                        (nu_dse__Original_Creditor__c = null OR Verified_Balance__c = null)                                                        
                                                        AND
                                                        nu_dse__Include_In_The_Program__c = true */
                                                    ORDER BY CreatedDate DESC];
        
        for(nu_dse__Tradeline__c tradeline : tradelineList) {
            creditorList.add(new Creditor(tradeline));
        }
        
        return creditorList;
    }
    
    
    global class Creditor {
        public String name;
        public Boolean verified = false;
        public String recordId;
        public String salesCreditorName;
        public Decimal originalBalance;
        public Decimal verifiedBalance;
        public String originalCreditor;
        public String currentStage;
        
        public Creditor(nu_dse__Tradeline__c tradeline) {
            
            this.name = tradeline.Name;
            if(tradeline.nu_dse__Tradeline_Name__c != null) {
                this.name = tradeline.nu_dse__Tradeline_Name__c;
            }
        
            this.recordId = tradeline.Id;
            this.salesCreditorName = tradeline.nu_dse__Sales_Creditor_Name__c;
            this.originalBalance = tradeline.nu_dse__Original_Debt__c;
            this.verifiedBalance = tradeline.nu_dse__Current_Balance__c;
            this.currentStage = tradeline.nu_dse__Current_Stage__c;
            
            if(tradeline.nu_dse__Original_Creditor__c != null) {
                this.verified = true;
                this.originalCreditor = tradeline.nu_dse__Original_Creditor__r.Name;
            }
            
            if(tradeline.nu_dse__Current_Stage__c != null) {
                this.name += ' - ' + tradeline.nu_dse__Current_Stage__c;
            }
        }
    }
}