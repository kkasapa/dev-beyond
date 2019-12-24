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
    public override void afterInsert() {
        string uName = userinfo.getName();
        Map<String, AWS_PDF_Split__c> csMap = new Map<String, AWS_PDF_Split__c>();
        for(AWS_PDF_Split__c ast : [SELECT id, AWS_PDF_Name_Start__c FROM AWS_PDF_Split__c]){
            csMap.put(ast.AWS_PDF_Name_Start__c, ast);
        }
        for(AWS_Document__c awsRecord : newAWSDocumentMap.values()){
            
            
            if(Switch__c.getValues('Swith Off').Turn_Off__c == true && !awsRecord.createdFromAWS__c){
                system.debug('@csMap'+csMap);
                system.debug('@awsRecord.File_Name__c'+awsRecord.File_Name__c);
                
                
                if(csMap.get(awsRecord.File_Name__c).AWS_PDF_Name_Start__c.startsWith(awsRecord.File_Name__c)){
                    PdfSplitService sf = new PdfSplitService(awsRecord.id,uName);
                    ID jobID = System.enqueueJob(sf);
                } 
                if(csMap.get(awsRecord.File_Name__c).AWS_PDF_Name_Start__c.startsWith(awsRecord.File_Name__c)){
                    if(awsRecord.File_Name__c == csMap.get(awsRecord.File_Name__c).AWS_PDF_Name_Start__c){
                    }
                    // call the BLP Class
                }
                
                
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