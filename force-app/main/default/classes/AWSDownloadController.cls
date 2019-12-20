public class AWSDownloadController {


/*
    public Document documents{get;set;}
    public String currentRecordId{get;set;}  
    public Attachment imageAttachment {get;set;}
    
    public pagereference sendEmail(){
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id'); 
        imageAttachment = [Select Id,Body, Name, ContentType from Attachment where ParentId =: currentRecordId];
        string linkToPdf = 'servlet/servlet.FileDownload?file='+imageAttachment.Id;
        //Document documents = [select Id, Body, ContentType, BodyLength from Document where Id= '0153J0000008z0F'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String email = 'Shravan.Dasari@avcoconsulting.com';
        Blob body;
        body = imageAttachment.Body;
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('testPdf.pdf');
        attach.setInline(false);
        attach.Body = body;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] { email });
        mail.setSubject('PDF Email Demo');
        mail.setHtmlBody('Here is the email you requested! Check the attachment!');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF sent to '+email));        
        //return new PageReference('/' + currentRecordId);
        
        return new PageReference('/' + linkToPdf);
    }
    */
}