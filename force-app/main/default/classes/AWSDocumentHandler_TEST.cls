/**
* This test class is created to check the functionality of AWS_DocumentHandler class 
* @author : Avco Team
* @created Date : December 2019
*/
@isTest
public class AWSDocumentHandler_TEST {
    /**
	* This method is used to create the test data
	*/
    @testSetup
    static void awsTestData(){
        Switch__c swc = new Switch__c();
        swc.Name = 'Swith Off';
        swc.Turn_Off__c = true;
        insert swc;
        
        AWS_PDF_Split__c awsSplit = new AWS_PDF_Split__c();
        awsSplit.Name = 'Enrollment-Agreement';
        awsSplit.SearchTitle__c = 'test';
        awsSplit.bucket__c = 'test';
        awsSplit.sourceFileName__c = 'test';
        awsSplit.OutputFileName__c = 'test';
        awsSplit.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement';        
        insert awsSplit;
        
        AWS_PDF_Split__c awsSplitSR = new AWS_PDF_Split__c();
        awsSplitSR.Name = 'Enrollment-AgmntSec';
        awsSplitSR.SearchTitle__c = 'test';
        awsSplitSR.bucket__c = 'test';
        awsSplitSR.sourceFileName__c = 'test';
        awsSplitSR.OutputFileName__c = 'test';
        awsSplitSR.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement';        
        insert awsSplitSR;
        
        AWS_PDF_Split__c awsSplitEA = new AWS_PDF_Split__c();
        awsSplitEA.Name = 'Enrollment-Agmnt';
        awsSplitEA.SearchTitle__c = 'test';
        awsSplitEA.bucket__c = 'test';
        awsSplitEA.sourceFileName__c = 'test';
        awsSplitEA.OutputFileName__c = 'test';
        awsSplitEA.AWS_PDF_Name_Start__c = 'AUTHORIZATION-SPAA-Enrollment-Agreement';        
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
        insert awsdoc;
    }
    /**
	* This method is used to test the FirstRequest class
	*/ 
    @isTest
    static void testAWSFirstCallout(){        
        String uName = UserInfo.getName();
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        FirstRequest frqueue = new FirstRequest(awsRecord.id,uName); 
        
        Test.startTest();
        System.enqueueJob(frqueue);
        Test.stopTest();
    }
    
    /**
	* This method is used to test the SecondRequest class
	*/ 
    @isTest
    static void testAWSSecondCallout(){
        String uName = UserInfo.getName();
        AWS_Document__c awsRecord = [SELECT id, Name FROM AWS_Document__c WHERE Bucket__c ='testBucket' LIMIT 1]; 
        SecondRequest srqueue = new SecondRequest(awsRecord.id,uName);  
        
        Test.startTest();
        System.enqueueJob(srqueue);
        Test.stopTest();
    }    
}