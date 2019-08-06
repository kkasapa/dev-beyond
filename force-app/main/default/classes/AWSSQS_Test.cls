/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for AttachmentTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-04-15
* @modified       2019-04-15
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class AWSSQS_Test {
    
    @isTest static void validateAWSSQS() {
        AWS_SQS_Credentials__c credential = new AWS_SQS_Credentials__c(
            accessKey__c = 'access',             
            endpointURL__c = 'https://sqs.us-east-1.amazonaws.com/603521395019/staging_debt-manager-addon-legal_new-program', 
            host__c = 'host', 
            region__c = 'region', 
            secret_access_key__c='secret', 
            service__c='service', 
            Description__c='BLP SQS Queue');

        insert credential;
        try{
            AWSSQS.sendMessageAttrib('PROGRAM', 'program_id','test prog.Id','String','program_id','test prog.Id','String');            
        }catch(Exception Ex){}
        try{
            AWSSQS.sendMessage('PROGRAM');            
        }catch(Exception Ex){}
        try{
            AWSSQS.CreateSQSMessgeRequest smr = new AWSSQS.CreateSQSMessgeRequest();
            /*smr.msgBody='PROGRAM';
            msgAttributeName='program_id';
            msgAttributeVal='test prog.Id';
            msgAttributeType='String';
            queueName='test Q';
            
*/

            List<AWSSQS.CreateSQSMessgeRequest> smrlist= new List<AWSSQS.CreateSQSMessgeRequest>();                    
            smrlist.add(smr);

            AWSSQS.sendMessageInvocable(smrlist);            
        }catch(AWS.ServiceException Ex){}

    }
    
}