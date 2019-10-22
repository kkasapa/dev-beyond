/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API class for Credit Core
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2019-10-16
* @modified       2019-10-16
* @Layer          REST API 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/creditCore/*')
global with sharing class CreditCoreRestResource {
	@HttpGet
    global static string getDetails() {
        RestRequest req = RestContext.request;
        string strPgmId = 'a0L22000000Vkb1';
        map<string,list<nu_dse__Field_mapping__c>> mapOfObjWithFilds = new map<string,list<nu_dse__Field_mapping__c>>();
        
        for(nu_dse__Field_mapping__c fldObj : [SELECT Id, nu_dse__Target_Field__c,nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c, nu_dse__Source_Field__c FROM nu_dse__Field_mapping__c WHERE nu_dse__Data_Mapping__r.Name = 'CreditCore' and nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c != null]){
        	list<nu_dse__Field_mapping__c> lstOfFlds;
            if(mapOfObjWithFilds.containsKey(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c))
            	lstOfFlds =  mapOfObjWithFilds.get(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c); 
            else
            	lstOfFlds = new list<nu_dse__Field_mapping__c>(); 
            lstOfFlds.add(fldObj);
            mapOfObjWithFilds.put(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c,lstOfFlds);
        }
        
        list<nu_dse__Field_mapping__c> lstOfPgmFlds = mapOfObjWithFilds.get('nu_dse__Program__c');
        list<nu_dse__Field_mapping__c> lstOfActFlds = mapOfObjWithFilds.get('Account');
        list<nu_dse__Field_mapping__c> lstOfTLFlds  = mapOfObjWithFilds.get('nu_dse__TradeLine__c');
        string strPreQry = 'SELECT ';
        string strActQry = 'SELECT ';
        string strTLQry  = 'SELECT ';
        
        for(nu_dse__Field_mapping__c strFldName : lstOfPgmFlds){
        	strPreQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strPreQry = strPreQry.substring(0,strPreQry.length() - 1);
        strPreQry += ' FROM nu_dse__Program__c WHERE Id =:strPgmId';        
        sObject pgmObj = database.query(strPreQry);
        
        string strActId = string.valueOf(pgmObj.get('nu_dse__Account__c'));
        for(nu_dse__Field_mapping__c strFldName : lstOfActFlds){
        	strActQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strActQry = strActQry.substring(0,strActQry.length() - 1);
        strActQry += ' FROM Account WHERE Id =:strActId';
        sObject actObj = database.query(strActQry);
        
        for(nu_dse__Field_mapping__c strFldName : lstOfTLFlds){
        	strTLQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strTLQry = strTLQry.substring(0,strTLQry.length() - 1);
        strTLQry += ' FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:strPgmId';
        list<sObject> lstOftls = database.query(strTLQry);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        	gen.writeFieldName('ProgramInfo');
                gen.writeStartObject();
                for(nu_dse__Field_mapping__c fldObj : lstOfPgmFlds){
                    gen.writeStringField(fldObj.nu_dse__Target_Field__c, string.valueOf(pgmObj.get(fldObj.nu_dse__Source_Field__c)));    
                }
                gen.writeEndObject();
        	gen.writeFieldName('AccountInfo');
                gen.writeStartObject();
                for(nu_dse__Field_mapping__c fldObj : lstOfActFlds){
                    gen.writeStringField(fldObj.nu_dse__Target_Field__c, string.valueOf(actObj.get(fldObj.nu_dse__Source_Field__c)));    
                }
                gen.writeEndObject();
        	gen.writeFieldName('TradeLines');
        		gen.writeStartArray();
                    for(sObject sObj : lstOftls){
                        gen.writeStartObject();
                        for(nu_dse__Field_mapping__c fldObj : lstOfTLFlds){                            
                            gen.writeStringField(fldObj.nu_dse__Target_Field__c, (sObj.get(fldObj.nu_dse__Source_Field__c) != null ? string.valueOf(sObj.get(fldObj.nu_dse__Source_Field__c)) : ''));    
                        }
                        gen.writeEndObject();
                    }
        		gen.writeEndArray();
        gen.writeEndObject();
        // Get the JSON string.
        String strResponse = gen.getAsString();        
        System.debug('***strResponse**'+strResponse);
        return strResponse;    
    }
    
    /*
        {
            "ProgramInfo": {
                "Id": "Id",
                "Name": "Name"
            },
            "AccountInfo": {
                "Id": "Id",
                "Name": "Name"
            },
            "TradeLines": [{
                    "Id": "Id",
                    "Name": "Name"
                },
                {
                    "Id": "Id",
                    "Name": "Name"
                }
            ]
    	}	
	*/
}