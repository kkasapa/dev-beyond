public with sharing class EmailMessageHandler extends TriggerHandler {
    
    private Map<Id, EmailMessage> newEmailMessageMap;

    public EmailMessageHandler() {

        this.newEmailMessageMap = (Map<Id, EmailMessage>) Trigger.newMap;
    }

    public override void afterInsert() {

        for (EmailMessage newEmailMessage : (List<EmailMessage>)Trigger.New) {
           
            // mark the payments for creating deposit reminders
            createTaskAtchRec(newEmailMessage);
        }
    }

    public void createTaskAtchRec(EmailMessage newEmailMessage) {
        
        system.debug('newEmailMessage::'+newEmailMessage);
    }
}
