@isTest(SeeAllData=true)
public class AWSDocumentExtensionTest {
    
    private static AWSDocumentExtension getTestPage(string name)
    {
        AWS_Document__c doc = new AWS_Document__c(
            Bucket__c = 'dev-salesforce-upload', Category__c='Verified Statements', Content_Type__c= 'text/plain', 
            Folder__c='Program/P-0254/', Size__c=59, Name=name
        );
        ApexPages.StandardController sc = new ApexPages.StandardController(doc);
        AWSDocumentExtension  testPage = new AWSDocumentExtension(sc);
        testPage.mockFileMap = new Map<string,string>();
        testPage.mockFileMap.put('testfile.txt','testfile.txt');
        testPage.mockFileMap.put('testimage.png','testimage.png');
        testPage.mockFileMap.put('testdoc.docx','testdoc.docx');
        testPage.mockFileMap.put('testexcel.xlxs','testexcel.xlxs');
        testPage.fileBlob = Blob.valueOf('this is demo');
        testPage.contentType = 'text/plain';
        testPage.fileSize = 59;
        
        return testPage;
    }
    
    private static DocumentDownloadExtension getDownloadTestPage()
    {
        AWS_Document__c doc = new AWS_Document__c(
            Bucket__c = 'dev-salesforce-upload', Category__c='Verified Statements', Content_Type__c= 'text/plain', 
            Folder__c='Program/P-0254/', Size__c=59, Name='test.txt'
        );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(doc);
        DocumentDownloadExtension  testPage = new DocumentDownloadExtension(sc);
        return testPage;
    }
    
    public static testMethod void testDownloadExtension()
    {
        System.debug('Executing testDownloadExtension');
        DocumentDownloadExtension testPage = getDownloadTestPage();
        AWS_Credentials_Settings__c result = testPage.getSettings();
        System.assertNotEquals(null, result);       
    }
    
    public static testMethod void testValidFileName()
    {
        System.debug('Executing testValidFileName');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        boolean result = testPage.validateFileName('testfile');
        System.assertEquals(true, result);       
    }
    
    public static testMethod void testInValidFileName()
    {
        System.debug('Executing testInValidFileName');
        AWSDocumentExtension testPage = getTestPage('test@file.txt');
        boolean result = testPage.validateFileName('test@file');
        System.assertEquals(false, result);       
    }
    
    public static testMethod void testGetFileExtension()
    {
        System.debug('Executing testGetFileExtension');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        testPage.fileName= 'testfile.txt';
        string extension = testPage.getFileExtension();
        System.assertEquals('txt', extension);
        
        testPage.fileName= 'testfile.jpeg';
        extension = testPage.getFileExtension();
        System.assertEquals('jpeg', extension);
    }
    
    
    public static testMethod void testGetCurrentFiles()
    {
        System.debug('Executing testGetCurrentFiles');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        Map<string,string> files = testPage.getCurrentFiles('');
        System.assertEquals(4, files.size()); 
    }
    
    public static testMethod void testGetFolderName()
    {
        System.debug('Executing testGetFolderName');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        string folder = testPage.getFolderName();
        System.assertEquals('Program/P-2000/', folder);
    }
    
    public static testMethod void testCreateSignature()
    {
        System.debug('Executing testCreateSignature');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        string signature = testPage.createSignature('a','a');
        System.assertEquals('OQLthH/yiTC18UGr+otHFoElNnM=', signature);
    }
    
    public static testMethod void testGetSettings()
    {
        System.debug('Executing testGetSettings');
        AWSDocumentExtension testPage = getTestPage('testfile.txt');
        AWS_Credentials_Settings__c settings = testPage.getSettings();
        
        System.assert(settings != null);
    }
    
    public static testMethod void testGetFileNameIfDuplicate()
    {
        System.debug('Executing testSetFileNameIfDuplicate');
        AWSDocumentExtension testPage = getTestPage('newFile');
        testPage.fileName = 'newFile.txt';
        string fileName = testPage.getFileNameIfDuplicate();
        System.assertEquals('newFile.txt', fileName);
        
        testPage.record.Name = 'testimage';
        testPage.fileName = 'testimage.png';
        fileName = testPage.getFileNameIfDuplicate();
        System.assertEquals('testimage-1.png', fileName);
        
        
        testPage.mockFileMap.put('testimage-1.png','testimage-1.png');
        fileName = testPage.getFileNameIfDuplicate();
        System.assertEquals('testimage-2.png', fileName);
    }
    
    public static testMethod void testvalidatePostData()
    {
        System.debug('Executing testvalidatePostData');
        AWSDocumentExtension testPage = getTestPage('testFile.txt');
        testPage.fileBlob = null;
        
        Boolean result  = testPage.validatePostData();
        System.assertEquals(false, result);
    }
    
    
    public static testMethod void testsetRecordData()
    {
        System.debug('Executing testsetRecordData');
        AWSDocumentExtension testPage = getTestPage('docmentation.pdf');
        AWS_Credentials_Settings__c settings = testPage.getSettings();
        
        testPage.contentType = 'application/pdf';
        testPage.fileSize = 3000;
        testPage.record.Name = 'docmentation.pdf';
        testPage.fileName = 'docmentation.pdf';
        Test.setCurrentPageReference(new PageReference('Page.uploaddocument')); 
        System.currentPageReference().getParameters().put('id', 'a0Lg000000VhXv1EAF');
        
        testPage.setRecordData(settings);
        
        System.assertEquals('application/pdf', testPage.record.Content_Type__c);
        
    }
    
    
    public static testMethod void testFileUpload()
    {
        System.debug('Executing testFileUpload');
        AWSDocumentExtension testPage = getTestPage('docmentation');
        testPage.fileName = 'docmentation.pdf';
        
        Test.setCurrentPageReference(new PageReference('Page.uploaddocument')); 
        System.currentPageReference().getParameters().put('retURL', 'example.com');
        
        Test.setMock(HttpCalloutMock.class, new MockS3HttpResponseGenerator());
        pageReference ref = testPage.saveFile();
        System.assert(ref != null);
        
    }
    
    public static testMethod void testDeleteFileHttpCall()
    {
        System.debug('Executing testDeleteFileHttpCall');
        AWSDocumentExtension testPage = getTestPage('docmentation.pdf');
        AWS_Credentials_Settings__c settings = testPage.getSettings();
        Test.setMock(HttpCalloutMock.class, new MockS3HttpResponseGenerator());
        S3Service.deleteFile(settings.Bucket_Name__c,'Program/P-1001/test.txt',settings.Key__c,settings.Secret__c);
    }
    
    public static testMethod void testDeleteAndMoveFileHttpCall()
    {
        System.debug('Executing testDeleteAndMoveFileHttpCall');
        AWSDocumentExtension testPage = getTestPage('docmentation.pdf');
        AWS_Credentials_Settings__c settings = testPage.getSettings();
        Test.setMock(HttpCalloutMock.class, new MockS3HttpResponseGenerator());
        S3Service.deleteAndMoveFile(settings.Bucket_Name__c,'Program/P-1001/test.txt','Program/P-1001/deleted/test.txt',settings.Key__c,settings.Secret__c);
    }
    
    
    public static testMethod void testDeleteTrigger()
    {
        System.debug('Executing testDeleteTrigger');
        AWS_Document__c doc = new AWS_Document__c(
            Bucket__c = 'dev-salesforce-upload', Category__c='Verified Statements', Content_Type__c= 'text/plain', 
            Folder__c='Program/P-00000/', Size__c=59, Name='testfile.txt'
        );
        insert doc;
        Test.setMock(HttpCalloutMock.class, new MockS3HttpResponseGenerator());
        Test.startTest();
        delete doc;
        Test.stopTest();
        
    }
    
    
}