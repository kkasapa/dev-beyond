trigger ProspectTaskTrigger on Task (after insert, after update) {
    if(Trigger.New[0].WhatId != null && Trigger.New[0].Status != 'Completed'){
        String Prospect_Prefix = Schema.SObjectType.nu_dse__Prospect__c.getKeyPrefix();
        ((String)Trigger.New[0].WhatId).startsWith(Prospect_Prefix);
    if(Prospect_Prefix == 'a0N'){
            List<Id> taskIdList = new List<Id>();
            List<Task> tsks = Trigger.New;
    
            for(Task t : tsks){
                        taskIdList.add(t.WhatId);
            }
            ProspectOpenTaskTrigger.checkOpenTasks(taskIdList);
        }
    }
}