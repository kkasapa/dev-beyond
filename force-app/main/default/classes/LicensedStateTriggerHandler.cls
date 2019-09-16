public class LicensedStateTriggerHandler {
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
                stateCodes.State_Codes__c = strCodes;
                upsert stateCodes;
            }
        }       			
    }
}