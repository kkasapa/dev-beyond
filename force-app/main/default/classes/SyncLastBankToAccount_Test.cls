@isTest
public class SyncLastBankToAccount_Test{
    static testMethod void runTest(){
        Account accObj = new Account();
        accObj.name = 'test ';
        insert accObj;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accObj.id;
        System.assertNotEquals(pgm.nu_dse__Account__c, null);
        insert pgm;
                
        nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = pgm.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        trd.nu_dse__Include_In_The_Program__c =true;
        trd.nu_dse__Original_Account_Number__c = '12312312';
        insert trd;
        
        Test.startTest();
        System.assertEquals(pgm.nu_dse__Account__c, accObj.Id);
        
        nu_dse__Bank_Account__c bacct = new nu_dse__Bank_Account__c ();
        bacct.nu_dse__Program__c = pgm.id;
        bacct.nu_dse__Bank_Account_Number__c = '1234567890';
        insert bacct;
        
        
        List<Account> a = [SELECT Id, Last_Bank_Account__c, Masked_Bank_Account_Number__c FROM Account WHERE Id = :bacct.nu_dse__Program__r.nu_dse__Account__c LIMIT 1];
        if(a.size() > 0){       
            String MaskedAcct = String.valueOf(bacct.nu_dse__Bank_Account_Number__c).right(4);
                if(MaskedAcct != null){
                    System.assertEquals(a[0].Masked_Bank_Account_Number__c, MaskedAcct);
                }
            System.assertEquals(a[0].Last_Bank_Account__c, bacct.Id);
        Test.stopTest();
        }
    }
}