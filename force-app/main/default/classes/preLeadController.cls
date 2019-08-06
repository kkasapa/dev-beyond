public class preLeadController {

    public String errorMessage { get; set; }
    public PreLead preLeadWrapper { get; set; }
    Public String mailerId { get; set; }
    public Integer Status { get; set; }
    public String Tester { get; set; }
    
    public BooLean genLead { get; set; }
    public String epoint; 
    String username; 
    String password;
    String pString = '';
    Blob headerValue;
    String authorizationHeader = '';    
    
    public preLeadController() {
    
        preLeadWrapper = new PreLead();
        
         PreLeadSettigs__c preLeadSettings = PreLeadSettigs__c.getInstance();
         system.debug('preLeadSettings-->'+preLeadSettings);
         
         epoint = preLeadSettings.EndPointURL__c != null ? preLeadSettings.EndPointURL__c : '';
         username = preLeadSettings.UserName__c != null ? preLeadSettings.UserName__c : '';
         password = preLeadSettings.Password__c != null ? preLeadSettings.Password__c : '';
         
         if(String.isNotBlank(username) && String.isNotBlank(password)) {
         
             headerValue = Blob.valueOf(username + ':' + password);
             authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
         }
    }
   
    public void callout() {
        
        if(String.isNotBlank(authorizationHeader) && String.isNotBlank(epoint)) {
            
            String responseBody; 
            
            preLeadWrapper = new PreLead();
            errorMessage = null;
            status = null;
            Tester = null;
            
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setClientCertificateName('beyondfinance');
            req.setHeader('Authorization',authorizationHeader);
            req.setHeader('Access-Control-Allow-Origin', '*');
            pString = '?$filter='+ EncodingUtil.urlEncode('MailerId eq \'' + mailerId + '\'', 'UTF-8');
            req.setEndpoint(epoint+pString);
            req.setMethod('GET');
            Http http = new Http();
            System.debug('*** req ' +req);
            System.debug(epoint+pString);
            
            try {
            
                HTTPResponse res = http.send(req);
                if (res != null && res.getBody() != null) {
                    responseBody = res.getBody();
                }
                System.debug('*** res ' + res);
                status  = res.getStatusCode();
                
                if(String.valueOf(status).startsWith('2') == False) {
                    
                    if (String.isNotBlank(responseBody)) {
                        PostCallError postcallErr = (PostCallError)JSON.deserialize(responseBody, PostCallError.class);
                    
                        system.debug('postcallErr-->'+postcallErr);
                    
                        if (postcallErr != null && postcallErr.error != null && postcallErr.error.innerError != null
                                && postcallErr.error.innerError.message != null) {
                        
                            errorMessage = String.valueOf(postcallErr.error.innerError.message).deleteWhitespace();
                        }
                    } else {
                        errorMessage = 'Bad Request : ' + res.getStatusCode();
                    }
                    system.debug('errorMessage-->'+errorMessage);
                    return;
                }
                
                List<PreLeadDeserilalize> deserializedPreLeads = new List<PreLeadDeserilalize>();
                
                if (String.isNotBlank(responseBody)) {
                    
                    JSONParser parser = JSON.createParser(responseBody);
                    
                    while(parser.nextToken() !=null) {
                
                        if ((parser.getCurrentToken() == JSONToken.START_ARRAY)){
                            
                            deserializedPreLeads = (List<PreLeadDeserilalize>) parser.readValueAs(List<PreLeadDeserilalize>.class) ;
                        } 
                    }
                } 

                if (deserializedPreLeads.isEmpty() == False) {
                    
                    PreLeadDeserilalize deserializedPreLead = deserializedPreLeads[0];
    
                    preLeadWrapper.Id = deserializedPreLead.Id;
                    preLeadWrapper.MailerId = deserializedPreLead.MailerId;        
                    preLeadWrapper.FirstName = deserializedPreLead.FirstName;            
                    preLeadWrapper.MiddleName = deserializedPreLead.MiddleName;            
                    preLeadWrapper.LastName = deserializedPreLead.LastName;            
                    preLeadWrapper.Address1 = deserializedPreLead.Address1;            
                    preLeadWrapper.Address2 = deserializedPreLead.Address2;           
                    preLeadWrapper.City = deserializedPreLead.City;            
                    preLeadWrapper.State = deserializedPreLead.State;            
                    preLeadWrapper.Zip = deserializedPreLead.Zip;           
                    preLeadWrapper.MailDate = Date.valueOf(deserializedPreLead.MailDate);            
                    preLeadWrapper.ExpirationDate = Date.valueOf(deserializedPreLead.ExpirationDate);           
                    preLeadWrapper.InsertDate = Date.valueOf(deserializedPreLead.InsertDate);            
                    preLeadWrapper.EmailAddress = deserializedPreLead.EmailAddress;            
                    preLeadWrapper.PhoneNumber = deserializedPreLead.PhoneNumber;            
                    preLeadWrapper.UnsecuredDebtAmount = deserializedPreLead.UnsecuredDebtAmount;                     
                    preLeadWrapper.BestTimeToCall = deserializedPreLead.BestTimeToCall;            
                    preLeadWrapper.HasIncomeSource = deserializedPreLead.HasIncomeSource;            
                    preLeadWrapper.PardotId = deserializedPreLead.PardotId;            
                    preLeadWrapper.StateQualification = deserializedPreLead.StateQualification;            
                    preLeadWrapper.DebtAmountQualification = deserializedPreLead.DebtAmountQualification;
                    preLeadWrapper.MetaData = deserializedPreLead.MetaData;            
                }
            } catch (System.CalloutException e){
                 System.debug('ERROR:' + e);
            }  
            system.debug('preLeadWrapper-->'+preLeadWrapper); 
        } else {
            errorMessage = 'Username or Password or Endpoint is not exist';
        }
    }
    
    public void postBack() {
        
        if(String.isBlank(authorizationHeader) == FALSE && String.isBlank(epoint) == FALSE) {
        
            if (preLeadWrapper != null && preLeadWrapper.Id != null) {
            
                Tester = null;
                errorMessage = null;
                status = null;
                
                HttpRequest req = new HttpRequest();
                pString = '('+preLeadWrapper.Id+')';
                req.setEndpoint(epoint+pString);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization',authorizationHeader);
                req.setHeader('Access-Control-Allow-Origin', '*');
                Http http = new Http();
                
                JSONGenerator pre = JSON.createGenerator(true);
                pre.writeStartObject();
        
                pre.writeFieldName('Id');
                if (preLeadWrapper.Id!=null) {
                    pre.writeNumber(preLeadWrapper.Id);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('MailerId');
                if(mailerId  != null) {
                    pre.writeString(mailerId);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('MailDate');
                if(preLeadWrapper.MailDate!=null) {
                    pre.writeDate(Date.valueOf(preLeadWrapper.MailDate));
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('ExpirationDate');
                if(preLeadWrapper.ExpirationDate!=null) {
                    pre.writeDate(Date.valueOf(preLeadWrapper.ExpirationDate));
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('InsertDate');
                if(preLeadWrapper.InsertDate!=null) {
                    pre.writeDate(Date.valueOf(preLeadWrapper.InsertDate));
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('FirstName');
                if(preLeadWrapper.FirstName!=null) {
                    pre.writeString(preLeadWrapper.FirstName);
                } else { 
                    pre.writeNull();
                }
                    
                pre.writeFieldName('MiddleName');
                if(preLeadWrapper.MiddleName!=null) {
                    pre.writeString(preLeadWrapper.MiddleName);
                } else { 
                    pre.writeNull();
                }
                    
                pre.writeFieldName('LastName');
                if(preLeadWrapper.LastName!=null) {
                    pre.writeString(preLeadWrapper.LastName);
                } else { 
                    pre.writeNull();
                }
                    
                pre.writeFieldName('Address1');
                if(preLeadWrapper.Address1!=null) {
                    pre.writeString(preLeadWrapper.Address1);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('Address2');
                if(preLeadWrapper.Address2!=null) {
                    pre.writeString(preLeadWrapper.Address2);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('City');
                if(preLeadWrapper.City!=null) {
                    pre.writeString(preLeadWrapper.City);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('State');
                if(preLeadWrapper.State!=null) {
                    pre.writeString(preLeadWrapper.State);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('Zip');
                if(preLeadWrapper.Zip!=null) {
                    pre.writeString(preLeadWrapper.Zip);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('EmailAddress');
                if(preLeadWrapper.EmailAddress!=null) {
                    pre.writeString(preLeadWrapper.EmailAddress);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('PhoneNumber');
                if(preLeadWrapper.PhoneNumber!=null) {
                    pre.writeString(preLeadWrapper.PhoneNumber);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('UnsecuredDebtAmount');
                if(preLeadWrapper.UnsecuredDebtAmount!=null) {
                    pre.writeNumber(preLeadWrapper.UnsecuredDebtAmount);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('BestTimeToCall');
                if(preLeadWrapper.BestTimeToCall!=null) {
                    pre.writeString(preLeadWrapper.BestTimeToCall);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('PardotId');
                if(preLeadWrapper.PardotId!=null) {
                    pre.writeString(preLeadWrapper.PardotId);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('StateQualification');
                if(preLeadWrapper.StateQualification!=null) {
                    pre.writeString(preLeadWrapper.StateQualification);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('DebtAmountQualification');
                if(preLeadWrapper.DebtAmountQualification!=null) {
                    pre.writeString(preLeadWrapper.DebtAmountQualification);
                } else { 
                    pre.writeNull();
                }
                
                pre.writeFieldName('MetaData');
                if(preLeadWrapper.MetaData!=null) {
                    pre.writeString(preLeadWrapper.MetaData);
                } else { 
                    pre.writeNull();
                }
                pre.writeEndObject();
                system.debug('pre.getAsString()-->'+pre.getAsString());
                req.setBody(pre.getAsString());
                HTTPResponse res = new HTTPResponse();
                system.debug('req-->'+req);
                res = http.send(req);
                status = res.getStatusCode();
                JSONParser parse = JSON.createParser(res.getBody());
                system.debug('response-->'+res.getBody());
                
                if (String.valueOf(status).startsWith('2') == False 
                        && res != null && res.getBody() != null && res.getBody() != '') {
                
                    system.debug('1234');
                    PostCallError postcallErr = (PostCallError)JSON.deserialize(res.getBody(), PostCallError.class);
                    
                    system.debug('postcallErr-->'+postcallErr);
                    
                    if (postcallErr != null && postcallErr.error != null && postcallErr.error.innerError != null
                            && postcallErr.error.innerError.message != null) {
                    
                        errorMessage = String.valueOf(postcallErr.error.innerError.message).deleteWhitespace();
                    }
                } 
                system.debug('errorMessage-->'+errorMessage);
                
                if(genLead == true) {
                  leadMG();
                }
            } else {
                errorMessage = 'No Valid data to do update call';
            }
        } else {
            errorMessage = 'Username or Password or Endpoint is not exist';
        }
    }
    
    public void leadMG(){
      
      nu_dse__Prospect__c prospectToUpdate  = new nu_dse__Prospect__c(
            //nu_dse__CO_Last_Name__c = preLeadWrapper.LastName,
            nu_dse__Last_name__c = preLeadWrapper.LastName,
            nu_dse__First_Name__c=preLeadWrapper.FirstName,
            nu_dse__Address_Line_1__c=preLeadWrapper.Address1,
            nu_dse__Address_Line_2__c=preLeadWrapper.Address2,
            nu_dse__City__c=preLeadWrapper.City,
            nu_dse__State__c =preLeadWrapper.State,
            nu_dse__Postal_Code__c =preLeadWrapper.Zip,
            nu_dse__Email_Address__c=preLeadWrapper.EmailAddress,
            Best_Phone__c=preLeadWrapper.PhoneNumber,
            nu_dse__Total_Debt__c=preLeadWrapper.UnsecuredDebtAmount,
            Best_Time_to_Call__c=preLeadWrapper.BestTimeToCall,
            HasIncomeSource__c=preLeadWrapper.HasIncomeSource,
            MailerId__c =preLeadWrapper.MailerId,
            nu_dse__Country__c='United States'
        );
        
        upsert prospectToUpdate MailerId__c;
        Tester = prospectToUpdate.id;      
    }
    
    public class PreLead {
        
        public Integer Id { get; set; }
        public String MailerId { get; set; }
        public Date MailDate { get; set; }
        public Date ExpirationDate { get; set; }
        public Date InsertDate { get; set; }
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String Address1 { get; set; }
        public String Address2 { get; set; }
        public String City {  get; set; }
        public String State { get; set; }
        public String Zip { get; set; }
        public String EmailAddress { get; set; }
        public String PhoneNumber { get; set; }
        public Double UnsecuredDebtAmount { get; set; }
        public String BestTimeToCall { get; set; }
        public BooLean HasIncomeSource { get; set; }
        public String PardotId { get; set; }
        public String StateQualification { get; set; }
        public String DebtAmountQualification { get; set; }
        public String MetaData { get; set; }
    }
    
    public class PreLeadDeserilalize {
        
        public Integer Id;
        public String MailerId { get; set; }
        public DateTime MailDate { get; set; }
        public DateTime ExpirationDate { get; set; }
        public DateTime InsertDate { get; set; }
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String Address1 { get; set; }
        public String Address2 { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String Zip { get; set; }
        public String EmailAddress { get; set; }
        public String PhoneNumber { get; set; }
        public Double UnsecuredDebtAmount { get; set; }
        public String BestTimeToCall { get; set; }
        public BooLean HasIncomeSource { get; set; }
        public String PardotId { get; set; }
        public String StateQualification { get; set; }
        public String DebtAmountQualification { get; set; }
        public String MetaData { get; set; }
    }
    
    public class PostCallError {
    
        public ErrorClass error;
    }
    
    public class ErrorClass {
    
        public String code;
        public String message;
        public InnerErrorClass innerError;
    }
    
    public class InnerErrorClass {
    
        public String message;
        public String type;
        public String stacktrace;
    }
}