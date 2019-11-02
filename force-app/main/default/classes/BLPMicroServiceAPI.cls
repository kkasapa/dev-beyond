/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API class for BLP MicroService
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2019-10-27
* @modified       2019-10-27
*       <Resly Added filter in addDocument and addClientCreditor
* @Layer          REST API 
* @To Execute from DEV Console
*     string strPgmId = 'a0L22000000Vkb1';
*     BLPMicroServiceAPI.addClientAPI(strPgmId);
*	  BLPMicroServiceAPI.addClientCreditorAPI(strPgmId);
*	  BLPMicroServiceAPI.addDocument(strPgmId);	
*       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*   
*/
public class BLPMicroServiceAPI {
    
    public static void addClientAPI(string strPgmId){
        nu_dse__Program__c pgmObj = [SELECT Id,Name,BLP_Client_Id__c,nu_dse__Account__c,BLP_Member_Type__c FROM nu_dse__Program__c WHERE Id =:strPgmId];
        BLPMicroService__c apiObj = getAPICreds();
            
        string strEndpointURL 	= apiObj.End_Point_URL__c;
        string strAddClient 	= apiObj.Add_Client_URL__c;
        string strFullEPforAddClient = strEndpointURL+strAddClient;
        string strBody = getAddClientRequest(pgmObj);

		Http http = new Http();        
        HttpRequest request = prepareHttpCallOut(strFullEPforAddClient,strBody,'POST');
        HttpResponse response = http.send(request);
        
        system.debug('EndpointURL==>'+strFullEPforAddClient);
        system.debug('STATUS==>'+response.getStatus()+'\n STATUS CODE==>'+response.getStatusCode()+'\n BODY==>'+response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            pgmObj.BLP_Client_Id__c = (String)results.get('clientid');
            pgmObj.BLP_Client_Last_Updated__c = System.now();
        }        
    }
    
    public static void addClientCreditorAPI(string strPgmId){        
        nu_dse__Program__c pgmObj = [SELECT Id,Name,BLP_Client_Id__c FROM nu_dse__Program__c WHERE Id =:strPgmId];
    	BLPMicroService__c apiObj = getAPICreds();    
        string strEndpointURL 	= apiObj.End_Point_URL__c;
        string strAddClient 	= apiObj.Add_Client_URL__c;
        string strClientId 		= pgmObj.BLP_Client_Id__c;
        string AddClientCreditor = strEndpointURL+strAddClient+'/'+strClientId+'/creditor';
        string strBody = getAddClientCreditorRequest(pgmObj.Id);
        
        Http http = new Http();        
        HttpRequest request = prepareHttpCallOut(AddClientCreditor,strBody,'POST');
        HttpResponse response = http.send(request);
        
        system.debug('EndpointURL==>'+AddClientCreditor+'\n STATUS==>'+response.getStatus()+'\n STATUS CODE==>'+response.getStatusCode()+'\n BODY==>'+response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }       
    }
    
    public static void addDocument(string strPgmId){ 
        nu_dse__Program__c pgmObj = [SELECT Id,Name,BLP_Client_Id__c FROM nu_dse__Program__c WHERE Id =:strPgmId];
        BLPMicroService__c apiObj = getAPICreds();    
        string strEndpointURL 	= apiObj.End_Point_URL__c;
        string strAddClient 	= apiObj.Add_Client_URL__c;
        string strClientId 		= pgmObj.BLP_Client_Id__c;
        string AddDocument = strEndpointURL+strAddClient+'/'+strClientId+'/document';        
        string strBody = getAddDocumentRequest(pgmObj.Id);
        
        Http http = new Http();        
        HttpRequest request = prepareHttpCallOut(AddDocument,strBody,'POST');
        HttpResponse response = http.send(request);
        
        system.debug('EndpointURL==>'+AddDocument+'\n STATUS==>'+response.getStatus()+'\n STATUS CODE==>'+response.getStatusCode()+'\n BODY==>'+response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }       
        
    }
    
    public static HttpRequest prepareHttpCallOut(string strURL, string strBody, string strMethod){
    	BLPMicroService__c apiObj = getAPICreds();
        string strFullEpURL = strURL;
        string strusername = apiObj.UserName__c;
        string strpassword = apiObj.Password__c;        
        string unamepwd = strusername+':'+strpassword;
        Blob beforeblob = Blob.valueOf(unamepwd);
        string authentication = EncodingUtil.base64Encode(beforeblob);
        
        HttpRequest request = new HttpRequest();        
            request.setEndpoint(strURL);
            request.setMethod(strMethod);
            request.setHeader('Authorization', 'Basic '+authentication);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(strBody);        
        return request;
    }
    
    public static map<string,list<nu_dse__Field_mapping__c>> getFieldMapping(string strDataMapping){
    	map<string,list<nu_dse__Field_mapping__c>> mapOfObjWithFilds = new map<string,list<nu_dse__Field_mapping__c>>(); 
        for(nu_dse__Field_mapping__c fldObj : [SELECT Id, nu_dse__Target_Field__c,nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c, nu_dse__Source_Field__c FROM nu_dse__Field_mapping__c WHERE nu_dse__Data_Mapping__r.Name =:strDataMapping and nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c != null]){
        	list<nu_dse__Field_mapping__c> lstOfFlds;
            if(mapOfObjWithFilds.containsKey(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c))
                lstOfFlds =  mapOfObjWithFilds.get(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c); 
            else
                lstOfFlds = new list<nu_dse__Field_mapping__c>(); 
            lstOfFlds.add(fldObj);
            mapOfObjWithFilds.put(fldObj.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c,lstOfFlds);    
        }
        return mapOfObjWithFilds;
    }
    
    public static string getAddDocumentRequest(string strPgmId){
        map<string,list<nu_dse__Field_mapping__c>> mapOfObjWithFilds = getFieldMapping('BLPAddDocument');
        list<nu_dse__Field_mapping__c> lstOfTLFlds = mapOfObjWithFilds.get('Attachment');
        string strattQry = 'SELECT ';
        for(nu_dse__Field_mapping__c strFldName : lstOfTLFlds){
            strattQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strattQry = strattQry.substring(0,strattQry.length() - 1);
        strattQry += ' FROM Attachment WHERE ParentId =:strPgmId and Name like Name like \'AUTHORIZATION-ONLINE-BLP%\'';
        
        list<sObject> lstOftls = database.query(strattQry);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('docs');
            gen.writeStartArray();
            for(sObject sObj : lstOftls){
                gen.writeStartObject();
                for(nu_dse__Field_mapping__c fldObj : lstOfTLFlds){  
                    if(fldObj.nu_dse__Target_Field__c == 'doc_content' && sObj.get(fldObj.nu_dse__Source_Field__c) != null){
                        gen.writeStringField(fldObj.nu_dse__Target_Field__c, EncodingUtil.Base64Encode((blob)sObj.get(fldObj.nu_dse__Source_Field__c))); 
                    }else{
                        gen.writeStringField(fldObj.nu_dse__Target_Field__c, (sObj.get(fldObj.nu_dse__Source_Field__c) != null ? string.valueOf(sObj.get(fldObj.nu_dse__Source_Field__c)) : ''));                
                    }                    
                }
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        String strResponse = gen.getAsString();  
        System.debug('***Request Body**'+strResponse.replaceAll('\n', ''));
        return strResponse;    
    }
    
    public static string getAddClientCreditorRequest(string strPgmId){
        map<string,list<nu_dse__Field_mapping__c>> mapOfObjWithFilds = getFieldMapping('BLPAddClientCreditor');
        list<nu_dse__Field_mapping__c> lstOfTLFlds = mapOfObjWithFilds.get('nu_dse__TradeLine__c');
        string strTLQry = 'SELECT ';
        for(nu_dse__Field_mapping__c strFldName : lstOfTLFlds){
            strTLQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strTLQry = strTLQry.substring(0,strTLQry.length() - 1);
        strTLQry += ' FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =:strPgmId and nu_dse__Include_In_The_Program__c = true';
        
        list<sObject> lstOftls = database.query(strTLQry);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(sObject sObj : lstOftls){
            gen.writeStartObject();
            for(nu_dse__Field_mapping__c fldObj : lstOfTLFlds){                            
                gen.writeStringField(fldObj.nu_dse__Target_Field__c, (sObj.get(fldObj.nu_dse__Source_Field__c) != null ? string.valueOf(sObj.get(fldObj.nu_dse__Source_Field__c)) : ''));    
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        String strResponse = gen.getAsString();  
        System.debug('***Request Body**'+strResponse.replaceAll('\n', ''));
        return strResponse;    
    }
    public static string getAddClientRequest(nu_dse__Program__c pgmObj){ 
        string actId = pgmObj.nu_dse__Account__c;
        map<string,list<nu_dse__Field_mapping__c>> mapOfObjWithFilds = getFieldMapping('BLPAddClient');
        list<nu_dse__Field_mapping__c> lstOfActFlds = mapOfObjWithFilds.get('Account');
        string strActQry = 'SELECT ';
        for(nu_dse__Field_mapping__c strFldName : lstOfActFlds){
            strActQry += strFldName.nu_dse__Source_Field__c+',';    
        }
        strActQry = strActQry.substring(0,strActQry.length() - 1);
        strActQry += ' FROM Account WHERE Id =:actId';
        
        Account actObj = (Account)database.query(strActQry);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('clientid', pgmObj.Name.split('-')[1]); 
        gen.writeStringField('blp_client_type', pgmObj.BLP_Member_Type__c); 
        for(nu_dse__Field_mapping__c fldObj : lstOfActFlds){
            if(fldObj.nu_dse__Target_Field__c == 'birthdate' && actObj.PersonBirthdate != null){
                gen.writeStringField('birthdate', actObj.PersonBirthdate.format());    
            }else if(fldObj.nu_dse__Target_Field__c == 'phone' && actObj.PersonHomePhone != null){
                gen.writeStringField('phone', actObj.PersonHomePhone);
                gen.writeStringField('phone_type', 'H');    
            }else if(fldObj.nu_dse__Target_Field__c == 'phone2' && actObj.PersonMobilePhone != null){
                gen.writeStringField('phone2', actObj.PersonMobilePhone);
                gen.writeStringField('phone2_type', 'C');    
            }else if(fldObj.nu_dse__Target_Field__c == 'phone3' && actObj.PersonOtherPhone != null){
                gen.writeStringField('phone3', actObj.PersonOtherPhone);
                gen.writeStringField('phone3_type', 'O');    
            }else if(fldObj.nu_dse__Target_Field__c == 'birthdate2' && actObj.nu_dse__Co_Date_of_Birth__c != null){
                gen.writeStringField('birthdate', actObj.nu_dse__Co_Date_of_Birth__c.format());    
            }else{
                gen.writeStringField(fldObj.nu_dse__Target_Field__c, (actObj.get(fldObj.nu_dse__Source_Field__c) != null ? string.valueOf(actObj.get(fldObj.nu_dse__Source_Field__c)) : ''));        
            }                
        }
            
        	/*
            gen.writeStringField('phone4', ''); 
            gen.writeStringField('phone4_type', 'W');
            gen.writeStringField('mothers_maiden_name2', '');
            gen.writeStringField('mothers_maiden_name', ''); 
        
            gen.writeStringField('employer', ''); 
            gen.writeStringField('employer2', ''); 
            gen.writeStringField('source_crm_status', '');
            gen.writeStringField('source_crm_insert_dt', ''); 
            gen.writeStringField('source_crm_program_name', ''); 
            gen.writeStringField('address2', ''); 
            gen.writeStringField('address2_co', ''); 
            */
        gen.writeEndObject();
        String strResponse = gen.getAsString();        
        //System.debug('***Request Body**'+strResponse.replaceAll('\n', ''));
        System.debug('***Request Body**'+strResponse);
        return strResponse;    
    }
    
    public static BLPMicroService__c getAPICreds(){
    	BLPMicroService__c apiObj = BLPMicroService__c.getValues('BLPMicroServiceAPI'); 
        return apiObj;
    }
}