/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for AttachmentTrigger, extends the Trigger framework. 
*
* After an attachment is saved on a Program, copy the attachment to AWS bucket/folder.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-04-08
* @modified       2019-04-08
* @systemLayer    Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AttachmentTriggerHandler extends TriggerHandler {
    
    private Map<Id, Attachment> newAttMap;
    private Map<Id, Attachment> oldAttMap;

    public AttachmentTriggerHandler() {
        this.newAttMap = (Map<Id, Attachment>) Trigger.newMap;
        this.oldAttMap = (Map<Id, Attachment>) Trigger.oldMap;
    }

    public override void afterInsert() {
        List<AWS_Document__c> awsDocumentsToAdd = new List<AWS_Document__c>();
        AWS_Credentials_Settings__c setting = getSettings(); 
        
        for(Attachment att : (List<Attachment>)Trigger.New) {
            String ParentIDPrefix = String.valueof(att.ParentId).substring(0,3);
            System.debug('ParentIDPrefix '+ParentIDPrefix);
            if(ParentIDPrefix == 'a0L'){                    //'a0L'prefix is for the object Program. Only attachments of Program are uploaded to AWS. 
                //create instance on AWS Attachment Object
                AWS_Document__c awsDocumentInstance = new AWS_Document__c();
                awsDocumentInstance.Bucket__c = setting.Bucket_Name__c;
                nu_dse__Program__c program = [SELECT Id, Name from nu_dse__Program__c where Id = :att.ParentId];
                String programName = program.Name;
                awsDocumentInstance.Program__c = att.ParentID;
                awsDocumentInstance.File_Link__c = 'Program/'+programName+'/'+programName+'-'+att.Name ;
                awsDocumentInstance.Folder__c = 'Program/'+programName;
                awsDocumentInstance.File_Name__c = att.Name ;
                awsDocumentInstance.Category__c = 'Other';
                awsDocumentInstance.Size__c = Integer.valueOf(att.BodyLength);
                awsDocumentsToAdd.add(awsDocumentInstance);
                //copy file to AWS
                copyAttachmentToAWS(awsDocumentInstance.File_Link__c,att.Body,(awsDocumentInstance.Size__c).intValue(),att.ContentType);
            }
        }
        if(awsDocumentsToAdd.size()>0){
            insert awsDocumentsToAdd;
            System.debug('AWSDocuments created count: '+awsDocumentsToAdd.size());
        }
    }
      
    @future(callout=true)
    public static void copyAttachmentToAWS(string attFileLink, Blob attBlob,Integer attFileSize,String attContentType){
        AWS_Credentials_Settings__c setting = getSettings(); 
        String now = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String host='s3.amazonaws.com';
        String method = 'PUT';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://s3.amazonaws.com/' + attFileLink.replace(' ', '+'));
        req.setHeader('Host', setting.Bucket_Name__c + '.' + host);
        req.setHeader('Content-Length', String.valueOf(attFileSize));
        req.setHeader('Content-type', attContentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', now);
        req.setHeader('x-amz-acl', setting.ACL__c);
        req.setBodyAsBlob(attBlob);
        
        String stringToSign = method+'\n\n' 
            +attContentType + '\n'
            + now +'\nx-amz-acl:'+setting.ACL__c+'\n/'+ setting.Bucket_Name__c +'/'+ attFileLink.replace(' ', '+');
        
        String signed = createSignature(stringToSign,setting.Secret__c);
        String authHeader = 'AWS' + ' ' + setting.Key__c + ':' + signed;
        req.setHeader('Authorization',authHeader);
        
        Http http = new Http();
        if(!Test.isRunningTest()) //added to avoid call out in Test class
            HTTPResponse res = http.send(req);      
    }
    
    private static string createSignature(string canonicalBuffer,String secret){
        string sig;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        sig = EncodingUtil.base64Encode(mac);
        return sig;
    }
        
    private static AWS_Credentials_Settings__c getSettings()
    {
        AWS_Credentials_Settings__c settings = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c];
        return settings;      
    }
}