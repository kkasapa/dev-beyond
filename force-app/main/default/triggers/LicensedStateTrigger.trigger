trigger LicensedStateTrigger on Licensed_State__c (after insert, after update,before insert,before update) {
    new LicensedStateTriggerHandler().run();
}