/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* AWSSQS class will extend class AWS. Initiates the SQS parameters
* 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         brianmfear   https://gist.github.com/brianmfear/db444a87f35a5a6348784a683b4cbd18
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-04-08
* @modified       2019-04-08
* @systemLayer    Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AWSSQS {
    abstract class Core extends AWS {
        Core() {
            super();
            method = HttpMethod.XGET;
            payload = Blob.valueOf('');
        }
        public virtual override void init() {
            AWS_SQS_Credentials__c credential = [Select accessKey__c, endpointURL__c, host__c, region__c, secret_access_key__c, service__c 
                                                from AWS_SQS_Credentials__c where Description__c = 'BLP SQS Queue' limit 1];
            endpoint = new Url(credential.endpointURL__c);          //endpoint is data type url
            resource = credential.endpointURL__c;                   //resource is data type string
            accessKey = credential.accessKey__c;
            region = credential.region__c;
            service = credential.service__c;
            secretKey = credential.secret_access_key__c;
            host = credential.host__c;

            setQueryParam('QueueUrl', resource);
	        setHeader('Date', requestTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\''));
            setQueryParam('Version','2012-11-05');
            setQueryParam('AWSAccessKeyID', accessKey);
            setQueryParam('Timestamp', requestTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            setQueryParam('SignatureVersion', '4');
            setQueryParam('SignatureMethod','HmacSHA256');
            setHeader('Accept','application/json');
            //	Prevent leaking the secret key by only exposing the signing key
            createSigningKey(secretKey);
        }
    }

    public class SendMessageRequest extends Core {

        public void execute(String msgBody) {
            setQueryParam('Action','SendMessage');
            setQueryParam('MessageBody', msgBody);
            sendRequest();
        }
        
        public void executeAttrib(String msgBody, 
            String msgAttributeName, String msgAttributeVal, String msgAttributeType,
            String msgAttributeName_2, String msgAttributeVal_2, String msgAttributeType_2) {
            setQueryParam('Action','SendMessage');
            setQueryParam('MessageBody', msgBody);
            setQueryParam('MessageAttribute.1.Name', msgAttributeName);
            setQueryParam('MessageAttribute.1.Value.StringValue', msgAttributeVal);
            setQueryParam('MessageAttribute.1.Value.DataType', msgAttributeType);
            setQueryParam('MessageAttribute.2.Name', msgAttributeName_2);
            setQueryParam('MessageAttribute.2.Value.StringValue', msgAttributeVal_2);
            setQueryParam('MessageAttribute.2.Value.DataType', msgAttributeType_2);
            sendRequest();
        }
    }

    //method to send message only (with no attributes)
    public static void sendMessage(String msgBody) {
        SendMessageRequest req = new SendMessageRequest();
        req.execute(msgBody);
    }

    //method to send message with 1 attribute
    @future(callout=true)
    public static void sendMessageAttrib(String msgBody, 
        String msgAttributeName, String msgAttributeVal, String msgAttributeType, 
        String msgAttributeName_2, String msgAttributeVal_2, String msgAttributeType_2 ) {
        SendMessageRequest req = new SendMessageRequest();
        
        req.executeAttrib(msgBody, msgAttributeName, msgAttributeVal, msgAttributeType, msgAttributeName_2, msgAttributeVal_2, msgAttributeType_2);
    }

    //this method is not required and deprecated as the process logic was converted to trigger.
   /*@InvocableMethod(label='Send Message to SQS Queue' description='Send Message to SQS Queue.')
    //method to send message with 1 attribute, Invocable from process/flow
    public static void sendMessageInvocable(List<CreateSQSMessgeRequest> requestList) {
        for(CreateSQSMessgeRequest request : requestList){
            sendMessageAttrib(request.msgBody, 
                request.msgAttributeName, request.msgAttributeVal, request.msgAttributeType, 
                request.msgAttributeName_2, request.msgAttributeVal_2, request.msgAttributeType_2);
        }
    }
    */

    public class CreateSQSMessgeRequest {
        
       @InvocableVariable(required=true)
       public String msgBody;
       @InvocableVariable(required=true)
       public String msgAttributeName;
       @InvocableVariable(required=true)
       public String msgAttributeVal;
       @InvocableVariable(required=true)
       public String msgAttributeType; 
       @InvocableVariable(required=true)
       public String queueName;
        @InvocableVariable(required=true)
       public String msgAttributeName_2;
       @InvocableVariable(required=true)
       public String msgAttributeVal_2;
       @InvocableVariable(required=true)
       public String msgAttributeType_2; 
    } 
}