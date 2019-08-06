trigger ProspectEventTrigger on Event (after insert, after update) {
  if(Trigger.New[0].WhatId != null){  
    for(Event e : Trigger.New){
        String Prospect_Prefix = Schema.SObjectType.nu_dse__Prospect__c.getKeyPrefix();
        ((String)Trigger.New[0].WhatId).startsWith(Prospect_Prefix);
          if(Prospect_Prefix == 'a0N' && Trigger.New[0].StartDateTime > System.Now()){
             Event[] evnts = Trigger.new;
             ProspectOpenEventTrigger.checkOpenEvents(evnts);
          }
          if(Prospect_Prefix == 'a0L' && Trigger.New[0].StartDateTime > System.Now()){
             Event[] evnts = Trigger.new;
             ProspectOpenEventTrigger.checkOpenEvents(evnts);
          }
    }
  }
}