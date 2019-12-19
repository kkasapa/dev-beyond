public class SplitFileIntoThree extends IntegrationUtilityClass implements Queueable,Database.AllowsCallouts {
    private String recordId;
    private String uName;
    
    public SplitFileIntoThree(String recordId, String uName) {
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
        splitNodesWrap spNodes = new splitNodesWrap();
        List<splitNodesWrap> spNodesList = new List<splitNodesWrap>();
        
        List<AWS_PDF_Split__c> awsCList = [SELECT id, Name,SearchTitle__c, OutputFileName__c FROM AWS_PDF_Split__c
                                           WHERE Name LIKE 'SplitAuth%' ];
        system.debug('***awsCList'+awsCList);
        /*
awswrap.title = AWS_PDF_Split__c.getValues('SplitAuthEA1').SearchTitle__c;
awswrap.title = AWS_PDF_Split__c.getValues('SplitAuthEA2').SearchTitle__c;
awswrap.title = AWS_PDF_Split__c.getValues('SplitAuthEA3').SearchTitle__c;

awswrap.outputFileName = AWS_PDF_Split__c.getValues('SplitAuthEA1').OutputFileName__c;
awswrap.outputFileName = AWS_PDF_Split__c.getValues('SplitAuthEA2').OutputFileName__c;
awswrap.outputFileName = AWS_PDF_Split__c.getValues('SplitAuthEA3').OutputFileName__c;
*/
        for(Integer i=0;i<awsCList.size();i++){
            spNodes.title = awsCList[i].SearchTitle__c;
            spNodes.outputFileName = awsCList[i].OutputFileName__c;
            spNodesList.add(new splitNodesWrap(spNodes.title,spNodes.outputFileName));
        }  
        awswrap.splitNodes = spNodesList;
        awswrap.bucket = AWS_PDF_Split__c.getValues('SplitAuthEA1').bucket__c;
        awswrap.sourceFileName = AWS_PDF_Split__c.getValues('SplitAuthEA1').sourceFileName__c; 
        
        JSONstr = JSON.serialize(awswrap,true);
        System.debug('\n******'+JSONstr +'\n******');
        
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        //objHttpRequest.setEndpoint('https://ifvde99om7.execute-api.us-east-1.amazonaws.com/dev/split-pdf-by-title');
        objHttpRequest.setEndpoint('https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/documents/pdf/split-by-title/bulk');
        //objHttpRequest.setBody('{"title":"Limited Power of Attorney to Speak and Negotiate","bucket": "bf-test-salesforce-upload","sourceFileName":"Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName":"LPA.pdf"}');
        objHttpRequest.setBody(JSONstr);
        
        //if (test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new UploadFileMock());
        
        Http http1 = New Http();         
        HttpResponse objResponse = http1.send(objHttpRequest);
        system.debug('objResponse1'+objResponse);
        system.debug('objResponse.getBody()'+objResponse.getBody());
        List<AWS_Document__c> aswFList = new List<AWS_Document__c>(); 
        if(objResponse.getStatusCode() == 200){
            System.debug('Success');
            List<ResponseClass> responseList = (List<ResponseClass>)JSON.deserialize(objResponse.getBody(), List<ResponseClass>.class);           
            system.debug(responseList);
            for(Integer i=0;i<responseList.size();i++){
                AWS_Document__c AWS = New AWS_Document__c();
                AWS.File_Link__c = responseList[i].outputFileName;
                Aws.File_Name__c= responseList[i].outputFileUrl;
                AWS.Program__c= awsRecord.Program__c;
                Aws.Folder__c = awsRecord.Folder__c;            
                AWS.Bucket__c=awsRecord.Bucket__c;
                AWS.Category__c = awsRecord.Category__c;
                AWS.Content_Type__c= awsRecord.Content_Type__c;
                AWS.Size__c = awsRecord.Size__c;
                AWS.createdFromAWS__c = true;
                aswFList.add(AWS);
            }
            insert aswFList; 
            
        }else{
            System.debug('Error');
            //createLog(recordId, 'Class: SplitFileIntoThree, Method: execute',uName);
        }    
    }
    
    public class awsWrapper{
        public List<splitNodesWrap> splitNodes;       
        public String bucket{get;set;}
        public String sourceFileName{get;set;}
        
        
        public awsWrapper (){         
            bucket = '';
            sourceFileName='';                 
        }       
    }
    public class splitNodesWrap{
        public String title{get;set;}        
        public String outputFileName{get;set;}  
        
    	public splitNodesWrap(){
       	 title = '';          
         outputFileName='';            
    	}        
        public splitNodesWrap(String t, String o){
            title = t;          
            outputFileName=o;            
        }       
    }
    
    public class ResponseClass{
        public String outputFileName;
        public String outputFileUrl;
    }
}