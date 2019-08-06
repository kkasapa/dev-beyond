@isTest
private class DocumentDownloadExtension_Test{

    static testMethod void Docdownload() {
        AWS_Document__c doc = new AWS_Document__c(
            Bucket__c = 'dev-salesforce-upload', Category__c='Verified Statements', Content_Type__c= 'text/plain', 
            Folder__c='Program/P-0254/', Size__c=59, Name='name'
        );
        insert doc;
        
         AWS_Credentials_Settings__c settings = new AWS_Credentials_Settings__c();
            settings.Key__c = 'AKIAIYLMWGW77TNCK';
            settings.Secret__c = 'aeldD2orv51EqI6VQ6szhFh0t73Jc5';
            settings.Bucket_Name__c = 'dev-salesforce-upload';
            settings.ACL__c = 'Private';
           insert  settings;
        
        PageReference pageRef = Page.downloadFile;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(doc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(doc);
        DocumentDownloadExtension testacc = new DocumentDownloadExtension(sc);
    }
}