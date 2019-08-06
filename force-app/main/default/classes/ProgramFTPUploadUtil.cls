public class ProgramFTPUploadUtil{
        
    @future(callout=true)
    public static void  processProgram(){
        List<nu_dse__Program__c> lstProgram = [select id,name from nu_dse__program__c  where Prospect_Name__c = 'DailyProgramReport'];
        if(lstProgram != null && !lstProgram.isEmpty()){
            list<attachment> attachments = [select id,Name from attachment where parentid = :lstProgram[0].id];
            string attachIds = '';
            attachIds = string.valueof(attachments[0].Id);
        List<Loop.AdHoc.Attachment> lstattachments = new List<Loop.AdHoc.Attachment>();
        lstattachments.add(new Loop.AdHoc.Attachment(attachments[0].Id, attachments[0].Name, 'csv'));
        system.debug('----attachIds'+attachIds);
            List<FTP_Uploads__c> lstProgramFTPUpload = [Select id,name,CurrentSessionId__c,DDPId__c,DeliveryId__c from FTP_Uploads__c where name='ProgramUpload'];
          if(lstProgramFTPUpload != null && !lstProgramFTPUpload.isEmpty()){
            Loop.loopMessage lm = new Loop.loopMessage();
            lm.sessionId = lstProgramFTPUpload[0].CurrentSessionId__c;
            system.debug('@@ lm.sessionId->'+lm.sessionId);
            Loop.loopMessage.loopMessageRequest objloopMessageRequest = new Loop.loopMessage.loopMessageRequest(
                lstProgram[0].Id, 
                lstProgramFTPUpload[0].DDPId__c,
                new Map<string, string>{
                    'deploy' => lstProgramFTPUpload[0].DeliveryId__c
                }
            );
            objloopMessageRequest.attachments = lstattachments;
            lm.requests.add(objloopMessageRequest);
              system.debug('----lm'+lm);
            lm.sendAllRequests();
            }
        }
    }
}