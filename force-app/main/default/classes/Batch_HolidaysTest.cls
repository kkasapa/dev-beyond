/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* This test class will check the functionality of UpdateMetadataUtil and Schedule_Batch_Holidays
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Avco Team - Karthik Kasapa <kkasapa@beyondfinance.com>
* @created        Nov 2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class Batch_HolidaysTest {   
    static testmethod void test() {        
        test.startTest();
              
        BusinessDays__c settings = BusinessDays__c.getOrgDefaults();        
        settings.Three_Business_Days__c  = null;        
        upsert settings BusinessDays__c.Id;                
        
        Schedule_Batch_Holidays obj = new Schedule_Batch_Holidays();       
        String sch = '0 0 23 * * ?';        
        system.schedule('Test check', sch, obj );   
           
        Test.stopTest();       
    }    
}