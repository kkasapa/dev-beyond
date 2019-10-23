/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API class for Credit Core
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2019-10-27
* @modified       2019-10-27
* @Layer          REST API 
* 
*       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class CreditCoreRestAPI {
    public static void addClientAPI(string strPgmId){
        strPgmId = 'a0L22000000Vkb1EAC';
    	string strEndpointURL = system.label.BeyondEndpointURL;
        string strFullEPforAddClient = strEndpointURL+'/beyond/rest/client';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(strFullEPforAddClient);
        request.setMethod('POST');
        
        string strusername = 'bfinance';
        string strpassword = 'Bf^%$$**(';
        
        string unamepwd = strusername+':'+strpassword;
        Blob beforeblob = Blob.valueOf(unamepwd);
   		string authentication = EncodingUtil.base64Encode(beforeblob);
        
        request.setHeader('Authorization', 'Basic '+authentication);
        request.setHeader('Content-Type', 'application/json');
        string strBody = getAddClientRequest(strPgmId);
        request.setBody(strBody);
        HttpResponse response = http.send(request);
        
        system.debug('EndpointURL==>'+strEndpointURL+'\n Authorization==>'+authentication);
        system.debug('STATUS==>'+response.getStatus()+'\n STATUS CODE==>'+response.getStatusCode()+'\n BODY==>'+response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }        
    }
    
    public static string getAddClientRequest(string strPgmId){
        
        nu_dse__Program__c pgmObj = [SELECT Id,nu_dse__Account__c FROM nu_dse__Program__c WHERE Id =:strPgmId];
        Account actObj = [SELECT Id,FirstName,LastName,PersonEmail,PersonBirthdate,PersonMailingStreet,PersonMailingCity,
                          PersonMailingState,PersonMailingPostalCode,nu_dse__SSN__c,PersonHomePhone,PersonMobilePhone,PersonOtherPhone,
                          nu_dse__Co_First_Name__c,nu_dse__Co_Last_Name__c,nu_dse__CO_Email_Address__c,nu_dse__Co_Date_of_Birth__c,
                          nu_dse__Co_Address_Line__c,nu_dse__Co_City__c,nu_dse__Co_State__c,nu_dse__Co_Postal_Code__c,nu_dse__Co_SSN__c
                          FROM Account WHERE Id =:pgmObj.nu_dse__Account__c];
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        	gen.writeStringField('firstname', actObj.FirstName); 
        	gen.writeStringField('lastname', actObj.FirstName); 
        	gen.writeStringField('email', actObj.PersonEmail); 
        	if(actObj.PersonBirthdate != null)
        		gen.writeStringField('birthdate', actObj.PersonBirthdate.format());
        	gen.writeStringField('mothers_maiden_name', ''); 
        	gen.writeStringField('address', actObj.PersonMailingStreet); 
        	gen.writeStringField('city', actObj.PersonMailingCity); 
        	gen.writeStringField('state', actObj.PersonMailingState);
        	gen.writeStringField('postal', actObj.PersonMailingPostalCode); 
        	gen.writeStringField('sid', actObj.nu_dse__SSN__c); 
        	gen.writeStringField('employer', ''); 
        	if(actObj.PersonHomePhone != null){
            	gen.writeStringField('phone', actObj.PersonHomePhone);
        		gen.writeStringField('phone_type', 'H');
        	}
        	if(actObj.PersonMobilePhone != null){
            	gen.writeStringField('phone2', actObj.PersonMobilePhone);
        		gen.writeStringField('phone2_type', 'C');
        	}
        	if(actObj.PersonOtherPhone != null){
            	gen.writeStringField('phone3', actObj.PersonOtherPhone);
        		gen.writeStringField('phone3_type', '');
        	}
        	gen.writeStringField('phone4', ''); 
        	gen.writeStringField('phone4_type', 'W'); 
        	
        	gen.writeStringField('firstname2', returnValue(actObj.nu_dse__Co_First_Name__c));
        	gen.writeStringField('lastname2', returnValue(actObj.nu_dse__Co_Last_Name__c)); 
        	gen.writeStringField('email2', returnValue(actObj.nu_dse__CO_Email_Address__c)); 
        	if(actObj.nu_dse__Co_Date_of_Birth__c != null)
        		gen.writeStringField('birthdate2', actObj.nu_dse__Co_Date_of_Birth__c.format()); 
        	gen.writeStringField('mothers_maiden_name2', '');
        	gen.writeStringField('address_co', returnValue(actObj.nu_dse__Co_Address_Line__c)); 
        	gen.writeStringField('city_co', returnValue(actObj.nu_dse__Co_City__c)); 
        	gen.writeStringField('state_co', returnValue(actObj.nu_dse__Co_State__c)); 
        	gen.writeStringField('postal_co', returnValue(actObj.nu_dse__Co_Postal_Code__c));
        	gen.writeStringField('sid2', returnValue(actObj.nu_dse__Co_SSN__c)); 
			
        	gen.writeStringField('employer2', ''); 
        	gen.writeStringField('clientid', ''); 
        	gen.writeStringField('source_crm_status', '');
        	gen.writeStringField('source_crm_insert_dt', ''); 
        	gen.writeStringField('source_crm_program_name', ''); 
        	gen.writeStringField('cftpay_account_id', ''); 
        	gen.writeStringField('blp_client_type', '');
        	gen.writeStringField('address2', ''); 
        	gen.writeStringField('address2_co', ''); 
        gen.writeEndObject();
        String strResponse = gen.getAsString();        
        System.debug('***Request Body**'+strResponse.replaceAll('\n', ''));
    	return strResponse;    
    }
    
    public static string returnValue(string strValue){
        return (strValue != null ? strValue : '');
    }
}