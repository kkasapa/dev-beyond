@isTest
private class scheduledProgrmFTPUploadTest{
  static testmethod void  testschedule(){
    
     Loop__DDP__c ddp1 = new Loop__DDP__c();
     ddp1.name = 'pftp';
     insert ddp1;
    
     Loop__DDP_Integration_Option__c delivery = new Loop__DDP_Integration_Option__c();
     delivery.name = 'FTP';
     delivery.Loop__DDP__c= ddp1.id;
     insert delivery;
     
     FTP_Uploads__c settings = new FTP_Uploads__c();
     settings.name = 'ProgramUpload';
     settings.DDPId__c = ddp1.id;
     settings.DeliveryId__c = delivery.id;
     settings.CurrentSessionId__c = userinfo.getsessionid();
     insert settings;

        Datetime dt = Datetime.now().addMinutes(1); String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
        system.schedule('Test ScheduledBatchClass', CRON_EXP, new scheduledProgrmFTPUpload());
    }
}