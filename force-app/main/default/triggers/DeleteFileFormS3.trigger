trigger DeleteFileFormS3 on AWS_Document__c (after delete) {
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