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
public class AWS_PdfSplitServiceBLP implements Queueable,Database.AllowsCallouts{
    private String recordId;
    private String uName;   
        
    public AWS_PdfSplitServiceBLP(String recordId, String uName) {
        this.recordId = recordId;
        this.uName = uName;
    }
    
    public void execute(QueueableContext context) {
        AWS_PDF_Split__c cs = new AWS_PDF_Split__c();
        AWS_Document__c  awsRecord = [SELECT id, Name,File_Link__c,Category__c,Program__c,Content_Type__c,
                                      File_Name__c,Folder__c,Size__c,Bucket__c,Program__r.Name,Program__r.nu_dse__Account__r.Name 
                                      FROM AWS_Document__c 
                                      WHERE id =: recordId];
        if(awsRecord.File_Name__c.startsWith(AWS_PDF_Split__c.getValues('ALC BLP POA').AWS_PDF_Name_Start__c)){
            alcPoa(recordId, cs);
        }
        if(awsRecord.File_Name__c.startsWith(AWS_PDF_Split__c.getValues('CM BLP POA').AWS_PDF_Name_Start__c)){
             cmPoa(recordId, cs);
        }
        if(awsRecord.File_Name__c.startsWith(AWS_PDF_Split__c.getValues('LNM BLP POA').AWS_PDF_Name_Start__c)){
            lnmPoa(recordId, cs);
        }
    }
    
    public static void cmPoa(String recordId,AWS_PDF_Split__c csAWS){
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);
        
        String JSONstr = ''; 
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.SplitByCmBlp splitByCmBlp = new AWSSchemaClass.SplitByCmBlp();
        splitByCmBlp.title 			= csAWS.SearchTitle__c;
        splitByCmBlp.page 			= csAWS.Page__c;
        splitByCmBlp.pages 			= csAWS.Pages__c;
        splitByCmBlp.outputFileName = pgmName + accName+ csAWS.OutputFileName__c;
        
        JSONstr = JSON.serialize(splitByCmBlp,true);
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
        
    }
    public static void alcPoa(String recordId,AWS_PDF_Split__c csAWS){
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);
        
        String JSONstr = ''; 
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.SplitByAlcBlp splitByAlcBlp = new AWSSchemaClass.SplitByAlcBlp();
        SplitByAlcBlp.title 			= csAWS.SearchTitle__c;
        SplitByAlcBlp.page 			= csAWS.Page__c;
        SplitByAlcBlp.pages 			= csAWS.Pages__c;
        SplitByAlcBlp.outputFileName = pgmName + accName+ csAWS.OutputFileName__c;
        
        JSONstr = JSON.serialize(splitByAlcBlp,true);
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
    }
    public static void lnmPoa(String recordId,AWS_PDF_Split__c csAWS){
        AWS_Document__c awsRecord = AWS_DocumentUtility.getAws(recordId);
        
        String JSONstr = ''; 
        String pgmName = awsRecord.Program__r.Name;
        String accName = awsRecord.Program__r.nu_dse__Account__r.Name;
        
        AWSSchemaClass.SplitByLnmBlp splitByLnmBlp = new AWSSchemaClass.SplitByLnmBlp();
        splitByLnmBlp.title 			= csAWS.SearchTitle__c;
        splitByLnmBlp.page 			= csAWS.Page__c;
        splitByLnmBlp.pages 			= csAWS.Pages__c;
        splitByLnmBlp.outputFileName = pgmName + accName+ csAWS.OutputFileName__c;
        
        JSONstr = JSON.serialize(splitByLnmBlp,true);
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
    }

}