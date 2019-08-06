/*********************************************************************************
This controller will grab the three parameters From, To, and Body when the Twilio
HTTP request is made.  Once we have the From number (which is the sender's number)
we can use it to query Salesforce for a Contact matching that (presumably) mobile
number.  When we've found a matching Contact we create a closed Task to record the
message of the incoming text, and it will now show up under the Activity History
related list for this Contact
*********************************************************************************/
public without sharing class TwilioListenerController {

    // Set instance variables to capture the To, From, and Body Parameters that Twilio sends in the HTTP request
    public String fromNumber = ApexPages.currentPage().getParameters().get('From');
    public String toNumber = ApexPages.currentPage().getParameters().get('To');
    public String body = ApexPages.currentPage().getParameters().get('Body');
    public PageReference response = new PageReference('http://your_site_url/TwilioResponse');

    // This is the initial method that gets called when the TwilioResponse page loads
    public PageReference init() {
    
        // Helpful with debugging
        System.debug('FROM: ' + fromNumber);
        System.debug('TO: ' + toNumber);
        System.debug('BODY: ' + body);

        // If we capture all of the parameters successfully, call the saveIncomingText() method
        if(fromNumber != null && toNumber != null && body != null) {
            response = saveIncomingText();
            return response;
        }

        return null;
    }

    private PageReference saveIncomingText() {
    
        // Call the method to clean the incoming phone number
        String cleanFromNumber = formatPhone(fromNumber);
        Attachment attachmentInstance;
        
        System.debug('cleanFromNumber-->'+cleanFromNumber);
        
        List<nu_dse__Offer__c> offers = [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.nu_dse__SSN__c,
                                            nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone, 
                                            nu_dse__Program__r.nu_dse__Account__r.nu_dse__Cell_phone__c, nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone 
                                            FROM nu_dse__Offer__c WHERE Notification_Status__c = 'Notified' AND nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone = :cleanFromNumber LIMIT 1];
        
        System.debug('Offers-->'+offers);
        if (offers.isEmpty() == FALSE) {
        
            String lastFourDigitsofSSN = offers[0].nu_dse__Program__r.nu_dse__Account__r.nu_dse__SSN__c.substring(7,11);
            
            String taskSub = offers[0].Name + ' Accepted Instant SMS';
                
            List<Task> taskList =  [SELECT Id, Description FROM Task WHERE Subject  = :taskSub AND WhatId IN :offers AND Status = 'Waiting on someone else' LIMIT 1];
            
            System.debug('Offers-->'+taskList);
            
            // Create a new Task to store the record of the incoming text, then attach it to the appropriate Account
            if(taskList.isEmpty() == false) {
            
                Task text = new Task(Id = taskList[0].Id);
                text.Inbound_Message__c = body;
                text.Status = 'Completed';
                nu_dse__Offer__c offertoUpdate = new nu_dse__Offer__c(Id= offers[0].Id);
                
                if (body.endsWith(lastFourDigitsofSSN)) {
                    
                    text.Type = 'SSN Match';
                    offertoUpdate.Notification_Status__c = 'Authorized';
                    String pageReferenceURL = '/apex/'+ 'TwilioConversationPage?smsbody=' + taskList[0].Description+'&response='+body+'&phone='+cleanFromNumber;
                    
                    PageReference twilioConversationPageRef = new PageReference(pageReferenceURL);
                    Blob conversationBlob = twilioConversationPageRef.getContentAsPdf();
                    
                    attachmentInstance = new Attachment();
                    attachmentInstance.Name = 'AUTHORIZATION-WRITTEN-'+ offers[0].Name;
                    attachmentInstance.Body = conversationBlob;
                    attachmentInstance.ParentId = offers[0].Id;
                    attachmentInstance.ContentType = 'pdf';
                    
                } else {
                
                    text.Type = 'SSN not Match';
                    offertoUpdate.Notification_Status__c = 'Denied';
                }
                
                // Insert the Incoming Text object and return the response page.
                try {
                   
                    update text;
                    insert attachmentInstance;
                    update offertoUpdate;
                    return response;
                   
                } catch(DmlException e) {
                
                  System.debug('INSERT TASK FAILED: ' + e);
                
                }
            }
        }
        return response;
    }

    // Twilio sends the phone number as +15555551234.  We have to reformat the string to (555) 555-1234
    private String formatPhone(String fromNumber) {
    
        String areaCode = fromNumber.substring(2,5);
        String prefix = fromNumber.substring(5,8);
        String last4 = fromNumber.substring(8);
        String formattedPhone = '(' + areaCode +')' + ' ' + prefix + '-' + last4;
        System.debug('FORMATTED PHONE IS: ' + formattedPhone);
        return formattedPhone;
    }
}