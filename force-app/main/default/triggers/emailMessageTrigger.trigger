trigger emailMessageTrigger on EmailMessage (after insert) {

    new EmailMessageHandler().run();
}