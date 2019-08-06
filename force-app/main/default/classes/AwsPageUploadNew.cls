global with sharing class AwsPageUploadNew {   
    
    public Attachment att{get;set;}
    public list<string> settings{get;set;}
    public string objName{get;set;}
    public Id parentId{get;set;}
    public string selectedfodler{get;set;} 
    public string selectedFile{get;set;}
    public string filename{get;set;}
    public boolean showuploadmodal{get;set;}
    public String documentName{get;set;}
    public String documenttype{get;set;}
    public Static boolean Uploaded{get;set;}
    public boolean FolderCreated{get;set;}
    public String objectId{get; set;}
    
    public nu_dse__Program__c  program{get;set;}
    public nu_dse__Program__c programInstance {get;set;} 
    public AWSCredentialsWrapper awsCredentialWrapperInstance {get; set;}
    
    public String nameSpacePrefix_sObject {get; set;}
    
    public Id documentId {get; set;}
    public Boolean isPrivate {get; set;}
    
    public Boolean isPortalUser {get; set;}
    List<Profile> profileList = new List<Profile>();
    public AWS_Credentials_Settings__c credentials;
    public String errorString;
    
    //Added for page Message
    public Boolean isError {get; set;}
    
    //Added on 25 may 2018
    public String parentName {get; set;}
    public String returnURL;
    public AWS_Document__c awsDocument {get; set;}
    
    //public Document_Library__c documentLibrary { get;set;}
    //public list<Document_Library__c> docLibAWSList{get;set;}
    
    public AwsPageUploadNew(ApexPages.StandardController controller) {
        
        isError = False;
        returnURL = apexpages.currentpage().getparameters().get('retURL');
        awsCredentialWrapperInstance = new AWSCredentialsWrapper();
        
        try {
            
            programInstance = (nu_dse__Program__c)controller.getRecord();
            parentId = programInstance.Id; 
            
            Uploaded = false;
            FolderCreated = false;
            selectedfodler = 'null';
            selectedFile = '';
            showuploadmodal = false;
            //documentLibrary = new Document_Library__c();
            //documentLibrary.IsPrivate__c  = true; 
            //settings = new list<string>();
            //Schema.DescribeFieldResult fieldResult = Document_Library__c.Folder__c.getDescribe();
            //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            isPortalUser = FALSE;
            
            credentials = AWS_Credentials_Settings__c.getInstance();
            errorString = '';
            
            if (credentials != null) {
            
                if (credentials.Secret__c != null && credentials.Key__c != null) {
                
                    awsCredentialWrapperInstance.secretValue = credentials.Secret__c;
                    awsCredentialWrapperInstance.accessKey = credentials.Key__c;
                
                } else if (credentials.Secret__c == null && credentials.Key__c == null) {
                
                    errorString = 'No Key and Secret is specified. Please enter the Key, secret value and retry.';
                
                } else if (credentials.Secret__c != null) {
                    
                    errorString = 'No key is specified. Please enter the Key value and retry.';
                    awsCredentialWrapperInstance.secretValue = credentials.Secret__c;
                    
                } else if (credentials.Key__c != null) {
                
                    errorString = 'No secret is specified. Please enter the Secret value and retry.';
                    awsCredentialWrapperInstance.accessKey = credentials.Key__c;
                }
            }
            
            awsCredentialWrapperInstance.regionConfig = 'us-east-1';
            awsCredentialWrapperInstance.bucket = credentials.Bucket_Name__c;
            
            if (String.isBlank(errorString) == False) {
                
                throw new CustomException(errorString);     
            }
            /*
            for ( Schema.PicklistEntry pickListVal : ple) {
                
                settings.add(pickListVal.getLabel());
            }     
            */
            
            if (parentId != null) {
                
                List<nu_dse__Program__c> programList = [SELECT Id, Name FROM nu_dse__Program__c WHERE Id = :parentId];
                
                if (programList.isEmpty() == False) {
                    
                    program = programList[0];
                }
                parentName = program.Name;
                
                //FolderCreated = program.Folder_Created__c;
                //documentLibrary.Program__c  =  parentId;
                
                //Added for table creation.
                //getDocumentsList(parentId); Commented on june 21 2018
            }
            
            att = new Attachment();
            
        } catch (Exception e) {
            
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = True;
        }
    }
    
    public void openUploadModal() {
       
       showuploadmodal = true;
    }
    
    @RemoteAction
    global static String createDocLibraryNew(String parent_Id,String file_name, String fileNameTosave, String objectCategory, String filesize) {
        
        try {
        
            if (String.isNotBlank(file_name)) {
                
                AWS_Document__c awsDocumentInstance = new AWS_Document__c();
                awsDocumentInstance.Program__c = parent_Id;
                awsDocumentInstance.File_Link__c = file_name;
                System.debug('***awsDocumentStatic-->'+file_name.split('/')[1]);
                awsDocumentInstance.Folder__c = 'Program/'+file_name.split('/')[1];
                System.debug('***awsDocumentStatic-->'+awsDocumentInstance.Folder__c);
                awsDocumentInstance.File_Name__c = fileNameToSave;
                awsDocumentInstance.Category__c = objectCategory;
                awsDocumentInstance.Size__c = Integer.valueOf(filesize);
                AWS_Credentials_Settings__c credentials = AWS_Credentials_Settings__c.getInstance();
                
                awsDocumentInstance.Bucket__c = credentials.Bucket_Name__c;
                
                System.debug('***awsDocumentStatic-->'+awsDocumentInstance);
                
                insert awsDocumentInstance;
                updatebutton();
            }
            
        } catch (Exception e) {
            
            return e.getMessage();
        }
        return null;
    }
    
    public void refreshPageMessage() {
        
        String mess = apexpages.currentpage().getparameters().get('message');
        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, mess);
        ApexPages.addMessage(errorMsg);
        System.debug('Message----->'+mess);
    }
    
    public static void updatebutton() {
        
        Uploaded = true;
    }
    
    public pageReference redirectToRetUrl() {
        
        if (String.isBlank(returnURL)) {
            
            returnURL = '/home/home.jsp';
        }
        
        PageReference pageRef = new PageReference(returnURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public class AWSCredentialsWrapper {
        
        public String accessKey {get; set;}
        public String secretValue {get; set;}
        public String regionConfig {get; set;}
        public String bucket {get;set;}
    }
    
    
    /*
    public void assignParentId () {
        
        objectId = apexpages.currentpage().getparameters().get('objectId');
        parentId = objectId;
        getDocumentsList(objectId);
    }
    */
    
    /* Commented on june 21 2018.
    //Added for table showing doc lib records with view functionality
    public pageReference ViewFile() {
        
        try {
            
            isError = False;
            
            List<Document_Library__c> docList = new List<Document_Library__c>();
            docList = [SELECT Id, Name, Isprivate__c ,AWS_File_Link__c FROM Document_Library__c WHERE Id=:selectedFile];
            
            if (docList.size() > 0) {
                
                Document_Library__c doc = docList[0];
                string privatebucket = '';
                string publicbucket = '';
                
                errorString = '';
                
                if (credentials != null && credentials.Key__c != null) {
                    
                    awsCredentialWrapperInstance.secretValue = credentials.Secret__c;
                    
                } else {
                    
                    errorString = 'No key is specified.';
                }
                
                if (credentials != null && credentials.Secret__c != null) {
                    
                    awsCredentialWrapperInstance.accessKey = credentials.Key__c;
                
                } else {
                    
                    if (errorString != '') {
                        
                        errorString = 'No Key and Secret is specified.';
                    
                    } else {
                        
                        errorString = 'No Secret is specified.';
                    }
                }
                
                if (doc.isprivate__c == True) {
                    
                    if (credentials != null && credentials.Bucket_Name__c != null) {
                        
                        privatebucket = credentials.Bucket_Name__c;
                        
                    } else {
                        
                        if (errorString != '') {   
                            
                            errorString += ' No Bucket is specified.';
                            //errorString += ' No Private Bucket is specified.';
                        } else {
                            
                            errorString += ' No Bucket is specified.';
                            //errorString = ' No Private Bucket is specified.';
                        }
                    }
                
                } else {
                    
                    if (credentials != null && credentials.Bucket_Name__c != null) {
                        
                        privatebucket = credentials.Bucket_Name__c ;
                        
                    } else {
                        
                        if (errorString != '') {   
                            
                            errorString += ' No Public Bucket is specified.';
                        } else {
                            
                            errorString = 'No Public Bucket is specified.';
                        }
                    }
                }
                
                if (String.isBlank(errorString) == False) {
                    
                    errorString += 'Please enter the value(s) and try again';
                    throw new CustomException(errorString);     
                }
                
                PageReference newPage;
            
                system.debug('---selectedFile---'+selectedFile);
                String fileName = doc.AWS_File_Link__c;
                Datetime now = DateTime.now();
                Datetime expireson = now.AddSeconds(120);
                Long Lexpires = expireson.getTime()/1000;
                String fileName_temp = fileName;
                String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+ privatebucket +'/'+filename;
                String signed = make_sig(stringtosign , credentials.Secret__c);
                String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
                String url ='';
                
                if(doc.isprivate__c = true){
                    
                    url = 'http://'+privatebucket+'.s3.amazonaws.com/'+fileName +'?AWSAccessKeyId='+credentials.Key__c+'&Expires='+Lexpires+'&Signature='+signed;
                
                } else {
                    
                    url = 'http://'+privatebucket+'.s3.amazonaws.com/'+fileName +'?AWSAccessKeyId='+credentials.Key__c+'&Expires='+Lexpires+'&Signature='+signed;
                }
                
                newPage = new PageReference(url);
                return newPage;
            
            } else {
                
                throw new CustomException('No files found'); 
            }
                
        } catch (Exception e) {
            
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = True;
            
            return null;
        }
    } 
    
    private String make_sig(string canonicalBuffer , String secret) {        
        
        String macUrl ;
        
        try {
            
            isError = False;
            
            String signingKey = EncodingUtil.base64Encode(Blob.valueOf(secret));
            Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(Secret)); 
            macUrl = EncodingUtil.base64Encode(mac); 
        
        } catch (Exception e) {
            
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = True;
        }             
        return macUrl;       
    }
    
    public void changeDocumentPrivacy() {
    
        if(documentId != null) {
            
            System.debug('***** isPrivate' + isPrivate);
            Document_Library__c documentToUpdate = new Document_Library__c(Id = documentId, IsPrivate__c = isPrivate);
            update documentToUpdate;
            
            getDocumentLibrary();
            
            System.debug('**** documentToUpdate-->' + documentToUpdate);
        }
    }
    */
    
    /*
    public void getDocumentLibrary() {
        
        try {
            
            isError = False;
            
            system.debug('--ParentId ---'+ParentId );
            system.debug('--selectedfodler---'+selectedfodler);
            objName = checkProspectOrProgram();
            system.debug('--objName---'+objName);
            docLibAWSList = new list<Document_Library__c>(); 
               
            if(objName  != null && selectedfodler !=null) {
            
               /* On 16-03-2018:
                * To render based on isPrivate__c = false to differentiate the community user and attorney
                */
                /*
                String queryString = 'SELECT Name, DocumentName__c, Folder__c, CreatedDate, IsPrivate__c, Program__c, CreatedBy.name, AWS_File_Link__c FROM Document_Library__c WHERE Program__c=:ParentId ORDER BY CreatedDate Desc';
               
                if(profileList != null && profileList.isEmpty() == False) {
                
                    Id profileId = profileList[0].Id;
                   
                    if(UserInfo.getProfileId() == profileId) {
                   
                        queryString += ' AND isPrivate__c = FALSE ';
                    }
                }
               
                queryString += ' LIMIT 1000';
               
                docLibAWSList = Database.query(queryString);
                
                system.debug('--docLibAWSList---'+docLibAWSList);
                
            }
        
        } catch (Exception e) {
            
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = True;
            
        }
    }
    
    public String checkProspectOrProgram() {
         
         objName=null;
         isError = False;
         
         if (parentId != null) {
             
             Schema.DescribeSObjectResult objectResult = parentId.getSobjectType().getDescribe();  
         
             if(objectResult != null) {
             
                 objName = objectResult.getName();
             }
         
         } else {
             
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Parent Id cannot be null');
             ApexPages.addMessage(errorMsg);
             isError = False;
         }
         
         return objName;
    }
   
    
    public void getDocumentsList(String parentId) {
        
        if (parentId != null) {
        
        //For showing document the document library records in Table
        docLibAWSList = [SELECT Id, DocumentName__c, 
                         CreatedDate, IsPrivate__c,
                         createdby.name 
                         FROM Document_Library__c 
                         WHERE Program__c = :parentId ORDER BY CreatedDate Desc];
        }
    }
    */
}