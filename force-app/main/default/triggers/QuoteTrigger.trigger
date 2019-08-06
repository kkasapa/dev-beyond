trigger QuoteTrigger on nu_dse__Quote__c (before insert, after insert,after update) {

    QuoteHandler.handle(trigger.oldMap, trigger.newMap);
}