/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Queueable class to callout AWS Endpoints. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shravan 
* @modifiedBy     
* @maintainedBy   Shravan
* @version        1.0
* @created        2019-12-19
* @modified       2019-12-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class AWS_PdfSplitService implements Queueable,Database.AllowsCallouts {
    private String recordId;
    private String uName;   
        
    public AWS_PdfSplitService(String recordId, String uName) {
        this.recordId = recordId;
        this.uName = uName;
    }
    
    public void execute(QueueableContext context) {         
        AWS_Document__c awsRecord 					= AWS_DocumentUtility.getAws(recordId);
        Set<String>sTitles 	  	  					= new Set<String>();       
        Map<String, Decimal>titleAndPageMap 		= new Map<String, Decimal>();
        Map<String, AWS_PDF_Split__c>titleAndAWSMap = new Map<String, AWS_PDF_Split__c>();
        List<AWS_PDF_Split__c>csList 				= new List<AWS_PDF_Split__c>();
        String AWSPdfNameStart 						= '';
        
        for(AWS_PDF_Split__c ast : [SELECT id,Name, AWS_PDF_Name_Start__c,Page__c,sourceFileName__c,
                                    Bucket__c,OutputFileName__c,SearchTitle__c 
                                    FROM AWS_PDF_Split__c
                                    WHERE Bucket__c!=null]){
                                        sTitles.add(ast.SearchTitle__c);
                                        titleAndPageMap.put(ast.SearchTitle__c,ast.Page__c);
                                        titleAndAWSMap.put(ast.SearchTitle__c,ast);
                                        csList.add(ast);
                                        AWSPdfNameStart = ast.AWS_PDF_Name_Start__c;
                                    }
        
        if(awsRecord.File_Name__c.startsWith(AWSPdfNameStart)){
            system.debug('In splitPDFBulk loop');
            splitPDFBulk(recordId,uName,csList);
        }
        else{
            for(String s : sTitles ){
                system.debug('In else for loop');
                AWS_PDF_Split__c cs = titleAndAWSMap.get(s);
                if(awsRecord.File_Name__c.startsWith(s) && titleAndPageMap.get(s)!=null){ 
                    system.debug('splitPDFByPage');
                    splitPDFByPage(recordId,uName,cs);            
                } else{
                    system.debug('splitPDFByTitle');
                    splitPDFByTitle(recordId,uName,cs);
                }
            } 
        }     
    }
    
    /**
	* This method will callout the AWS EndPoint to Split PDF By Title Single
	*/
    public static void splitPDFByTitle(String recordId, String uName,AWS_PDF_Split__c csAWS){        
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);
        
        String JSONstr = ''; 
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.SplitByTitleSingle splitBytitle = new AWSSchemaClass.SplitByTitleSingle();
        splitBytitle.title 							   = csAWS.SearchTitle__c;
        splitBytitle.bucket 						   = csAWS.bucket__c;
        splitBytitle.sourceFileName 				   = 'Program/' +pgmName+ '/' +pgmName+ csAWS.sourceFileName__c; 
        splitBytitle.outputFileName                    = pgmName + accName+ csAWS.OutputFileName__c;
        
        JSONstr = JSON.serialize(splitBytitle,true);
        String splitByTitleEndPoint = AWS_Endpoints__c.getValues('Split PDF By Title Single').Endpoint_Name__c;
        System.debug('\n******'+JSONstr +'\n******');
        
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        objHttpRequest.setEndpoint(splitByTitleEndPoint);
        objHttpRequest.setBody(JSONstr);
        
        Http http1 = New Http();         
        HttpResponse objResponse = http1.send(objHttpRequest);
        system.debug('objResponse1'+objResponse);
        
        if(objResponse.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse.getBody());
            system.debug(DocObject);
            AWS_Document__c dObj = AWS_DocumentUtility.getSingleResponse(DocObject,awsRecord);
            insert dObj;            
        }else{
            System.debug('Error');
            AWS_DocumentUtility.createLog(recordId, 'Class: FirstRequest, Method: execute',uName);
        }    
    }
    
    /**
	* This method will construct the PDF Split Single by Page
	*/
    public static void splitPDFByPage(String recordId, String uName , AWS_PDF_Split__c csAWS){
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);
        String JSONstr = '';
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.SplitByPageSingle splitByPage = new AWSSchemaClass.SplitByPageSingle();
        splitByPage.page 							 = csAWS.Page__c;
        splitByPage.bucket 							 = csAWS.bucket__c;
        splitByPage.sourceFileName 					 = 'Program/' +pgmName+ '/' +pgmName+ csAWS.sourceFileName__c; 
        splitByPage.outputFileName 					 = pgmName + accName+ csAWS.OutputFileName__c;
        splitByPage.pages 							 = csAWS.Pages__c;
        
        JSONstr = JSON.serialize(splitByPage,true);
        String splitByPageEndPoint = AWS_Endpoints__c.getValues('PDF Split Single by Page').Endpoint_Name__c;
        System.debug('\n******'+JSONstr +'\n******');
        
        HttpRequest objHttpRequest2 = new HttpRequest();
        objHttpRequest2.setMethod('POST');
        objHttpRequest2.setHeader('Content-Type', 'application/json');
        objHttpRequest2.setEndpoint(splitByPageEndPoint);
        objHttpRequest2.setBody(JSONstr);
        
        Http http = New Http();
        HttpResponse objResponse2 = http.send(objHttpRequest2);       
        system.debug('objResponse2'+objResponse2);
        
        if(objResponse2.getStatusCode() == 200){
            System.debug('Success');
            Map<String, Object> DocObject= (Map<String, Object>)JSON.deserializeUntyped(objResponse2.getBody());
            system.debug(DocObject);
            AWS_Document__c dObj = AWS_DocumentUtility.getSingleResponse(DocObject,awsRecord);                   
            insert dObj;            
        }else{
            System.debug('Error');
            AWS_DocumentUtility.createLog(awsRecord.Id, 'Class: SecondRequest, Method: execute',uName);
        }
    }
    /**
	* This method will construct the PDF Split Bulk
	*/
    public static void splitPDFBulk(String recordId, String uName, List<AWS_PDF_Split__c>csList){
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);        
        String JSONstr = '';
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.awsWrapper awswrap 				= new AWSSchemaClass.awsWrapper();
        AWSSchemaClass.splitNodesWrap spNodes   		= new AWSSchemaClass.splitNodesWrap();        
        List<AWSSchemaClass.splitNodesWrap> spNodesList = new List<AWSSchemaClass.splitNodesWrap>();
       // List<AWS_PDF_Split__c> awsCList 				= csList; 
        
        for(Integer i=0;i<csList.size();i++){
            spNodes.title = csList[i].SearchTitle__c;
            spNodes.outputFileName = pgmName + accName+ csList[i].OutputFileName__c;
            spNodesList.add(new AWSSchemaClass.splitNodesWrap(spNodes.title,spNodes.outputFileName));
        }  
        awswrap.splitNodes = spNodesList;
        awswrap.bucket = csList[0].bucket__c;
        awswrap.sourceFileName = 'Program/' +pgmName+ '/' +pgmName+'-'+pgmName+csList[0].sourceFileName__c; 
        
        JSONstr = JSON.serialize(awswrap,true);
        String splitByBulkEndPoint = AWS_Endpoints__c.getValues('PDF Split Bulk').Endpoint_Name__c;
        System.debug('\n******'+JSONstr +'\n******');
                
        HttpRequest objHttpRequest = new HttpRequest();
        objHttpRequest.setMethod('POST');
        objHttpRequest.setHeader('Content-Type', 'application/json');
        objHttpRequest.setEndpoint(splitByBulkEndPoint);
        objHttpRequest.setBody(JSONstr);
        
        Http http1 = New Http();         
        HttpResponse objResponse = http1.send(objHttpRequest);
        system.debug('objResponse1'+objResponse);
        system.debug('objResponse1'+objResponse.getBody());
                
        if(objResponse.getStatusCode() == 200){
            System.debug('Success');            
            List<AWSSchemaClass.ResponseClass> responseList = new List<AWSSchemaClass.ResponseClass>();
            responseList = (List<AWSSchemaClass.ResponseClass>)JSON.deserialize(objResponse.getBody(), List<AWSSchemaClass.ResponseClass>.class);           
            system.debug(responseList);            
            List<AWS_Document__c> aswFList = AWS_DocumentUtility.getBulkResponse(responseList,awsRecord);
            insert aswFList;
        }else{
            System.debug('Error');
            AWS_DocumentUtility.createLog(recordId, 'Class: SplitFileIntoThree, Method: execute',uName);
        } 
    }
    /**
	* This method will construct the Split PDF Bulk by page
	*/
    public static void splitPDFBulkByPage(String recordId, String uName){
        AWS_Document__c awsRecord  = AWS_DocumentUtility.getAws(recordId);
        String splitByBulkEndPoint = AWS_Endpoints__c.getValues('Split PDF Bulk by page').Endpoint_Name__c;
    } 
}