trigger ProsToTaskSrcValue on Task (before insert, before update) { 

    Set<Id> prosIds = new Set<Id>(); 
    Map<Id, nu_dse__prospect__c> prosMap = new Map<Id, nu_dse__prospect__c>();  

    for(Task t : trigger.new){ 
        
        if(t.WhatId != null){
        Id wId = t.WhatId;
            string prosobj = wId.getSObjectType().getDescribe().getName();
            if(prosObj =='nu_dse__prospect__c' && (t.Five9__Five9SessionId__c != null && t.Five9__Five9SessionId__c != '')){
                prosIds.add(t.WhatId); 
            }
         }    
    } 

    if(!prosIds.isempty()){
         List<nu_dse__prospect__c> lstProspects = [SELECT Id,nu_dse__Affiliate__c from nu_dse__prospect__c where id IN:prosIds];
         if(!lstProspects.isempty()){
             for(nu_dse__prospect__c p : lstProspects){ 
                prosMap.put(p.Id,p);      
             }
         } 
     }
     for(Task t : trigger.new){ 
         
         if(t.WhatId != null){
         Id wId = t.WhatId;
             string prosobj = wId.getSObjectType().getDescribe().getName();
             if(prosObj == 'nu_dse__prospect__c'){
                 nu_dse__prospect__c thisPros = prosMap.get(t.WhatId);
                 if(thisPros != null&& (thisPros.nu_dse__Affiliate__c != null && thisPros.nu_dse__Affiliate__c != '')){
                     t.UTM_Value__c = thisPros.nu_dse__Affiliate__c;
                } 
            } 
        } 
    }
 }