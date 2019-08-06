@isTest
public class Batch_MissedCallsTaskAssignment_Test {
    static testmethod void testdata(){ 
        
        Task t = new task();
         t.subject = 'etet';
         t.status = 'completed';
         t.Five9__Five9ANI__c = '2342342342';
         insert t;

         Account ac = new Account();
         ac.name='testname';
         ac.Phone = '(234) 234-2342';
         insert ac;
         
         nu_dse__Prospect__c p = new nu_dse__Prospect__c();
         p.nu_dse__First_Name__c = 'testfirst';
         p.nu_dse__Last_name__c = 'testlast';
         p.Best_Phone__c = '234242';
         insert p;
                 
         nu_dse__Program__c pr = new nu_dse__Program__c (); 
         pr.nu_dse__Account__c = ac.id;
         insert pr;
        
         test.starttest();
        String cronString = '0 0 9 ? * MON-FRI *';
        
        String jobId = System.schedule('Test Schedule', cronString, new MissedCallBatchScheduler());
       
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];    
        
        System.assertEquals(cronString, ct.CronExpression);
    
        System.assertEquals(0, ct.TimesTriggered);
         test.stoptest();
    
    }
    
    static testmethod void testdata1(){ 
        
         Task t1 = new task();
         t1.subject = 'etet';
         t1.status = 'completed';
         t1.Five9__Five9ANI__c = '234242111';
         insert t1;        
        
         Account ac = new Account();
         ac.name='testname';
         ac.Phone = '(234) 234-2342';
         insert ac;
         
         nu_dse__Prospect__c p = new nu_dse__Prospect__c();
         p.nu_dse__First_Name__c = 'testfirst';
         p.nu_dse__Last_name__c = 'testlast';
         p.Best_Phone__c = '(234) 242-111';
         insert p;
        
         nu_dse__Prospect__c p2 = new nu_dse__Prospect__c();
         p2.nu_dse__First_Name__c = 'testfirst12';
         p2.nu_dse__Last_name__c = 'testlast12';
         p2.Best_Phone__c = '(234) 242-111';
         insert p2;
         
         nu_dse__Program__c pr = new nu_dse__Program__c (); 
         pr.nu_dse__Account__c = ac.id;
         insert pr;
        
        test.starttest();
        
        String cronString = '0 0 9 ? * MON-FRI *';
        
        String jobId = System.schedule('Test Schedule', cronString, new MissedCallBatchScheduler());
       
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];    
        
        System.assertEquals(cronString, ct.CronExpression);
    
        System.assertEquals(0, ct.TimesTriggered);
         test.stoptest();
    
    }
    
    static testmethod void testdata2(){ 
       
         Task t3 = new task();
         t3.subject = 'etet';
         t3.status = 'completed';
         t3.Five9__Five9ANI__c = '21241121234242';
         insert t3;
        
         Account ac = new Account();
         ac.name='testname';
         ac.Phone = '(234) 234-2342';
         insert ac;
         
         nu_dse__Prospect__c p = new nu_dse__Prospect__c();
         p.nu_dse__First_Name__c = 'testfirst';
         p.nu_dse__Last_name__c = 'testlast';
         p.Best_Phone__c = '234242';
         insert p;
        
         nu_dse__Prospect__c p2 = new nu_dse__Prospect__c();
         p2.nu_dse__First_Name__c = 'testfirst12';
         p2.nu_dse__Last_name__c = 'testlast12';
         p2.Best_Phone__c = '(234) 242-111';
         insert p2;
         
         nu_dse__Program__c pr = new nu_dse__Program__c (); 
         pr.nu_dse__Account__c = ac.id;
         insert pr;
        
       test.starttest();
        String cronString = '0 0 9 ? * MON-FRI *';
        
        String jobId = System.schedule('Test Schedule', cronString, new MissedCallBatchScheduler());
       
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];    
        
        System.assertEquals(cronString, ct.CronExpression);
    
        System.assertEquals(0, ct.TimesTriggered);
        test.stoptest();
    
    }
}