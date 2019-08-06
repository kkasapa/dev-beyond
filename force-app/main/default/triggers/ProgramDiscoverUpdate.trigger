trigger ProgramDiscoverUpdate on nu_dse__TradeLine__c (after insert, after update) {
    set<String> setProgramIds = new Set<String>();
    Map<String,Boolean> mapProgramIdFlag = new Map<String,Boolean>();
    for(nu_dse__TradeLine__c objTradeLine : Trigger.new){
        if(String.isNotBlank(objTradeLine.nu_dse__Program__c)){
            setProgramIds.add(objTradeLine.nu_dse__Program__c);
            mapProgramIdFlag.put(objTradeLine.nu_dse__Program__c,false);
        }
    }
    system.debug('-----mapProgramIdFlag'+mapProgramIdFlag);
    system.debug('-----setProgramIds'+setProgramIds);
    List<nu_dse__TradeLine__c> lstTRadeLines = [SELECT Id,nu_dse__Include_In_The_Program__c,nu_dse__Original_Creditor__c,nu_dse__Program__c ,nu_dse__Original_Creditor__r.Name,nu_dse__New_Creditor__c,nu_dse__New_Creditor__r.name FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c IN:setProgramIds];
    if(lstTRadeLines != null && !lstTRadeLines.isEmpty()){
        for(nu_dse__TradeLine__c objTradeLine : lstTRadeLines){
          
           if((objTradeLine.nu_dse__Original_Creditor__c != null && objTradeLine.nu_dse__Original_Creditor__r.Name == 'Discover') || 
               (objTradeLine.nu_dse__New_Creditor__c != null && objTradeLine.nu_dse__New_Creditor__r.Name == 'Discover')){
                if(objTradeLine.nu_dse__Include_In_The_Program__c){
                    mapProgramIdFlag.put(objTradeLine.nu_dse__Program__c,true);
                }else{
                    mapProgramIdFlag.put(objTradeLine.nu_dse__Program__c,false);
               }
               //mapProgramIdFlag.put(objTradeLine.nu_dse__Program__c,true);
           }
          
        }
    }
    
    List<nu_dse__Program__c> lstProgram = new List<nu_dse__Program__c>();
    for(String programId : setProgramIds){
        nu_dse__Program__c objProgram = new nu_dse__Program__c(Id=programId);
        objProgram.Discover_Included__c = mapProgramIdFlag.get(programId);
        
        lstProgram.add(objProgram);
    }
        system.debug('-----lstProgram'+lstProgram);
    system.debug('-----mapProgramIdFlag30'+mapProgramIdFlag);

    if(lstProgram != null && !lstProgram.isEmpty())
        update lstProgram;
}