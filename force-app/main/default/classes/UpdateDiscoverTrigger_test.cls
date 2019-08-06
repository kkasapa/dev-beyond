@isTest
private class UpdateDiscoverTrigger_test{
    public static testMethod void discoverTriggerTestMethod(){
      nu_dse__Program__c aa =new nu_dse__Program__c(Discover_Included__c = false);
      insert aa;
    
      nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c(nu_dse__Original_Debt__c = 1231,nu_dse__Original_Account_Number__c ='123456',nu_dse__Include_In_The_Program__c=true,nu_dse__Program__c = aa.id);
      insert trd;
    
      List<nu_dse__TradeLine__c> trdlist1 = new List<nu_dse__TradeLine__c>{ [select id from nu_dse__TradeLine__c where id =:trd.id]};
      for(nu_dse__TradeLine__c td:trdlist1){
        td.nu_dse__Include_In_The_Program__c=false;
      }
      update trdlist1;
     
    }
}