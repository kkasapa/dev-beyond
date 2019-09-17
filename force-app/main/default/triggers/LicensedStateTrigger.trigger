trigger LicensedStateTrigger on Licensed_State__c (after insert, after update,before insert,before update) {
    if(trigger.isBefore){
    	if(trigger.isInsert || trigger.isUpdate){
            LicensedStateTriggerHandler.checkStateCodesUnique(trigger.new,trigger.oldmap);
        }	    
    }else if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            LicensedStateTriggerHandler.updateStateCodes(trigger.new,trigger.oldmap);
        }      
    }
}