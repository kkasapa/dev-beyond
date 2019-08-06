trigger GenerateUUIDForProspectsTrigger on nu_dse__Prospect__c (before insert, before update) {
    for(nu_dse__Prospect__c p : Trigger.new){
        if(p.uuid__c == null){
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            p.uuid__c = guid;
            System.debug('Generating UUID for prospect with name = ' + p.Name);
        }
    }
}