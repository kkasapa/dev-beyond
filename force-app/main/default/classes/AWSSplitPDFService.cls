@RestResource(urlMapping='/PDFSplitService')

global with Sharing class AWSSplitPDFService {
    @HttpPost
    global static string CreateSplitPDFDocument(){
        string jsonString=RestContext.request.requestBody.toString();
        system.debug('I am jsonString'+jsonString);
        
        Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        AWS_Document__c AWS = New AWS_Document__c();
        AWS.File_Link__c = (string)DocObject.get('aws_documentLink');
        AWS.Category__c = (string)DocObject.get('category');
        AWS.Program__c= (string)DocObject.get('clientsProgramId');
        AWS.Content_Type__c= (string)DocObject.get('contentType');
        Aws.File_Name__c= (string)DocObject.get('documentName');
        Aws.Folder__c = (string)DocObject.get('folder');
        AWS.Size__c = (decimal)DocObject.get('size');
        AWS.Bucket__c=(string)DocObject.get('bucket');
        
        insert AWS;
        return AWS.id;
        
    }

}