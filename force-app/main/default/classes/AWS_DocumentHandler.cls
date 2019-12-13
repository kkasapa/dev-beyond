public class AWS_DocumentHandler extends TriggerHandler {       
    private Map<Id, AWS_Document__c> newAWSDocumentMap;
    private Map<Id, AWS_Document__c> oldAWSDocumentMap;
    private Set<Id> prospectIds;
    private Map<id,String> afterInsertAWSMap;
    
    public AWS_DocumentHandler() {
        this.newAWSDocumentMap = (Map<Id, AWS_Document__c>) Trigger.newMap;
        this.oldAWSDocumentMap = (Map<Id, AWS_Document__c>) Trigger.oldMap;
        afterInsertAWSMap = new Map<id,String>();
    }
   /* 
    public override void beforeInsert() {
        if(Switch__c.getValues('Swith Off').Turn_Off__c == true){       
            system.debug('I am Fired');        
            if(trigger.isInsert){
                AWSSplitPDFService Aws = New AWSSplitPDFService();           
            }
        }    
    }
    */
    
    public override void afterInsert() {
        string uName = userinfo.getName();
        for(AWS_Document__c awsRecord : newAWSDocumentMap.values()){
            if(Switch__c.getValues('Swith Off').Turn_Off__c == true && !awsRecord.createdFromAWS__c  && AWS_PDF_Split__c.getValues('Enrollment-Agreement').AWS_PDF_Name_Start__c ==  'AUTHORIZATION-SPAA-Enrollment-Agreement'){
                system.debug('In AWS Doc Handler');                 
                AWSTriggerHandler.splitPdf(awsRecord.id,uName);               
            }
        }         
    }
    
    public override void afterDelete() {
        AWS_Credentials_Settings__c settings = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c Limit 1];
        for (AWS_Document__c doc : oldAWSDocumentMap.values()) 
        {
            system.debug(doc);
            string fullPath = doc.Folder__c + doc.Name.Replace(' ','+');
            string newPath = doc.Folder__c +'Deleted/' + doc.Name.Replace(' ','+');
            S3Service.deleteAndMoveFile(doc.Bucket__c,fullPath,newPath,settings.Key__c ,settings.Secret__c);
            
        }     
    }
}