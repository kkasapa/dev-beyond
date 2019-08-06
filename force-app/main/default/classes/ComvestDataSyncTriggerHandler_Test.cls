/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for ComvestDataSyncTriggerHandler
* 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sai Reddy
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-05-29
* @modified       2019-05-29
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class ComvestDataSyncTriggerHandler_Test {
    @testSetup
    static void setup() {
        nu_dse__Program__c pgmObj = new nu_dse__Program__c();
        insert pgmObj;
        
        nu_dse__Payment__c payObj = new nu_dse__Payment__c(
            nu_dse__Program__c = pgmObj.Id,
            nu_dse__Schedule_Date__c = system.today(),
            RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId()
        );
        insert payObj;
        
    }
    
    @isTest
    static void testComvestDataSyncTriggerForBermudaCo() {
        Test.startTest();
        nu_dse__Program__c pgmObj = [SELECT Id,Fee_Deferral__c FROM nu_dse__Program__c LIMIT 1];
        Comvest_Data_Sync__c cdsObj = new Comvest_Data_Sync__c(
            Program__c = pgmObj.Id,
            Sale_Date__c = system.today().addDays(7),
            Sale_To__c = 'BermudaCo',
            Sync_Status__c = 'Pending'
        );
        insert cdsObj;      
        
        pgmObj.Fee_Deferral__c = false;
        update pgmObj;
        cdsObj.Sale_To__c = 'BermudaCo';
        cdsObj.Sync_Status__c = 'Pending';
        cdsObj.Sale_Date__c = system.today().addDays(-7);
        update cdsObj;
        Test.stopTest();
    }
    
    @isTest
    static void testComvestDataSyncTriggerForSPS() {
        Test.startTest();
            nu_dse__Program__c pgmObj = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
            Comvest_Data_Sync__c cdsObj = new Comvest_Data_Sync__c(
                Program__c = pgmObj.Id,
                Sale_Date__c = system.today().addDays(7),
                Sale_To__c = 'SPS_Trust',
                Sync_Status__c = 'Pending'
            );
            insert cdsObj;
        
        Test.stopTest();
        cdsObj.Sale_To__c = 'BermudaCo';
        cdsObj.Sync_Status__c = 'Pending';
        cdsObj.Sale_Date__c = system.today().addDays(-7);
        update cdsObj;
    }
}