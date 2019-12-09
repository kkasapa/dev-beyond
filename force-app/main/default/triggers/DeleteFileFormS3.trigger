trigger DeleteFileFormS3 on AWS_Document__c (before insert,after insert, after delete) {
    string uName = userinfo.getName();
    if(Switch__c.getValues('Swith Off').Turn_Off__c == true){       
        system.debug('I am Fired');        
        if(trigger.isInsert){
            AWSSplitPDFService Aws = New AWSSplitPDFService();           
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            for(AWS_Document__c awsRecord : Trigger.new){
                if(!awsRecord.createdFromAWS__c  && AWS_PDF_Split__c.getValues('Enrollment-Agreement').AWS_PDF_Name_Start__c ==  'AUTHORIZATION-SPAA-Enrollment-Agreement'){
                    AWSTriggerHandler.splitPdf(awsRecord.id,uName);
                }
            }            
        }
    }

     if (Trigger.isDelete) 
     {
         AWS_Credentials_Settings__c settings = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c Limit 1];
         for (AWS_Document__c doc : Trigger.old) 
         {
             system.debug(doc);
             string fullPath = doc.Folder__c + doc.Name.Replace(' ','+');
             string newPath = doc.Folder__c +'Deleted/' + doc.Name.Replace(' ','+');
             S3Service.deleteAndMoveFile(doc.Bucket__c,fullPath,newPath,settings.Key__c ,settings.Secret__c);
                        
         }
     }
}