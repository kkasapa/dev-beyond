trigger BusinessHours on nu_dse__Prospect__c (before insert) {
BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
    if ((Trigger.isBefore)&&(Trigger.isInsert)){
        for (nu_dse__Prospect__c so : Trigger.new) {
            if ((bh != NULL)) {
                datetime currenttime = system.now();
                Boolean isWithin= BusinessHours.isWithin(bh.id, currenttime);
                system.debug('--isWithin'+isWithin);
                system.debug('--currenttime'+currenttime);
                if(isWithin){
                    so.Off_Business_Hours__c = false;              
                }else{
                    so.Off_Business_Hours__c = true;              
                }   
            }
        }
    }
}