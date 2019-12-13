public with sharing class MultipleCalloutController extends IntegrationUtilityClass{
public String requestLabel1;
    public String requestLabel2;
    public Integer result1 {get;set;} 
    public String result1Body {get;set;} 
    public Integer result2 {get;set;}
    public String result2Body {get;set;} 

public Object startRequestInParallel(){
        // Create continuation with a timeout
        Continuation con = new Continuation(120);
        // Set callback method
        con.continuationMethod='processAllResponses';
        
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/split-pdf/by-title');
        objHttpRequest.setBody('{"title":"Limited Power of Attorney to Speak and Negotiate","bucket": "bf-test-salesforce-upload","sourceFileName":"Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName":"LPA.pdf"}');
        
       this.requestLabel1 = con.addHttpRequest(objHttpRequest); 
    
       system.debug('@@requestLabel1'+requestLabel1);
    
        HttpRequest objHttpRequest2 = new HttpRequest();
        objHttpRequest2.setMethod('POST');
        objHttpRequest2.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest2.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/split-pdf/by-page');
        objHttpRequest2.setBody('{"page": 5,"bucket": "bf-test-salesforce-upload","sourceFileName": "Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName": "Doc5.pdf","pages": 3}');
        
       this.requestLabel2 = con.addHttpRequest(objHttpRequest2); 
        
        system.debug('@@con'+con);
    	system.debug('@@requestLabel2'+requestLabel2);
        return con;
        
    }
    
    public Object processAllResponses() {
        HttpResponse response1 = Continuation.getResponse(this.requestLabel1);
        system.debug('@@response1'+response1);
        
        this.result1 = response1.getStatusCode();
         system.debug('@@result1'+result1);
        this.result1Body = response1.getBody();
        if(response1.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
            system.debug(DocObject);
            
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = (string)DocObject.get('outputFileUrl');
            Aws.File_Name__c= (string)DocObject.get('outputFileName');
            AWS.Program__c= 'test';
            Aws.Folder__c = (string)DocObject.get('folder');
            
            AWS.Bucket__c='test';
            AWS.Category__c = 'test';
            AWS.Content_Type__c= 'test';
            AWS.Size__c = 2;
            AWS.createdFromAWS__c = true;
            
            insert AWS;
            
        }else{
            System.debug('Error');
            createLog('recordId', 'Class: AWSTriggerHandler, Method: splitPdf','uName');
        }
        
        
        
        // Get the response of the second request
        HttpResponse response2 = Continuation.getResponse(this.requestLabel2);
        this.result2 = response1.getStatusCode();
        system.debug('@@response2'+response2);
        system.debug('@@result2'+result2);
        if(response1.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(response2.getBody());
            system.debug(DocObject);
            
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = (string)DocObject.get('outputFileUrl');
            Aws.File_Name__c= (string)DocObject.get('outputFileName');
            AWS.Program__c= 'test';
            Aws.Folder__c = (string)DocObject.get('folder');
            
            AWS.Bucket__c='test';
            AWS.Category__c = 'test';
            AWS.Content_Type__c= 'test';
            AWS.Size__c = 2;
            AWS.createdFromAWS__c = true;
            
            insert AWS;
            
        }else{
            System.debug('Error');
            createLog('recordId', 'Class: AWSTriggerHandler, Method: splitPdf','uName');
        }
        
        
        
        return null;
        

    }
}