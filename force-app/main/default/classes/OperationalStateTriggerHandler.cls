public class OperationalStateTriggerHandler extends TriggerHandler {
    
    private Map<Id, Operational_State__c> newStatesMap;
    private Map<Id, Operational_State__c> oldStatesMap;
    private list<Operational_State__c> newStates;
    
    public OperationalStateTriggerHandler() {
        this.newStatesMap = (Map<Id, Operational_State__c>) Trigger.newMap;
        this.oldStatesMap = (Map<Id, Operational_State__c>) Trigger.oldMap;
        this.newStates 	  = (list<Operational_State__c>) Trigger.new;
    }
    
    public override void beforeInsert() {
    	OperationalStateTriggerHandler.checkStateCodesUnique(newStates,oldStatesMap);    
    }
    
    public override void beforeUpdate() {
    	   
    }
    
    public override void afterDelete() {
    	OperationalStateTriggerHandler.updateStateCodes(null,null,true); 	   
    }
    
    public override void afterInsert() {
    	OperationalStateTriggerHandler.updateStateCodes(newStates,oldStatesMap,false);    
    }
    
    public override void afterUpdate() {
        OperationalStateTriggerHandler.checkStateCodesUnique(newStates,oldStatesMap);
    	OperationalStateTriggerHandler.updateStateCodes(newStates,oldStatesMap,false);    
    }
    
    
    public static map<string,list<string>> mapOfKeyWithStates = new map<string,list<string>>();
    public static void checkStateCodesUnique(list<Operational_State__c> lstOfStatesRecords,map<Id,Operational_State__c> mapOfOldStateRecs){
    	boolean isUpdate = false;
        if(mapOfOldStateRecs != null && !mapOfOldStateRecs.isEmpty()){
        	isUpdate = true;    
        }
        set<string> setOfStates = new set<string>();
        for(Operational_State__c lsObj : lstOfStatesRecords){
        	if((!isUpdate && lsObj.State__c != null) || 
               (isUpdate && mapOfOldStateRecs != null && (
                (lsObj.State__c != mapOfOldStateRecs.get(lsObj.Id).State__c && lsObj.State__c != null) || 
                lsObj.ADR_Beyond_Overlapping_States__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Beyond_Overlapping_States__c ||
                lsObj.ADR_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Operational_State__c ||
                lsObj.ADR_Selling_to_ClearOne__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Selling_to_ClearOne__c || 
                lsObj.ADR_Sell_to_GRT__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_GRT__c ||
                lsObj.ADR_Sell_to_Signature__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_Signature__c ||
                lsObj.Beyond_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).Beyond_Operational_State__c || 
                lsObj.Discounted_and_Free_Legal__c != mapOfOldStateRecs.get(lsObj.Id).Discounted_and_Free_Legal__c ||
                lsObj.Full_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Full_BLP_States__c ||
                lsObj.Limited_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Limited_BLP_States__c ||
                lsObj.CFT__c != mapOfOldStateRecs.get(lsObj.Id).CFT__c ||
                lsObj.ClearOne_GCS__c != mapOfOldStateRecs.get(lsObj.Id).ClearOne_GCS__c   
            	))){
            	setOfStates.add(lsObj.State__c);                   
        	}    
        }
        if(!setOfStates.isEmpty()){
            list<Operational_State__c> lstOfStates = [SELECT Id,State__c,ADR_Beyond_Overlapping_States__c,
                                                   ADR_Operational_State__c,ADR_Selling_to_ClearOne__c,ADR_Sell_to_GRT__c,
                                                   ADR_Sell_to_Signature__c,Beyond_Operational_State__c,Discounted_and_Free_Legal__c,
                                                   Full_BLP_States__c,Limited_BLP_States__c,CFT__c,ClearOne_GCS__c
                                                   FROM Operational_State__c WHERE State__c IN:setOfStates];
            for(Operational_State__c lsObj : lstOfStates){
                
                if(lsObj.ADR_Beyond_Overlapping_States__c){
                    prepareStateAsKey('1',lsObj);
                }
                if(lsObj.ADR_Operational_State__c){
                    prepareStateAsKey('2',lsObj);                
                }
                if(lsObj.ADR_Selling_to_ClearOne__c){
                    prepareStateAsKey('3',lsObj);                
                }
                if(lsObj.ADR_Sell_to_GRT__c){
                    prepareStateAsKey('4',lsObj);                
                }
                if(lsObj.ADR_Sell_to_Signature__c){
                    prepareStateAsKey('5',lsObj);                
                }
                if(lsObj.Beyond_Operational_State__c){
                    prepareStateAsKey('6',lsObj);                
                }
                if(lsObj.Discounted_and_Free_Legal__c){
                    prepareStateAsKey('7',lsObj);               
                }
                if(lsObj.Full_BLP_States__c){
                    prepareStateAsKey('8',lsObj);                
                }
                if(lsObj.Limited_BLP_States__c){
                    prepareStateAsKey('9',lsObj);                
                }
                if(lsObj.CFT__c){
                    prepareStateAsKey('10',lsObj);                
                }
                if(lsObj.ClearOne_GCS__c){
                    prepareStateAsKey('11',lsObj);                
                }
            }
            map<string,map<string,list<string>>> mapOfFildWithStateAsKey = new map<string,map<string,list<string>>>();
            for(string strKey : mapOfKeyWithStates.keySet()){
                map<string,list<string>> mapOfKeyAsState = new map<string,list<string>>();
                for(string strState : mapOfKeyWithStates.get(strKey)){
                    list<string> lstOfSs;
                    if(mapOfKeyAsState.containsKey(strState))
                    	lstOfSs = mapOfKeyAsState.get(strState);    
                    else
                        lstOfSs = new list<string>(); 
                    lstOfSs.add(strState);
                    mapOfKeyAsState.put(strState,lstOfSs);
                }
                mapOfFildWithStateAsKey.put(strKey,mapOfKeyAsState);
            }
            for(Operational_State__c lsObj : lstOfStatesRecords){                
                for(string strKey : mapOfKeyWithStates.KeySet()){
                    if(!isUpdate){
                        if((lsObj.ADR_Beyond_Overlapping_States__c && mapOfFildWithStateAsKey.get('1') != null && mapOfFildWithStateAsKey.get('1').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('1').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.ADR_Operational_State__c && mapOfFildWithStateAsKey.get('2') != null && mapOfFildWithStateAsKey.get('2').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('2').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.ADR_Selling_to_ClearOne__c && mapOfFildWithStateAsKey.get('3') != null && mapOfFildWithStateAsKey.get('3').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('3').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.ADR_Sell_to_GRT__c && mapOfFildWithStateAsKey.get('4') != null && mapOfFildWithStateAsKey.get('4').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('4').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.ADR_Sell_to_Signature__c && mapOfFildWithStateAsKey.get('5') != null && mapOfFildWithStateAsKey.get('5').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('5').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.Beyond_Operational_State__c && mapOfFildWithStateAsKey.get('6') != null && mapOfFildWithStateAsKey.get('6').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('6').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.Discounted_and_Free_Legal__c && mapOfFildWithStateAsKey.get('7') != null && mapOfFildWithStateAsKey.get('7').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('7').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.Full_BLP_States__c && mapOfFildWithStateAsKey.get('8') != null && mapOfFildWithStateAsKey.get('8').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('8').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.Limited_BLP_States__c && mapOfFildWithStateAsKey.get('9') != null && mapOfFildWithStateAsKey.get('9').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('9').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.CFT__c && mapOfFildWithStateAsKey.get('10') != null && mapOfFildWithStateAsKey.get('10').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('10').get(lsObj.State__c).Size() > 0) ||
                           (lsObj.ClearOne_GCS__c && mapOfFildWithStateAsKey.get('11') != null && mapOfFildWithStateAsKey.get('11').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('11').get(lsObj.State__c).Size() > 0)
                          ){
                        	lsObj.addError('Duplicate State');    
                        }                         	
                    }else{
                        if((lsObj.ADR_Beyond_Overlapping_States__c && mapOfFildWithStateAsKey.get('1') != null && mapOfFildWithStateAsKey.get('1').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('1').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.ADR_Operational_State__c && mapOfFildWithStateAsKey.get('2') != null && mapOfFildWithStateAsKey.get('2').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('2').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.ADR_Selling_to_ClearOne__c && mapOfFildWithStateAsKey.get('3') != null && mapOfFildWithStateAsKey.get('3').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('3').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.ADR_Sell_to_GRT__c && mapOfFildWithStateAsKey.get('4') != null && mapOfFildWithStateAsKey.get('4').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('4').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.ADR_Sell_to_Signature__c && mapOfFildWithStateAsKey.get('5') != null && mapOfFildWithStateAsKey.get('5').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('5').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.Beyond_Operational_State__c && mapOfFildWithStateAsKey.get('6') != null && mapOfFildWithStateAsKey.get('6').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('6').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.Discounted_and_Free_Legal__c && mapOfFildWithStateAsKey.get('7') != null && mapOfFildWithStateAsKey.get('7').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('7').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.Full_BLP_States__c && mapOfFildWithStateAsKey.get('8') != null && mapOfFildWithStateAsKey.get('8').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('8').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.Limited_BLP_States__c && mapOfFildWithStateAsKey.get('9') != null && mapOfFildWithStateAsKey.get('9').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('9').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.CFT__c && mapOfFildWithStateAsKey.get('10') != null && mapOfFildWithStateAsKey.get('10').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('10').get(lsObj.State__c).Size() > 1) ||
                           (lsObj.ClearOne_GCS__c && mapOfFildWithStateAsKey.get('11') != null && mapOfFildWithStateAsKey.get('11').get(lsObj.State__c) != null && mapOfFildWithStateAsKey.get('11').get(lsObj.State__c).Size() > 1)
                          ){
                        	lsObj.addError('Duplicate State');    
                        }
                    }    
                } 
            }
        }    
    }
    public static void updateStateCodes(list<Operational_State__c> lstOfStatesRecords,map<Id,Operational_State__c> mapOfOldStateRecs,boolean isDelete){
        list<Operational_State__c> lstOfRecords = new list<Operational_State__c>();
        if(!isDelete){
            boolean isUpdate = false;
            if(mapOfOldStateRecs != null && !mapOfOldStateRecs.isEmpty()){
                isUpdate = true;    
            }             
            for(Operational_State__c lsObj : lstOfStatesRecords){
                if((!isUpdate && lsObj.State__c != null) || 
                (isUpdate && mapOfOldStateRecs != null && (
                    (lsObj.State__c != mapOfOldStateRecs.get(lsObj.Id).State__c && lsObj.State__c != null) || 
                    lsObj.ADR_Beyond_Overlapping_States__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Beyond_Overlapping_States__c ||
                    lsObj.ADR_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Operational_State__c ||
                    lsObj.ADR_Selling_to_ClearOne__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Selling_to_ClearOne__c || 
                    lsObj.ADR_Sell_to_GRT__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_GRT__c ||
                    lsObj.ADR_Sell_to_Signature__c != mapOfOldStateRecs.get(lsObj.Id).ADR_Sell_to_Signature__c ||
                    lsObj.Beyond_Operational_State__c != mapOfOldStateRecs.get(lsObj.Id).Beyond_Operational_State__c || 
                    lsObj.Discounted_and_Free_Legal__c != mapOfOldStateRecs.get(lsObj.Id).Discounted_and_Free_Legal__c ||
                    lsObj.Full_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Full_BLP_States__c ||
                    lsObj.Limited_BLP_States__c != mapOfOldStateRecs.get(lsObj.Id).Limited_BLP_States__c||
                    lsObj.CFT__c != mapOfOldStateRecs.get(lsObj.Id).CFT__c ||
                    lsObj.ClearOne_GCS__c != mapOfOldStateRecs.get(lsObj.Id).ClearOne_GCS__c
                ))){
                    lstOfRecords.add(lsObj);
                }            
            }
        }
        if(!lstOfRecords.isEmpty() || isDelete){
            set<string> setOfStateCodes = new set<string>();
            set<string> setOf1 = new set<string>();set<string> setOf2 = new set<string>();set<string> setOf3 = new set<string>();
            set<string> setOf4 = new set<string>();set<string> setOf5 = new set<string>();set<string> setOf6 = new set<string>();
            set<string> setOf7 = new set<string>();set<string> setOf8 = new set<string>();set<string> setOf9 = new set<string>();
            set<string> setOf10 = new set<string>();set<string> setOf11 = new set<string>();
            for(Operational_State__c lsObj : [SELECT Id,State__c,ADR_Beyond_Overlapping_States__c,
                                           ADR_Operational_State__c,ADR_Selling_to_ClearOne__c,ADR_Sell_to_GRT__c,
                                           ADR_Sell_to_Signature__c,Beyond_Operational_State__c,Discounted_and_Free_Legal__c,
                                           Full_BLP_States__c,Limited_BLP_States__c,CFT__c,ClearOne_GCS__c
                                           FROM Operational_State__c WHERE State__c != null LIMIT 500000]){
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
                if(lsObj.CFT__c){
                	setOf10.add(lsObj.State__c);    
                }
                if(lsObj.ClearOne_GCS__c){
                	setOf11.add(lsObj.State__c);    
                }                               
                                               
            }
            if(!setOfStateCodes.isEmpty()){                
                Operational_States__c stateCodes = Operational_States__c.getOrgDefaults();
                stateCodes.ADR_Beyond_Overlapping_States__c = prepareStates(setOf1);
                stateCodes.ADR_Operational_States__c = prepareStates(setOf2);
                stateCodes.ADR_Selling_to_ClearOne_States__c = prepareStates(setOf3);
                stateCodes.ADR_Sell_to_GRT_States__c = prepareStates(setOf4);
                stateCodes.ADR_Sell_to_Signature_States__c = prepareStates(setOf5);
                stateCodes.Beyond_Operational_States__c = prepareStates(setOf6);
                stateCodes.Discounted_and_Free_Legal_States__c = prepareStates(setOf7);
                stateCodes.Full_BLP_States__c = prepareStates(setOf8);
                stateCodes.Limited_BLP_States__c = prepareStates(setOf9);
                stateCodes.CFT__c = prepareStates(setOf10);
                stateCodes.ClearOne_GCS__c = prepareStates(setOf11);
                upsert stateCodes;				
            }
        }       			
    }
    
    public static void prepareStateAsKey(string strKey,Operational_State__c lsObj){
        list<string> lstOfStrs;
        if(mapOfKeyWithStates.ContainsKey(strKey))
            lstOfStrs = mapOfKeyWithStates.get(strKey);    
        else
            lstOfStrs = new list<string>();
        lstOfStrs.add(lsObj.State__c);
        mapOfKeyWithStates.put(strKey,lstOfStrs);
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