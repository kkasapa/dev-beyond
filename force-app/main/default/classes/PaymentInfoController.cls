global class PaymentInfoController {
    
    @RemoteAction
    global static PaymentInfo getPaymentsInfo(Id programId) {
        PaymentInfo info = new PaymentInfo();
        
        info.draftPayments= [SELECT COUNT() FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :programId AND RecordType.DeveloperName = 'Draft'];
        info.clearedPayments = [SELECT COUNT() FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :programId AND RecordType.DeveloperName = 'Settlement' AND nu_dse__Transaction_Status__c = 'Cleared'];
        info.completedPayments = [SELECT COUNT() FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :programId AND RecordType.DeveloperName = 'Draft' AND nu_dse__Transaction_Status__c = 'Completed'];
        info.pendingPayments = [SELECT COUNT() FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :programId AND RecordType.DeveloperName = 'Draft' AND nu_dse__Transaction_Status__c = 'Pending'];
        info.failedPayments = [SELECT COUNT() FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :programId AND RecordType.DeveloperName = 'Draft' AND nu_dse__Transaction_Status__c = 'Failed' AND nu_dse__Dont_Consider__c = False];
        
        List<nu_dse__Program__c> pgInfo = [SELECT nu_dse__Payment_Frequency__c, nu_dse__Program_Length__c FROM nu_dse__Program__c WHERE Id = :programId];
        
        if(pgInfo.isEmpty() == false) {
            info.programLength = (Integer) pgInfo[0].nu_dse__Program_Length__c;
            info.paymentFrequency = pgInfo[0].nu_dse__Payment_Frequency__c;
        }
        
        return info;
    }
    
    global class PaymentInfo {
        public Integer programLength;
        public String paymentFrequency;
        public Integer draftPayments;
        public Integer clearedPayments;
        public Integer completedPayments;
        public Integer pendingPayments;
        public Integer failedPayments;
    }
}