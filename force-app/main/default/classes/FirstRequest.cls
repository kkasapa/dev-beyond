public class FirstRequest extends IntegrationUtilityClass implements Queueable,Database.AllowsCallouts {
    private String recordId;
    private String uName;
    
    public FirstRequest(String recordId, String uName) {
        this.recordId = recordId;
        this.uName = uName;
    }
    
    public void execute(QueueableContext context) {         
        
        AWS_Document__c  awsRecord = [SELECT id, Name,File_Link__c,Category__c,Program__c,Content_Type__c,
                     File_Name__c,Folder__c,Size__c,Bucket__c,Program__r.Name 
                     FROM AWS_Document__c 
                     WHERE id =: recordId];
        
        String JSONstr = ''; 
        String pgmName = awsRecord.Program__r.Name; 
        awsWrapper awswrap = new awsWrapper();
        
        awswrap.title = 'Limited Power of Attorney to Speak and Negotiate';
        awswrap.bucket = 'bf-test-salesforce-upload';
        awswrap.sourceFileName = 'Program/' +pgmName+ '/' +pgmName+ '-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf'; 
        awswrap.outputFileName = 'LPA.pdf';
        
        JSONstr = JSON.serialize(awswrap,true);
        System.debug('\n******'+JSONstr +'\n******');
        
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/split-pdf/by-title');
        objHttpRequest.setBody('{"title":"Limited Power of Attorney to Speak and Negotiate","bucket": "bf-test-salesforce-upload","sourceFileName":"Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName":"LPA.pdf"}');
        
        Http http2 = New Http();
       
        HttpResponse objResponse = http2.send(objHttpRequest);
        
        system.debug('objHttpRequest'+objHttpRequest);
        system.debug('objResponse'+objResponse);
        
        if(objResponse.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse.getBody());
            system.debug(DocObject);
            
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = (string)DocObject.get('outputFileUrl');
            Aws.File_Name__c= (string)DocObject.get('outputFileName');
            AWS.Program__c= awsRecord.Program__c;
            Aws.Folder__c = (string)DocObject.get('folder');
            
            AWS.Bucket__c=awsRecord.Bucket__c;
            AWS.Category__c = awsRecord.Category__c;
            AWS.Content_Type__c= awsRecord.Content_Type__c;
            AWS.Size__c = awsRecord.Size__c;
            AWS.createdFromAWS__c = true;
            
            insert AWS;
            
        }else{
            System.debug('Error');
            createLog('awsRecord.Id', 'Class: AWSTriggerHandler, Method: splitPdf',uName);
        }
    }
    
     public class awsWrapper{
        public String title{get;set;}
        public String bucket{get;set;}
        public String sourceFileName{get;set;}
        public String outputFileName{get;set;}
        
        public awsWrapper (){
            title = '';
            bucket = '';
            sourceFileName='';
            outputFileName='';            
        }       
    }
}