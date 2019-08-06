@istest
public class AwsPageUploadNew_Test{
    
    public static testMethod void uploadDoct() {  
    
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();    
        Id accountRecordTypeId;
        
        if (accountRecordTypeMap.containsKey('Client')) {
            
            accountRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }        
                
        Account accountInstance = TestRecordCreator.createAccount('Account Name', accountRecordTypeId);        
        insert accountInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('CFT');        
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);        
        insert programInstance;
        
        AWS_Credentials_Settings__c awsInstance = TestRecordCreator.createAwsCredentialsSettings();  
        insert awsInstance;        
        
        Test.StartTest();
             
        ApexPages.StandardController sc = new ApexPages.StandardController(programInstance);
        
        AwsPageUploadNew testUploadRecord = new AwsPageUploadNew(sc);
        
        /* Commented on june 21 2018-->
        testUploadRecord.assignParentId();
        testUploadRecord.openUploadModal();
        */
        
        PageReference pageRef = Page.AWSUploadPageNew;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(programInstance.Id));      
        
        AwsPageUploadNew.createDocLibraryNew(String.valueof(programInstance.id), 'Program/AB-CD', 'Test Doc Name', 'Voided Check', '5000');
        
        Test.StopTest();
        
        List<AWS_Document__c> awsDocumentList = [SELECT Id, File_Link__c, Folder__c, Bucket__c, Name, Category__c FROM AWS_Document__c];
        
        System.debug('***awsDocumentList--->'+awsDocumentList);
        
        System.assertEquals(true, awsDocumentList.size() > 0);
        System.assertEquals('Program/AB-CD', awsDocumentList[0].File_Link__c);

    }
     public static testMethod void testCase2() {
     
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();    
        Id accountRecordTypeId;
        
        if (accountRecordTypeMap.containsKey('Client')) {
            
            accountRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
                
        Account accountInstance = TestRecordCreator.createAccount('Account Name', accountRecordTypeId);        
        insert accountInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('CFT');        
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);        
        insert programInstance;     

        Test.StartTest();
             
        ApexPages.StandardController sc = new ApexPages.StandardController(programInstance);
        
        AwsPageUploadNew testUploadRecord = new AwsPageUploadNew(sc);
        
        PageReference pageRef = Page.AWSUploadPageNew;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(programInstance.Id));
        
        Test.StopTest();
        
        System.assertEquals(true,programInstance != null);
       
     }
}