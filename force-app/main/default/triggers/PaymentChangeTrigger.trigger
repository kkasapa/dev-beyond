trigger PaymentChangeTrigger on nu_dse__Payment__ChangeEvent (after insert) {

    new PaymentChangeHandler().run();
    /*Set<String> paymentIds = new Set<String>();    
    
    for (nu_dse__Payment__ChangeEvent paymentChange : trigger.new) {

        Set<String> changeFieldsToTrigger = new Set<String> {'nu_dse__Transaction_Status__c', 'nu_dse__Schedule_Date__c', 
                                        'nu_dse__Amount__c', 'nu_dse__Monthly_Maintenance_Fee__c', 'nu_dse__Monthly_Third_Party_Fees__c',
                                        'nu_dse__Monthly_Other_Fee__c', 'nu_dse__Processor_Fee__c', 'nu_dse__Ancillary_Fee__c', 
                                        'nu_dse__Retainer_Fee__c', 'nu_dse__Service_Fee__c', 'nu_dse__Admin_Fee__c'};

        EventBus.ChangeEventHeader header = paymentChange.ChangeEventHeader;
        changeFieldsToTrigger.retainAll(header.changedFields);
        if(header.changetype == 'CREATE' 
            || changeFieldsToTrigger.isEmpty() == false) {

            List<String> recordIds = paymentChange.ChangeEventHeader.getRecordIds();
            paymentIds.addAll(recordIds);
        }
        system.debug('nu_dse__Transaction_Status__c:::'+ paymentChange.nu_dse__Transaction_Status__c);
    }

    if(paymentIds.isEmpty() == false) {

        Set<Id> programIds = new Set<Id>();

        for(nu_dse__Payment__c payment : [SELECT Id, nu_dse__Program__c FROM nu_dse__Payment__c
                                         WHERE Id IN :paymentIds]) {

            programIds.add(payment.nu_dse__Program__c);
        }
    }*/
}