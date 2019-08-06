trigger SyncLastBankToAccount on nu_dse__Bank_Account__c (after insert, after update) {
    for(nu_dse__Bank_Account__c b : Trigger.New){
        //if(b.nu_dse__Status__c == 'Active'){
         Id acctId = [SELECT Id, nu_dse__Program__r.nu_dse__Account__c FROM nu_dse__Bank_Account__c WHERE /*nu_dse__Status__c = 'Active' AND*/ Id = :b.Id ORDER BY LastModifiedDate DESC LIMIT 1].nu_dse__Program__r.nu_dse__Account__c;
         
         if(acctId != null){
             List<Account> acctList = [SELECT Id, Last_Bank_Account__c, Masked_Bank_Account_Number__c FROM Account WHERE id = :acctId LIMIT 1];
                for(Account acct : acctList){
                    if(acctList.size() > 0){
                    acct.Last_Bank_Account__c = b.Id;
                    String MaskedAcct = String.valueOf(b.nu_dse__Bank_Account_Number__c).right(4);
                        if(MaskedAcct != null){
                            acct.Masked_Bank_Account_Number__c = '****'+MaskedAcct;
                        }
                    }
                }
                update acctList;
             }
       //}
    }
}