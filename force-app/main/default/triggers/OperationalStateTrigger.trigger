trigger OperationalStateTrigger on Operational_State__c (after insert, after update,before insert,before update, after delete) {
	new OperationalStateTriggerHandler().run();
}