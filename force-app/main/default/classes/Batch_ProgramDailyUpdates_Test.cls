@istest
public class Batch_ProgramDailyUpdates_Test {

    @testsetup
    public static void testdata(){
        
        
         Account a = new Account(); 
        a.firstName = 'Test'; 
        a.lastname = 'IDR'; 
        a.Phone = '6784567890'; 
        a.personemail = 'test@idr.com'; 
        a.recordTypeId = [select id from RecordType where sObjectType='Account' and isPersonType=true and DeveloperName='Client' limit 1].id;
        insert a; 
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.nu_dse__Account__c = a.Id; 
        program.nu_dse__In_Settlement__c = false; 
         insert program; 
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>(); 
        
        for (integer i=0; i<10; i++){
            nu_dse__Payment__c p = new nu_dse__Payment__c(); 
            p.nu_dse__Schedule_Date__c = System.date.today(); 
            p.nu_dse__Amount__c = 100.00 ; 
            p.nu_dse__Monthly_Other_Fee__c = 10.00 ; 
            p.nu_dse__Program__c = program.id; 
            p.nu_dse__Transaction_Status__c = 'In Progress'; 
            paymentList.add(p); 
        }
        insert paymentList; 
    }
    
    public static testmethod void batchProgramDayUpdatesTest(){
        
        Test.startTest(); 
           Batch_ProgramDailyUpdates batch = new Batch_ProgramDailyUpdates(); 
           Database.executeBatch(batch);
        Test.stopTest(); 
    }

    static testmethod void schedulerbatchProgramDayUpdatesTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();
            String jobId = System.schedule('Batch_ProgramDailyUpdates',  CRON_EXP, new Batch_ProgramDailyUpdates());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}