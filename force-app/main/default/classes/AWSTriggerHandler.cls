public class AWSTriggerHandler extends IntegrationUtilityClass {

    @future(callout=true)
    public static void splitPdf(String recordId, String uName){
        //create Http Post 
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/split-pdf/by-title');
        objHttpRequest.setBody('{"title":"Limited Power of Attorney to Speak and Negotiate","bucket": "bf-test-salesforce-upload","sourceFileName":"Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName":"LPA.pdf"}');
        
        Http http = New Http();
        HttpResponse objResponse = http.send(objHttpRequest);
       
        if(objResponse.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse.getBody());
            system.debug(DocObject);
            
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = (string)DocObject.get('outputFileUrl');
            AWS.Category__c = (string)DocObject.get('category');
            AWS.Program__c= (string)DocObject.get('clientsProgramId');
            AWS.Content_Type__c= (string)DocObject.get('contentType');
            Aws.File_Name__c= (string)DocObject.get('outputFileName');
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