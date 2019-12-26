/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* This class will get the Pdf from AWS system and send email to users 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shravan 
* @modifiedBy     
* @maintainedBy   Shravan
* @version        1.0
* @created        2019-12-23
* @modified       2019-12-23
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class AWS_GetPdfSendEmailsInBatch implements Database.Batchable<sobject>,Database.AllowsCallouts {    
    global String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Denver');
    global String fileName = 'P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf';
    global string bucketname = 'bf-test-salesforce-upload';    
    global String region ='region=us-east-1';
    global String emailAddress ='Shravan.Dasari@avcoconsulting.com';
    global String contentType ='application/pdf';
    global  String Key = 'AKIAYZBFNVFF2JJYRPDN';
    global String Secret ='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';
    global String Program = 'P-37682';
    global String s3 ='s3';
    
    global Database.QueryLocator Start(Database.BatchableContext bc){  
        return Database.getQueryLocator(
            'SELECT ID, Name, Email FROM User ' + 
            'Where Email = \'shravan.dasari@avcoconsulting.com\''
        );
        
    }
    global void execute(Database.BatchableContext bc, List<User> Scope){
        List<String>emailAddresses = new List<String>();
        for(User u : Scope){
            emailAddresses.add(u.Email);
        }
        List<Messaging.SingleEmailMessage>emailList = new List<Messaging.SingleEmailMessage>();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        //req.setHeader('Host','s3-' + region + '.amazonaws.com');
        req.setHeader('Content-Type', 'application/pdf');
        //req.setHeader('Accept', 'application/pdf');
        //req.setEndpoint('https://s3-' + region + '.amazonaws.com' + '/'+ bucketname + '/' +'Program'+ + filename);   //path style
        req.setEndpoint('https://s3.console.aws.amazon.com'+'/'+ s3+'/object' +'/'+ bucketname + '/' +'Program'+'/'+ Program+'/'+ filename );        
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader('GET',contentType,filename,formattedDateString,bucketname,key,secret));        
        //req.setEndpoint('https://s3.amazonaws.com/' + attFileLink.replace(' ', '+'));
        req.setHeader('Host', bucketname + '.s3.amazonaws.com');        
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('x-amz-acl', 'private');
        HTTPResponse res = http.send(req);        
        emailList.add(prepareSendEmail(res,emailAddresses));
        
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }
    
    global void finish(Database.BatchableContext bc){        
    }    
    //create authorization header for Amazon S3 REST API
    public string createAuthHeader(String method,String contentType,String filename,String formattedDateString,String bucket,String key,String secret){
        string auth;
        String stringToSign = method+'\n\n'+contentType+'\n'+formattedDateString+'\n/'+bucket+'/'+filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        return auth;
    }
    
    // Prepare the Email that can be sent from execute method
    private Messaging.SingleEmailMessage prepareSendEmail (HTTPResponse res, List<String>emailAddresses){
        List<Messaging.SingleEmailMessage>emailList2 = new List<Messaging.SingleEmailMessage>();        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailAddresses);
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('DEMO.pdf');
        efa.setBody( res.getBodyAsBlob());
        //efa.setContentType('.pdf');
        attachments.add(efa);
        email.setFileAttachments(attachments);
        email.setSubject('');
        email.setHtmlBody('Test');
        email.setSaveAsActivity(true);
        
        return email;
    }
    
    /*
	* Use below code to Execute this Batch Class
	* Paste in Developer Console
		AWS_GetPdfSendEmailsInBatch objClass = new AWS_GetPdfSendEmailsInBatch();
		Database.executeBatch (objClass);
	*/
}