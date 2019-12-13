/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Trigger for Assignment object 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Digu 
* @modifiedBy     
* @maintainedBy   Digu
* @version        1.0
* @created        2019-12-11
* @modified       2019-12-11
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger AssignmentTrigger on Assignment__c (after insert) {
    
    if(Switch__c.getValues('Assignment').Turn_Off__c== False){
        system.debug('I am Fired');
    new AssignmentHandler().run();
    }

}