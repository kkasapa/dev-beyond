public class LicensedStateTriggerHandler {
    
    public static void checkStateCodesUnique(list<Licensed_State__c> lstOfStatesRecords,map<Id,Licensed_State__c> mapOfOldStateRecs){
    	boolean isUpdate = false;
        if(mapOfOldStateRecs != null && !mapOfOldStateRecs.isEmpty()){
        	isUpdate = true;    
        }
        set<string> setOfStates = new set<string>();
        for(Licensed_State__c lsObj : lstOfStatesRecords){
        	if((!isUpdate && lsObj.State__c != null) || 
               (isUpdate && mapOfOldStateRecs != null && (lsObj.State__c != mapOfOldStateRecs.get(lsObj.Id).State__c && lsObj.State__c != null))){
            	if(!setOfStates.contains(lsObj.State__c)){
                	setOfStates.add(lsObj.State__c);    
                }else{
                	lsObj.addError('Duplicate State');	 	   
                }                   
        	}    
        }
        list<Licensed_State__c> lstOfStates = [SELECT Id FROM Licensed_State__c WHERE State__c IN:setOfStates];
        for(Licensed_State__c lsObj : lstOfStatesRecords){
            if((!isUpdate && lstOfStates.Size() > 0) || (isUpdate && lstOfStates.Size() >= 1)){
            	lsObj.addError('Duplicate State');	    
            }	    
        }
    }
    public static void updateStateCodes(list<Licensed_State__c> lstOfStatesRecords,map<Id,Licensed_State__c> mapOfOldStateRecs){
        boolean isUpdate = false;
        if(mapOfOldStateRecs != null && !mapOfOldStateRecs.isEmpty()){
        	isUpdate = true;    
        }  
        list<Licensed_State__c> lstOfRecords = new list<Licensed_State__c>();
        for(Licensed_State__c lsObj : lstOfStatesRecords){
			if((!isUpdate && lsObj.State__c != null && lsObj.Active__c) || 
            (isUpdate && mapOfOldStateRecs != null && ((lsObj.State__c != mapOfOldStateRecs.get(lsObj.Id).State__c && lsObj.State__c != null) || lsObj.Active__c != mapOfOldStateRecs.get(lsObj.Id).Active__c))){
            	lstOfRecords.add(lsObj);
        	}            
        }
        if(!lstOfRecords.isEmpty()){
            set<string> setOfStateCodes = new set<string>();
            for(Licensed_State__c lsObj : [SELECT Id,State__c,Active__c FROM Licensed_State__c LIMIT 500000]){
                if(lsObj.Active__c && lsObj.State__c != null){
                	setOfStateCodes.add(lsObj.State__c);    
                }    
            }
            if(!setOfStateCodes.isEmpty()){
                string strCodes = '';
                for(string strCode : setOfStateCodes){
                	strCodes += strCode+';';    
                }
                strCodes = strCodes.substring(0,strCodes.length()-1);
            	License_State__c stateCodes = License_State__c.getOrgDefaults();
                stateCodes.ADR_Beyond_Overlapping_States__c = strCodes;
                upsert stateCodes;
            }
        }       			
    }
}