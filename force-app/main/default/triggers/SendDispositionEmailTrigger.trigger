trigger SendDispositionEmailTrigger on nu_dse__Prospect__c (before insert, before update) {
    for(nu_dse__Prospect__c p : Trigger.new){
        String disposition = p.nu_dse__Last_Disposition__c;
        String dispositionEmailType = p.Disposition_Email_Type__c;
        if (dispositionEmailType == null){
            if(disposition == 'Disqualified' || disposition == 'LTLending'){
                if (disposition == 'Disqualified'){
                    List<TU_Permission_Audit__c> permissionAuditList = [SELECT Id, uuid__c, Created_At__c FROM TU_Permission_Audit__c WHERE uuid__c = :p.uuid__c];
                    if (!permissionAuditList.isEmpty()){
                        p.Disposition_Email_Type__c = 'PullTU-NotQualified';
                    }
                }else{
                    p.Disposition_Email_Type__c = 'LTLending';
                }   
            }
        }
    }
}