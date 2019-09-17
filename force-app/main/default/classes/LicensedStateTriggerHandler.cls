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
            (isUpdate && mapOfOldStateRecs != null && (
                (lsObj.State__c != mapOfOldStateRecs.get(lsObj.Id).State__c && lsObj.State__c != null) || 
                lsObj.Active__c != mapOfOldStateRecs.get(lsObj.Id).Active__c || 
                lsObj.ADR_Beyond_Overlapping_States__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Beyond_Overlapping_States__c ||
                lsObj.ADR_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Operational_State__c ||
                lsObj.ADR_Selling_to_ClearOne__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Selling_to_ClearOne__c || 
                lsObj.ADR_Sell_to_GRT__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_GRT__c ||
                lsObj.ADR_Sell_to_Signature__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_Signature__c ||
                lsObj.Beyond_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).Beyond_Operational_State__c || 
                lsObj.Discounted_and_Free_Legal__c != mapOfOldStateRecs.get(lsObj.Id).Discounted_and_Free_Legal__c ||
                lsObj.Full_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Full_BLP_States__c ||
                lsObj.Limited_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Limited_BLP_States__c
            ))){
            	lstOfRecords.add(lsObj);
        	}            
        }
        if(!lstOfRecords.isEmpty()){
            set<string> setOfStateCodes = new set<string>();
            set<string> setOf1 = new set<string>();set<string> setOf2 = new set<string>();set<string> setOf3 = new set<string>();
            set<string> setOf4 = new set<string>();set<string> setOf5 = new set<string>();set<string> setOf6 = new set<string>();
            set<string> setOf7 = new set<string>();set<string> setOf8 = new set<string>();set<string> setOf9 = new set<string>();
            
            for(Licensed_State__c lsObj : [SELECT Id,State__c,Active__c,ADR_Beyond_Overlapping_States__c,
                                           ADR_Operational_State__c,ADR_Selling_to_ClearOne__c,ADR_Sell_to_GRT__c,
                                           ADR_Sell_to_Signature__c,Beyond_Operational_State__c,Discounted_and_Free_Legal__c,
                                           Full_BLP_States__c,Limited_BLP_States__c
                                           FROM Licensed_State__c WHERE Active__c = TRUE AND State__c != null LIMIT 500000]){
            	setOfStateCodes.add(lsObj.State__c);   
                if(lsObj.ADR_Beyond_Overlapping_States__c){
                	setOf1.add(lsObj.State__c);
                }
                if(lsObj.ADR_Operational_State__c){
                	setOf2.add(lsObj.State__c);    
                }
                if(lsObj.ADR_Selling_to_ClearOne__c){
                	setOf3.add(lsObj.State__c);    
                } 
                if(lsObj.ADR_Sell_to_GRT__c){
                	setOf4.add(lsObj.State__c);    
                } 
                if(lsObj.ADR_Sell_to_Signature__c){
                	setOf5.add(lsObj.State__c);    
                } 
                if(lsObj.Beyond_Operational_State__c){
                	setOf6.add(lsObj.State__c);    
                }
                if(lsObj.Discounted_and_Free_Legal__c){
                	setOf7.add(lsObj.State__c);    
                } 
                if(lsObj.Full_BLP_States__c){
                	setOf8.add(lsObj.State__c);    
                }
                if(lsObj.Limited_BLP_States__c){
                	setOf9.add(lsObj.State__c);    
                }
                                               
            }
            if(!setOfStateCodes.isEmpty()){
                License_State__c stateCodes = License_State__c.getOrgDefaults();
                stateCodes.ADR_Beyond_Overlapping_States__c = prepareStates(setOf1);
                stateCodes.ADR_Operational_States__c = prepareStates(setOf2);
                stateCodes.ADR_Selling_to_ClearOne_States__c = prepareStates(setOf3);
                stateCodes.ADR_Sell_to_GRT_States__c = prepareStates(setOf4);
                stateCodes.ADR_Sell_to_Signature_States__c = prepareStates(setOf5);
                stateCodes.Beyond_Operational_States__c = prepareStates(setOf6);
                stateCodes.Discounted_and_Free_Legal_States__c = prepareStates(setOf7);
                stateCodes.Full_BLP_States__c = prepareStates(setOf8);
                stateCodes.Limited_BLP_States__c = prepareStates(setOf9);
                upsert stateCodes;
            }
        }       			
    }
    
    public static string prepareStates(set<string> setOfStateCodes){
    	string strCodes = '';
        for(string strCode : setOfStateCodes){
            strCodes += strCode+';';    
        }
        if(strCodes.length() > 0)
        strCodes = strCodes.substring(0,strCodes.length()-1);   
        return strCodes;
    }
}