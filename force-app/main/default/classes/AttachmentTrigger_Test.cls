/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for AttachmentTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly Mathews   <rmathews@beyondfinance.com>
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-04-08
* @modified       2019-04-08
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class AttachmentTrigger_Test {
    
    public static List<Attachment> createAttachment(Integer count){
        List<Attachment> atts = new List<Attachment>();
        
        nu_dse__Program__c pgObj = new nu_dse__Program__c(
            
        );
        insert pgObj; 
                    
        for(Integer i=0;i<count;i++){
            Attachment att = new Attachment(
                ParentID=pgObj.Id,
                Name='TestAttachment'+i,
                Body = blob.ValueOf('Test'),
                ContentType = 'PDF'
            );
            atts.add(att);
        }
        insert atts;
        return atts;
    }
    
    static testMethod void validateHelloWorld() {
        
        AWS_Credentials_Settings__c settObj = new AWS_Credentials_Settings__c(
            Key__c = 'Key',Secret__c = 'Secret' ,Bucket_Name__c = 'Name',ACL__c = 'ACL', Name = 'Test' 
        );
        insert settObj;
        AttachmentTrigger_Test.createAttachment(1); 
    }
}