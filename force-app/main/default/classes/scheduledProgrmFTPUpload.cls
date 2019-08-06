global class scheduledProgrmFTPUpload implements Schedulable {
   global String session_Id = UserInfo.getSessionId();
   global void execute(SchedulableContext SC) {
      List<FTP_Uploads__c> lstProgrmFTPUpload = [Select id,name,CurrentSessionId__c,DDPId__c,DeliveryId__c from FTP_Uploads__c where name='ProgramUpload'];
      system.debug('@@ lstProgrmFTPUpload->'+lstProgrmFTPUpload);
      if(lstProgrmFTPUpload != null && !lstProgrmFTPUpload.isEmpty()){
          lstProgrmFTPUpload[0].CurrentSessionId__c = session_Id;
          
          update lstProgrmFTPUpload;
          system.debug('@@ lstProgrmFTPUpload9->'+lstProgrmFTPUpload);
          ProgramFTPUploadUtil.processProgram();
      }
   }
   //scheduledProspFTPUpload obj = new scheduledProspFTPUpload();
   // String sch = '0 48 11 29 10 ?';
   // String jobID = system.schedule('scheduledProspFTPUpload', sch, obj);
}