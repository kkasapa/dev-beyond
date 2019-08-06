public class S3Service {
    
   public static void deleteFile(string bucket, string fullDocPath, string key, string secret)
    {
        String formattedDateString = Datetime.now().formatGMT('EEE,   dd MMM yyyy HH:mm:ss z');
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setHeader('Host', 's3.amazonaws.com');
        req.setHeader('Date', formattedDateString);
        req.setEndpoint('https://s3.amazonaws.com/'+ bucket +'/'+ fullDocPath); 
        System.debug(bucket +'/'+ fullDocPath);
        
        String stringToSign = 'DELETE\n\n\n'+formattedDateString+'\n/'+ bucket +'/'+ fullDocPath;
        
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization',authHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
    }
    
    
    @future(callout=true) public static void deleteAndMoveFile(string bucket, string fullDocPath, string newDocpath, string key, string secret)
    {
        String formattedDateString = Datetime.now().formatGMT('EEE,   dd MMM yyyy HH:mm:ss z');
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('Host', 's3.amazonaws.com');
        req.setHeader('Date', formattedDateString);
        req.setHeader('x-amz-copy-source', bucket +'/'+ fullDocPath);
        req.setEndpoint('https://s3.amazonaws.com/'+ bucket +'/'+ newDocpath); 

        System.debug(bucket +'/'+ fullDocPath);
        
        String stringToSign = 'PUT\n\n\n'+formattedDateString+'\nx-amz-copy-source:'+bucket +'/'+ fullDocPath +'\n/'+ bucket +'/'+ newDocpath;
        
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization',authHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('RESPONSE STRING: ' + res.toString());
        System.debug('RESPONSE STATUS: ' + res.getStatus());
        System.debug('STATUS_CODE: ' + res.getStatusCode());
        
        S3Service.deleteFile(bucket, fullDocPath, key, secret);
    }
    
    public static HTTPResponse uploadObject(AWS_Document__c record, AWS_Credentials_Settings__c setting,Blob fileBlob,Integer fileSize,String contentType)
    {
        System.debug('Called the main method');
        String now = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String host='s3.amazonaws.com';
        String method = 'PUT';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://s3.amazonaws.com/' + record.Folder__c + record.Name.replace(' ', '+'));
        req.setHeader('Host', setting.Bucket_Name__c + '.' + host);
        req.setHeader('Content-Length', String.valueOf(fileSize));
        req.setHeader('Content-type', contentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', now);
        req.setHeader('x-amz-acl', setting.ACL__c);
        req.setBodyAsBlob(fileBlob);
        
        String stringToSign = method+'\n\n' 
            +contentType + '\n'
            + now +'\nx-amz-acl:'+setting.ACL__c+'\n/'+ setting.Bucket_Name__c +'/'+ record.Folder__c + record.Name.replace(' ', '+');
        
        String signed = createSignature(stringToSign,setting.Secret__c);
        String authHeader = 'AWS' + ' ' + setting.Key__c + ':' + signed;
        req.setHeader('Authorization',authHeader);
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
        
    }
    
    private static string createSignature(string canonicalBuffer,String secret){
        string sig;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(canonicalBuffer),blob.valueof(secret));
        sig = EncodingUtil.base64Encode(mac);
        return sig;
    }
    
}