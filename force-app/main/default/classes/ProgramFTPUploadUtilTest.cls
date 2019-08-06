@isTest
private class ProgramFTPUploadUtilTest{
  static testmethod void  ProgramUpload(){
     nu_dse__Program__c t=new nu_dse__Program__c();
     t.Prospect_Name__c = 'DailyProgramReport';
     insert t;
     
     attachment att = new attachment();
     att.name  = 'Program.csv';
     att.body = blob.valueof('testbody');
     att.parentid = t.id;
     insert att;
     
     
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
    ProgramFTPUploadUtil.processProgram();
        
    }
}