public class AWSDocumentExtension {
    
    //Fields to get data from file input
    public Transient Blob fileBlob {get;set;}
    public Transient Integer fileSize {get;set;}
    public Transient String fileName {get;set;}
    public Transient String contentType { get; set; }
    
    //Mock objects to help in Testing
    @testVisible private Map<string,string> mockFileMap = null;
    
    
    public AWS_Document__c record;
    ApexPages.StandardController con;
    public AWSDocumentExtension(ApexPages.StandardController stdController) {
        this.con = stdController;
        try { 
            this.record = (AWS_Document__c)con.getRecord();
        } catch( Exception ee) 
        { 
            this.record = new 	AWS_Document__c(); 
        }
    }
    
    
    public pageReference saveFile() {
        
        if(!validatePostData())
        {
            return null;
        }
        
        AWS_Credentials_Settings__c setting = getSettings();
        setRecordData(setting);   
        if(S3Service.uploadObject(this.record,setting,fileBlob,fileSize,contentType).getStatusCode()==200)
        {
            insert this.record;
            PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
            return returnPage;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Document could not be uploaded.'));
            return null;
        }
    }
    
    @testVisible private void setRecordData(AWS_Credentials_Settings__c setting)
    {
        
        this.record.Content_Type__c = contentType;
        this.record.Bucket__c = setting.Bucket_Name__c;
        this.record.Folder__c = getFolderName();
        this.record.Size__c = fileSize;
        this.record.Name =  getFileNameIfDuplicate();
        if(ApexPages.currentPage() != null)
        {
            this.record.Program__c = ApexPages.currentPage().getParameters().get('recId');
        }
        
    }
    
    @testVisible private boolean validatePostData(){
        Boolean isValid = true;
        System.debug('Name :: '  + this.record.Name.replace(' ', '+'));
        
        if(!validateFileName(this.record.Name.replace(' ', '+')))
        {
            system.debug('record.Name is invalid');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'File name cannot contain special characters. Select the file again and then remove special characters from the file name.'));
            isValid = false;
        }
        if(fileBlob == null)
        {
            system.debug('fileblob is null');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a file.'));
            isValid = false;
        }
        System.debug('validatePostData is completed');
        return isValid;
    }
    
    @testVisible private string getFileNameIfDuplicate()
    {
        System.debug('getFileNameIfDuplicate');
        string fName = this.record.Name + '.' +getFileExtension();
        System.debug(fName);
        Map<string,string> currentFiles = getCurrentFiles(getFolderName());
        System.debug(currentFiles);
        if(currentFiles.containsKey(fName))
        {
            integer counter = 1;
            fname  =  this.record.Name + '-' + String.valueOf(counter) +  '.' +getFileExtension();
            while(currentFiles.containsKey(fName))
            {
                counter = counter + 1;
                fname  =  this.record.Name + '-' + String.valueOf(counter) +  '.' +getFileExtension();
            }
        }
        
        return fName;
    }
    
    @testVisible private Map<string,string> getCurrentFiles(string folder)
    {
        if(Test.isRunningTest() && (mockFileMap != null))
        {
            return mockFileMap;
        }
        else
        {
            Map<string,string> names = new Map<string,string>();
            List<AWS_Document__C> documents = [Select Id,Name from AWS_Document__c Where Folder__C = :folder];
            for(AWS_Document__C doc: documents)
            {
                names.put(doc.Name,doc.Name);
            }
            System.debug(names);
            return names;
        }
        
    }
    
    @testVisible private boolean validateFileName(string fileName)
    {
        System.debug('fileName in validateFileName :: ' + fileName);
        Pattern MyPattern = Pattern.compile('[a-zA-Z0-9_+-]+');
        Matcher MyMatcher = MyPattern.matcher(fileName);
        return MyMatcher.matches();
    }
    
    
    
    
    @testVisible private string getFolderName()
    {
        if(Test.isRunningTest())
        {
            return 'Program/P-2000/';
        }
        else
        {
            string Id = ApexPages.currentPage().getParameters().get('recId'); 
            string objName = ApexPages.currentPage().getParameters().get('type'); 
            nu_dse__Program__c prog = [Select Name from nu_dse__Program__c where Id=:Id limit 1];
            return objName+'/' + prog.Name+ '/';
        }
    }
    
    @testVisible private string createSignature(string canonicalBuffer,String secret){
        string sig;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        sig = EncodingUtil.base64Encode(mac);
        return sig;
    }
    
    @testVisible private string getFileExtension()
    {
        list<string> parts = filename.split('\\.');
        return parts[parts.size()-1];
    }
    
    @testVisible private AWS_Credentials_Settings__c getSettings()
    {
        if(Test.isRunningTest())
        {
            AWS_Credentials_Settings__c settings = new AWS_Credentials_Settings__c();
            settings.Key__c = 'AKIAIYLMWGW77TNCK';
            settings.Secret__c = 'aeldD2orv51EqI6VQ6szhFh0t73Jc5';
            settings.Bucket_Name__c = 'dev-salesforce-upload';
            settings.ACL__c = 'Private';
            return settings;
        }
        else
        {
            AWS_Credentials_Settings__c settings = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c];
            return settings;
        }
        
    }
}