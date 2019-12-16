public class SecondRequest extends IntegrationUtilityClass implements Queueable,Database.AllowsCallouts {
    private String recordId;
    private String uName;
    
    public SecondRequest(String recordId, String uName) {
        this.recordId = recordId;
        this.uName = uName;
    }
    
    public void execute(QueueableContext context) {   
        
        AWS_Document__c  awsRecord = [SELECT id, Name,File_Link__c,Category__c,Program__c,Content_Type__c,
                                      File_Name__c,Folder__c,Size__c,Bucket__c,Program__r.Name 
                                      FROM AWS_Document__c 
                                      WHERE id =: recordId];
        
        String JSONstr = ''; 
        //String pgmName = 'P-37682'; //  awsRecord.Program__r.Name; Currently Server system is not accepting
         String pgmName = 'P-38060';
        awsWrapper awswrap = new awsWrapper();
        
        awswrap.page = AWS_PDF_Split__c.getValues('Enrollment-AgmntSec').Page__c;
        awswrap.bucket = AWS_PDF_Split__c.getValues('Enrollment-AgmntSec').bucket__c;
        awswrap.sourceFileName = 'Program/' +pgmName+ '/' +pgmName+ AWS_PDF_Split__c.getValues('Enrollment-AgmntSec').sourceFileName__c; 
        awswrap.outputFileName = AWS_PDF_Split__c.getValues('Enrollment-AgmntSec').OutputFileName__c;
        awswrap.pages = AWS_PDF_Split__c.getValues('Enrollment-AgmntSec').Pages__c;
        
        JSONstr = JSON.serialize(awswrap,true);
        System.debug('\n******'+JSONstr +'\n******');
        
        HttpRequest objHttpRequest2 = new HttpRequest();
        objHttpRequest2.setMethod('POST');
        objHttpRequest2.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest2.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/split-pdf/by-page');
        //objHttpRequest2.setBody('{"page": 5,"bucket": "bf-test-salesforce-upload","sourceFileName": "Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName": "Doc5.pdf","pages": 3}');
        objHttpRequest2.setBody(JSONstr);
        
        Http http = New Http();
        HttpResponse objResponse2 = http.send(objHttpRequest2);       
        system.debug('objResponse2'+objResponse2);
        
        if(objResponse2.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse2.getBody());
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
            createLog(awsRecord.Id, 'Class: SecondRequest, Method: execute',uName);
        }
    }
    public class awsWrapper{
        public Decimal page{get;set;}
        public String bucket{get;set;}
        public String sourceFileName{get;set;}
        public String outputFileName{get;set;}
        public Decimal pages{get;set;}
        
        public awsWrapper (){
            page = 0;
            bucket = '';
            sourceFileName='';
            outputFileName='';  
            pages = 0;
        }       
    }
}