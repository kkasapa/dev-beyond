public class DocumentDownloadExtension {
    
    public string key {get;set;}
    public String secret {get;set;}
    public String fileName {get;set;}
    public String bucketName { get; set; }
    
    public AWS_Document__c record;
    ApexPages.StandardController con;
    public DocumentDownloadExtension(ApexPages.StandardController stdController) {
        System.debug('Running the constructor');
        this.con = stdController;
        AWS_Credentials_Settings__c setting =  getSettings();
        key = setting.Key__c;
        secret = setting.Secret__c;
        bucketName = setting.Bucket_Name__c;
        string Id = ApexPages.currentPage().getParameters().get('Id'); 
        this.record = [Select Name,Folder__c,File_Link__c from AWS_Document__c where Id=:Id limit 1];
        System.debug(this.record);
        fileName = this.record.File_Link__c;
        
        
    }
    
    private AWS_Credentials_Settings__c getSettings()
    {
        AWS_Credentials_Settings__c settings = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c Limit 1];
        return settings;
    }
}