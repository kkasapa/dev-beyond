public class AWSTriggerHandler extends IntegrationUtilityClass {

    @future(callout=true)
    public static void splitPdf(String recordId, String uName){
        //create Http Post 
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        
        HttpResponse objResponse = new HttpResponse();
       
        if(objResponse.getStatusCode() == 201){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse.getBody());
            
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = (string)DocObject.get('aws_documentLink');
            AWS.Category__c = (string)DocObject.get('category');
            AWS.Program__c= (string)DocObject.get('clientsProgramId');
            AWS.Content_Type__c= (string)DocObject.get('contentType');
            Aws.File_Name__c= (string)DocObject.get('documentName');
            Aws.Folder__c = (string)DocObject.get('folder');
            AWS.Size__c = (decimal)DocObject.get('size');
            AWS.Bucket__c=(string)DocObject.get('bucket');
            AWS.createdFromAWS__c = true;
            
            insert AWS;
            
        }else{
            createLog(recordId, 'Class: AWSTriggerHandler, Method: splitPdf',uName);
        }
    }
}