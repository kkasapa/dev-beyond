/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Test Class to check the functionality of SplitFileIntoThree Queueable class.  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shravan 
* @modifiedBy     
* @maintainedBy   Shravan
* @version        1.0
* @created        2019-12-19
* @modified       2019-12-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
global class AWS_DocumentHandler_TEST {
    /**
	* This method is used to create the test data
	*/
    @testSetup
    static void awsTestData(){
        Switch__c swc = new Switch__c();
        swc.Name = 'Swith Off';
        swc.Turn_Off__c = true;
        insert swc;
        
        AWS_Endpoints__c awsTitle = new AWS_Endpoints__c();
        awsTitle.Name = 'Split PDF By Title Single';
        awsTitle.Active__c = false;
        awsTitle.Endpoint_Name__c = 'https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/documents/pdf/split-by-title';
        insert awsTitle;        
        
        AWS_Endpoints__c awsPage = new AWS_Endpoints__c();
        awsPage.Name = 'PDF Split Single by Page';
        awsPage.Active__c = false;
        awsPage.Endpoint_Name__c = 'https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/documents/pdf/split-by-page';
        insert awsPage;
        
        AWS_Endpoints__c awsBulk = new AWS_Endpoints__c();
        awsBulk.Name = 'PDF Split Bulk';
        awsBulk.Active__c = false;
        awsBulk.Endpoint_Name__c = 'https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/documents/pdf/split-by-title/bulk';
        insert awsBulk; 
        
        AWS_Endpoints__c awsBulkPage = new AWS_Endpoints__c();
        awsBulkPage.Name = 'Split PDF Bulk by page';
        awsBulkPage.Active__c = false;
        awsBulkPage.Endpoint_Name__c = 'https://zb0bwfulaf.execute-api.us-east-1.amazonaws.com/staging/v1/documents/pdf/split-by-page/bulk';
        insert awsBulkPage; 
        
        AWS_PDF_Split__c awsSplit = new AWS_PDF_Split__c();
        awsSplit.Name = 'Auth Letter';
        awsSplit.SearchTitle__c = 'test';
        awsSplit.bucket__c = 'test';
        awsSplit.sourceFileName__c = 'test';
        awsSplit.OutputFileName__c = 'test';
        awsSplit.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement.pdf';   
        
        insert awsSplit;
        
        AWS_PDF_Split__c awsSplitSR = new AWS_PDF_Split__c();
        awsSplitSR.Name = 'LPOA';
        awsSplitSR.SearchTitle__c = 'test';
        awsSplitSR.bucket__c = 'test';
        awsSplitSR.sourceFileName__c = 'test';
        awsSplitSR.OutputFileName__c = 'test';
        awsSplitSR.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement.pdf';  
        
        insert awsSplitSR;
        
        AWS_PDF_Split__c awsSplitEA = new AWS_PDF_Split__c();
        awsSplitEA.Name = 'ATC';
        awsSplitEA.SearchTitle__c = 'test';
        awsSplitEA.bucket__c = 'test';
        awsSplitEA.sourceFileName__c = 'test';
        awsSplitEA.OutputFileName__c = 'test';
        awsSplitEA.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement.pdf'; 
        
        insert awsSplitEA;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.Firm_Name__c = 'testFrimName';
        pgm.Email_Address__c = 'test@tes.com';
        insert pgm;
        
        AWS_Document__c awsdoc = new AWS_Document__c();
        awsdoc.Program__c = pgm.id;
        awsdoc.Bucket__c = 'testBucket';
        awsdoc.Category__c = 'Offer';
        awsdoc.Content_Type__c = 'testCOntentType';
        awsdoc.Size__c = 2;
        awsdoc.createdFromAWS__c = false;
        awsdoc.File_Name__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement.pdf';
        insert awsdoc;
    }
    /**
	* This method is used to test the splitPDFByTitle
	*/ 
    @isTest
    static void testsplitPDFByTitle(){
        String uName = UserInfo.getName(); 
        AWS_Endpoints__c awsE = [SELECT id,Name,Active__c FROM AWS_Endpoints__c WHERE Name ='Split PDF By Title Single' ];
        awsE.Active__c = true;
        update awsE;
        
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        PdfSplitService frqueue1 = new PdfSplitService(awsRecord.id,uName); 
        Test.setMock(HttpCalloutMock.class, new UploadFileMock());
        Test.startTest();
        
        System.enqueueJob(frqueue1);
        Test.stopTest();
    }     
    /**
	* This method is used to test the splitPDFByPage
	*/    
    @isTest
    static void testsplitPDFByPage(){
        String uName = UserInfo.getName();
        AWS_Endpoints__c awsE1 = [SELECT id,Name,Active__c FROM AWS_Endpoints__c WHERE Name ='PDF Split Single by Page' ];
        awsE1.Active__c = true;
        update awsE1;        
        
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        PdfSplitService frqueue2 = new PdfSplitService(awsRecord.id,uName); 
        Test.setMock(HttpCalloutMock.class, new UploadFileMock());
        Test.startTest();
        
        System.enqueueJob(frqueue2);
        Test.stopTest();
    }    
    /**
	* This method is used to test the splitPDFBulk
	*/    
    @isTest
    static void testsplitPDFBulk(){        
        String uName = UserInfo.getName();
        AWS_Endpoints__c awsE3  = [SELECT id,Name,Active__c FROM AWS_Endpoints__c WHERE Name ='PDF Split Bulk' ];
        awsE3.Active__c = true;
        update awsE3;        
        
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        PdfSplitService frqueue3 = new PdfSplitService(awsRecord.id,uName); 
        Test.setMock(HttpCalloutMock.class, new UploadFileMockSplit());
        Test.startTest();
        System.enqueueJob(frqueue3);
        Test.stopTest();
    }
    /**
	* This method is used to test the splitPDFBulkPage
	*/ 
    @isTest
    static void testsplitPDFBulkPage(){        
        String uName = UserInfo.getName();
        AWS_Endpoints__c awsE4 = [SELECT id,Name,Active__c FROM AWS_Endpoints__c WHERE Name ='Split PDF Bulk by page' ];
        awsE4.Active__c = true;
        update awsE4;        
        
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        PdfSplitService frqueue4 = new PdfSplitService(awsRecord.id,uName); 
        Test.setMock(HttpCalloutMock.class, new UploadFileMockSplit());
        Test.startTest();
        
        System.enqueueJob(frqueue4);
        Test.stopTest();
    }
    /*
    * This is a mock class to test the SplitByTitle and SplitByPage Single methods
    */ 
    global class UploadFileMock implements HTTPCalloutMock{
        global HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"title":"Limited Power of Attorney to Speak and Negotiate","bucket": "bf-test-salesforce-upload","sourceFileName":"Program/P-37682/P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf","outputFileName":"LPA.pdf"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /*
    * This is a mock class to test the SplitByBulk method.
    */
    global class UploadFileMockSplit implements HTTPCalloutMock{
        global HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            String json = ('{"splitNodes":[{"title":"Limited Power of Attorney to Speak and Negotiate","outputFileName":"P-38060Shravan DasariLPOA.pdf"},{"title":"Authorization Letter for Beyond Finance, Inc.","outputFileName":"P-38060Shravan DasariAuthLetter.pdf"},{"title":"Authorization To Communicate for Beyond Finance, Inc.","outputFileName":"P-38060Shravan DasariATC.pdf"}],"sourceFileName":"Program/P-38060/P-38060-P-38060-AUTHORIZATION-SPAA-Enrollment-Agreement.pdf","bucket":"bf-test-salesforce-upload"}');
            json = '['+json+']';        
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }    
    }
}