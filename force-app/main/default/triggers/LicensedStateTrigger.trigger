trigger LicensedStateTrigger on Licensed_State__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            LicensedStateTriggerHandler.updateStateCodes(trigger.new,trigger.oldmap);
        }else if(trigger.isUpdate){
            LicensedStateTriggerHandler.updateStateCodes(trigger.new,trigger.oldmap);            
        }       
    }
}