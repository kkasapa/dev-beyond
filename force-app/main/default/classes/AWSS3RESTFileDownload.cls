//RESLY USING
public class AWSS3RESTFileDownload {
    public void getObjectToS3(){
        
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Denver');
        String fileName = 'P-37682-AUTHORIZATION-SPAA-Enrollment-Agreement-AL-Test BLP 2-Prospect-05212019.pdf';
        string bucketname = 'bf-test-salesforce-upload';
        //Digu
        String region ='region=us-east-1';
        String emailAddress ='dipatel@beyondfinance.com';
        String contentType ='application/pdf';
        String Key = 'AKIAYZBFNVFF2JJYRPDN';
        String Secret ='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';
        String Program = 'P-37682';
        String s3 ='s3';
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        //req.setHeader('Host','s3-' + region + '.amazonaws.com');
        req.setHeader('Content-Type', 'application/pdf');
        //req.setHeader('Accept', 'application/pdf');
        //req.setEndpoint('https://s3-' + region + '.amazonaws.com' + '/'+ bucketname + '/' +'Program'+ + filename);   //path style
        req.setEndpoint('https://s3.console.aws.amazon.com'+'/'+ s3+'/object' +'/'+ bucketname + '/' +'Program'+'/'+ Program+'/'+ filename );
        system.debug('I am here');
        req.setHeader('Date', formattedDateString);
        req.setHeader('Authorization',createAuthHeader('GET',contentType,filename,formattedDateString,bucketname,key,secret));
        
        //req.setEndpoint('https://s3.amazonaws.com/' + attFileLink.replace(' ', '+'));
        req.setHeader('Host', bucketname + '.s3.amazonaws.com');

        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('x-amz-acl', 'private');
        
        try {
            HTTPResponse res = http.send(req);
           // req.setHeader('Accept', 'application/xml');
           System.debug('RESContent-Type:'+ res.getHeader('Content-Type'));
            system.debug('res'+res);
            
/*
String codedFilename=  EncodingUtil.urlEncode(bucketPath,'UTF-8');
String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+bucketName+'/'+codedFilename+'?response-content-disposition=attachment; filename=abc.doc';
String signed = make_sig(stringtosign); 
String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
String url = serverURL+'/'+bucketName+'/'+codedFilename+'?response-content-disposition='+EncodingUtil.urlEncode('attachment; filename=abc.doc','UTF-8')+'&AWSAccessKeyId='+awskey+'&Expires='+Lexpires+'&Signature='+codedsigned;
*/

            System.debug('MYDEBUG: ' + fileName + ' RESPONSE STRING: ' + res.toString());
            system.debug('I a m here');
            system.debug(res.getBody());
            
            system.debug('***id-2***'+res.getHeader('x-amz-id-2'));
            
            //String result = (String)JSON.deserializeUntyped(res.getBody());
            //String result = String.valueOf( JSON.deserializeUntyped(res.getBody()));
            //system.debug('I am result'+result);
            //Blob pdfBlob = EncodingUtil.base64Decode(res.toString());
            //Blob pdfBlob = EncodingUtil.base64Decode(String.valueOf(JSON.deserializeUntyped(res.getBody())));
            
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new String[] { emailAddress });
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('DEMO.pdf');
            efa.setBody( res.getBodyAsBlob());
            //efa.setContentType('.pdf');
            attachments.add(efa);
            message.setFileAttachments(attachments);
            message.setSubject('');
            message.setHtmlBody('Test');
            message.setSaveAsActivity(true);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch(System.CalloutException e) {
            system.debug('MYDEBUG: AWS Service Callout Exception on ' + fileName + 'ERROR: ' + e.getMessage());
        }
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
    
    
    
    public void getS3File() {
        
        //string attFileLink='Program/P-35170/P-35170-Data Mask Data Sheet November 2019 NEWW.pdf';
        string attFileLink='Program/P-38322/P-38322-Enrollmeent_Agreement.pdf';
        String attContentType='application/pdf';
        String emailAddress ='dipatel@beyondfinance.com';
        AWS_Credentials_Settings__c setting = [Select Key__c,Secret__c,Bucket_Name__c,ACL__c from AWS_Credentials_Settings__c];
        String now = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String host='s3.amazonaws.com';
        String method = 'GET';
        String stringToSign = method+'\n\n'+attContentType + '\n'+ now +'\nx-amz-acl:'+setting.ACL__c+'\n/'+ setting.Bucket_Name__c +'/'+ attFileLink.replace(' ', '+');
        String signed = createSignature(stringToSign,setting.Secret__c);
        String authHeader = 'AWS' + ' ' + setting.Key__c + ':' + signed;
        
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://s3.amazonaws.com/' + attFileLink.replace(' ', '+'));
        req.setHeader('Host', setting.Bucket_Name__c + '.' + host);
        req.setHeader('Content-type', attContentType);
        //req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', now);
        req.setHeader('x-amz-acl', setting.ACL__c);
        req.setHeader('Authorization',authHeader);
        
        Http http = new Http();
        if(!Test.isRunningTest()) //added to avoid call out in Test class
            try {
                HTTPResponse res = http.send(req);   
                
                System.debug('RESContent-Type:'+ res.getHeader('Content-Type'));
                system.debug('res'+res);
                
                System.debug('MYDEBUG: RESPONSE STRING: ' + res.toString());
                system.debug('I a m here');
                system.debug(res.getBody());
            
                system.debug('***id-2***'+res.getHeader('x-amz-id-2'));
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[] { emailAddress });
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('DEMO_FILE.pdf');
                efa.setBody( res.getBodyAsBlob());
                //efa.setContentType('.pdf');
                attachments.add(efa);
                message.setFileAttachments(attachments);
                message.setSubject('');
                message.setHtmlBody('Test');
                message.setSaveAsActivity(true);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            } catch(System.CalloutException e) {
            system.debug('MYDEBUG: AWS Service Callout Exception on ' + 'ERROR: ' + e.getMessage());
        }
        
    }
    
    private static string createSignature(string canonicalBuffer,String secret){
        string sig;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        sig = EncodingUtil.base64Encode(mac);
        return sig;
    }
}