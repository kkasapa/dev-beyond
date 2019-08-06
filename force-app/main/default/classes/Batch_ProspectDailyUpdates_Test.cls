/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Test Class for Batch class that updates Prospect day field in Prospect. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @modified       2019-06-20
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@istest
public class Batch_ProspectDailyUpdates_Test {

   @testsetup
    public static void testdata(){
                
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
        prospect.nu_dse__Converted__c = False; 
        prospect.UTM_Source__c = 'lendingtree';
        prospect.UTM_Medium__c = 'Affiliate';
        prospect.F9LastDisposition__c = 'Busy';
        prospect.Prospect_Day__c = '0';
        insert prospect;
        
        Test.setCreatedDate(prospect.id, System.dateTime.now().addDays(-1));
    }
    
    public static testmethod void batchProspectDayUpdateTest(){
        
        nu_dse__Prospect__c prospect = [select Prospect_Day__c,CreatedDate from nu_dse__Prospect__c where nu_dse__converted__c = false limit 1];
        System.assertEquals(prospect.Prospect_Day__c, '0');
        System.assertEquals(Prospect.CreatedDate, System.dateTime.now().addDays(-1));
        
        System.test.startTest(); 
        Batch_ProspectDailyUpdates batch = new Batch_ProspectDailyUpdates(); 
        Database.executeBatch(batch);
        System.test.stopTest(); 
        
        prospect = [select Prospect_Day__c,CreatedDate from nu_dse__Prospect__c where nu_dse__converted__c = false limit 1];
        System.assertEquals(prospect.Prospect_Day__c, '1');
    }

    static testmethod void schedulerbatchProgramDayUpdatesTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();
            String jobId = System.schedule('Batch_ProspectDailyUpdates',  CRON_EXP, new Batch_ProspectDailyUpdates());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

}