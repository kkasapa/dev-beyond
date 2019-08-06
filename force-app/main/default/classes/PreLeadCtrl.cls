public class PreLeadCtrl {

    public PreLead pre_lead{get;set;}
    
    public List<PreLead> pre_leads{get;set;}
    
    public PreLeadSettigs__c settings{get;set;}
    
    public string mailer_Id{get;set;}
    
    public string firstName{get;set;}
   
    public string lastName{get;set;}
    
    public String zipCode { get; set; }
    
    public map<id,PreLead> preLeadMap{get;set;}
    
    public String mailerIdValue { get; set; }
    public Boolean showModal { get; set; }
    public PreLead preLeadWrapper { get; set; }
    public Map<Integer, PreLead> preLeadsMap { get; set; }
    public Integer selectedPreLeadWrapperId { get; set; }
    public Boolean hasError { get; set; }
    public String errorMessage { get; set; }
    public Boolean hasErrorinGetAPI { get; set; }
    public String errorMessageinGetAPI { get; set; }
    public String redirectProspectId { get; set; }
    public list<selectOption> preferredLanguages{get{
        List<selectOption> options = new List<selectOption>(); 
        
        Schema.DescribeFieldResult fieldResult = nu_dse__Prospect__C.Preferred_Language__c.getDescribe();
        List<Schema.PicklistEntry> languages = fieldResult.getPicklistValues();
        
       for( Schema.PicklistEntry f : languages)
       {
         options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }set;}
    public String epoint; 
    String username; 
    String password;
    String pString = '';
    Blob headerValue;
    String authorizationHeader = '';  
    
    public PreLeadCtrl() {
    
        showModal = False;
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
    
    public void showEditModal() {
    
        system.debug('modal action function called');
        system.debug('selectedPreLeadWrapperId-->'+selectedPreLeadWrapperId);
        hasError = False;
        errorMessage = null;
        preLeadWrapper = preLeadsMap.get(Integer.valueOf(selectedPreLeadWrapperId));
        showModal = True;
    }
    
    public void hideEditModal() {
    
        system.debug('modal action function called');
        showModal = False;
    }
    
    public void getPreLeads() {
        
        pre_Leads = new List<PreLead>();
        preLeadsMap = new Map<Integer, PreLead>();
        hasErrorinGetAPI = False;
        errorMessageinGetAPI = '';
        
        if (String.isNotBlank(epoint) && String.isNotBlank(authorizationHeader)) {
        
            String filter = '';
            String endpoint = epoint;
            system.debug('mailerIdValue-->'+mailerIdValue);
            system.debug('firstname-->'+firstname);
            system.debug('lastname-->'+lastname);
            
            if (String.isNotBlank(mailerIdValue)) {
            
                filter += 'MailerId eq \'' + mailerIdValue + '\' and '; 
            }
            
            if (String.isNotBlank(firstname)) {
            
                filter += 'FirstName eq \'' + firstname + '\' and ';
            }
            
            if (String.isNotBlank(lastname)) {
            
                filter += 'LastName eq \'' + lastname + '\' and ';
            }
            
            if (String.isNotBlank(zipCode)) {
            
                filter += 'Zip eq \'' + zipCode + '\' and ';
            }
            
            system.debug('filter-->'+filter);
            
            if (String.isNotBlank(filter)) {
            
                system.debug('filter-->'+filter.removeEnd(' and '));
                
                filter = '?$filter='+EncodingUtil.urlEncode(filter.removeEnd(' and '), 'UTF-8');
                endpoint += filter;
                
                system.debug('endpoint--->'+endpoint);
        
                /*blob headerValue = Blob.valueOf(settings.UserName__c + ':' + settings.Password__c);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);*/
                
                HttpRequest request = new HttpRequest(); 
                request.setEndpoint(endpoint); 
                request.setMethod('GET');
                request.setHeader('Authorization', authorizationHeader);
                request.setTimeout(120000);
                Http http = new Http();
                httpresponse response =  http.send(request); 
                system.debug('response-->'+response);
                String jString = response.getBody();
      
                System.debug('jString'+ jstring);
                List<PreLeadDeserialize> deserializedPreLeads = new List<PreLeadDeserialize>();
                
                JSONParser parser = JSON.createParser(jString);
                 
                while (parser.nextToken() != null) {
                    
                    if ((parser.getCurrentToken() == JSONToken.START_ARRAY)) {
                        
                        deserializedPreLeads = (List<PreLeadDeserialize>)parser.readValueAs(List<PreLeadDeserialize>.class) ;
                    } 
                }
                system.debug('deserializedPreLeads-->'+deserializedPreLeads);
                    
                if (deserializedPreLeads.isEmpty() == False) {
            
                    for (PreLeadDeserialize deserializedPreLead : deserializedPreLeads) {
                    
                        system.debug('deserializedPreLead-->'+deserializedPreLead);
                        PreLead preLeadWrapperRec = new PreLead();
                        preLeadWrapperRec.Id = deserializedPreLead.Id;
                        preLeadWrapperRec.MailerId = deserializedPreLead.MailerId;        
                        preLeadWrapperRec.FirstName = deserializedPreLead.FirstName;            
                        preLeadWrapperRec.MiddleName = deserializedPreLead.MiddleName;            
                        preLeadWrapperRec.LastName = deserializedPreLead.LastName;            
                        preLeadWrapperRec.Address1 = deserializedPreLead.Address1;            
                        preLeadWrapperRec.Address2 = deserializedPreLead.Address2;           
                        preLeadWrapperRec.City = deserializedPreLead.City;            
                        preLeadWrapperRec.State = deserializedPreLead.State;            
                        preLeadWrapperRec.Zip = deserializedPreLead.Zip;           
                        preLeadWrapperRec.MailDate = Date.valueOf(deserializedPreLead.MailDate);            
                        preLeadWrapperRec.ExpirationDate = Date.valueOf(deserializedPreLead.ExpirationDate);           
                        preLeadWrapperRec.InsertDate = Date.valueOf(deserializedPreLead.InsertDate);            
                        preLeadWrapperRec.EmailAddress = deserializedPreLead.EmailAddress;            
                        preLeadWrapperRec.PhoneNumber = deserializedPreLead.PhoneNumber;            
                        preLeadWrapperRec.UnsecuredDebtAmount = deserializedPreLead.UnsecuredDebtAmount;                     
                        preLeadWrapperRec.BestTimeToCall = deserializedPreLead.BestTimeToCall;            
                        preLeadWrapperRec.HasIncomeSource = deserializedPreLead.HasIncomeSource;            
                        preLeadWrapperRec.PardotId = deserializedPreLead.PardotId;            
                        preLeadWrapperRec.StateQualification = deserializedPreLead.StateQualification;            
                        preLeadWrapperRec.DebtAmountQualification = deserializedPreLead.DebtAmountQualification;
                        preLeadWrapperRec.MetaData = deserializedPreLead.MetaData; 
                        preLeadWrapperRec.isQualified = deserializedPreLead.isQualified;  
                        pre_leads.add(preLeadWrapperRec);
                        preLeadsMap.put(preLeadWrapperRec.Id, preLeadWrapperRec);
                    }         
                }
                
                if (pre_leads.isEmpty()) {
                
                    hasErrorinGetAPI = True;
                    errorMessageinGetAPI = 'No Records found. Please redefine the filter criteria';
                }
                
            } else {
            
            }
            
        } else {
        
        }
    }
    
    public void postBack() {
        
        hasError = False;
        errorMessage = null;
        redirectProspectId = null;
        
        try {
        
            if(String.isBlank(authorizationHeader) == FALSE && String.isBlank(epoint) == FALSE) {
            
                if (preLeadWrapper != null && preLeadWrapper.Id != null) {
                
                    Integer status = null;
                    
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
                    if(preLeadWrapper.MailerId != null) {
                        pre.writeString(String.valueOf(preLeadWrapper.MailerId));
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
                    system.debug('res-->'+res);
                    status = res.getStatusCode();
                    JSONParser parse = JSON.createParser(res.getBody());
                    system.debug('response-->'+res.getBody());
                    system.debug('status-->'+res.getStatusCode());
                    getPreLeads();
                    if (String.valueOf(status).startsWith('2') == False 
                            && res != null && res.getBody() != null && res.getBody() != '') {
                    
                        system.debug('1234');
                        PostCallError postcallErr = (PostCallError)JSON.deserialize(res.getBody(), PostCallError.class);
                        
                        system.debug('postcallErr-->'+postcallErr);
                        
                        if (postcallErr != null && postcallErr.error != null && postcallErr.error.innerError != null
                                && postcallErr.error.innerError.message != null) {
                        
                            errorMessage = String.valueOf(postcallErr.error.innerError.message).deleteWhitespace();
                            hasError = True;
                        }
                    }
                    system.debug('errorMessage-->'+errorMessage);
                    system.debug('preLeadWrapper.isqualified-->'+preLeadWrapper.isQualified);
                    if(preLeadWrapper.isQualified == True) {
                      updateProspectInSF();
                    }
                } else {
                    errorMessage = 'No Valid data to do update call';
                    hasError = True;
                }
            } else {
                errorMessage = 'Username or Password or Endpoint is not exist';
                hasError = True;
            }
        } catch(Exception e) {
        
            errorMessage = e.getMessage();
            hasError = True;
        }
        
        if (hasError == False) {
        
            hideEditModal();
        }
    }
    
    public void updateProspectInSF(){
      system.debug('Entered in update prospect method');
      nu_dse__Prospect__c prospectToUpdate  = new nu_dse__Prospect__c(
            nu_dse__Last_name__c = preLeadWrapper.LastName,
            nu_dse__First_Name__c=preLeadWrapper.FirstName,
            Middle_Name__c = preLeadWrapper.MiddleName,
            nu_dse__MI__c = preLeadWrapper.MiddleName.left(1),
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
            nu_dse__Country__c='United States',
            Preferred_Language__c=preLeadWrapper.preferredLanguage	
        );
        
        upsert prospectToUpdate MailerId__c;
        redirectProspectId = prospectToUpdate.Id;
        
        System.debug('Id:'+ prospectToUpdate.id);
    }
    
    /*public PageReference  mailer(){
        
        settings = PreLeadSettigs__c.getInstance(userinfo.getUserId());
        string mailerId = mailer_Id;
        String  endPoint = ''; 
        
        if(settings !=null && settings.EndPointURL__c !=null && settings.EndPointURL__c !=''){
            
            endpoint = settings.EndPointURL__c; 
            
            if(!endpoint.endsWith('/')){
                
                endpoint +='/';
            }
        }
        
        if(mailerId !=null && mailerId !=''){
            
             endpoint += 'PreLead(\''+mailerId+'\')';
           
            
            
            System.debug('EndPoint: '+ endpoint);
            
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint(endpoint); 
            request.setMethod('GET');
            Http http = new Http();
            
           httpresponse response =  http.send(request); 
            
           String jString =  response.getBody();
          
            System.debug('jString'+ jstring);
            
           // Pre_Lead = new PreLead();
            
          Pre_Lead  =(Prelead) json.deserialize(jString, Prelead.class);
            
          Pre_Leads = new List<PreLead>(); 
            
          pre_Leads.add(pre_Lead);
            
            System.debug('MailerId'+Pre_Lead.mailerId);
       
        }
        
        
        return null; 
        
    }*/
    
    
    
    /*public PageReference PreLead_Patch(PreLead lead){
        
        lead.isqualified = null;
        lead.firstName = lead.firstname;
        String jstring = Json.serialize(lead,true);
        
        settings = PreLeadSettigs__c.getInstance(userinfo.getUserId());
      
        String  endPoint = ''; 
        
        if(settings !=null && settings.EndPointURL__c !=null && settings.EndPointURL__c !=''){
            
            endpoint = settings.EndPointURL__c; 
            
            if(!endpoint.endsWith('/')){
                
                endpoint +='/';
            }
        }   
            endpoint += 'PreLead';
            
            System.debug('EndPoint: '+ endpoint);
            System.debug('Body: '+ jstring);
           HttpRequest request = new HttpRequest(); 
            request.setEndpoint(endpoint); 
            request.setHeader('Content-Type' , 'application/json');
            request.setHeader('Cache-Control','no-cache');
            request.setBody(jstring);
            request.setMethod('POST');
            Http http = new Http();
            
           httpresponse response =  http.send(request); 
            
           String resp=  response.getBody();
        
            return null; 
        
    }*/
    
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
        public Boolean isQualified { get; set; }
        public String preferredLanguage{get;set;}
       
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
    
    public class PreLeadDeserialize {
        
        public Integer Id { get; set; }
        public String MailerId { get; set; }
        public DateTime MailDate { get; set; }
        public DateTime ExpirationDate { get; set; }
        public DateTime InsertDate { get; set; }
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
        public Boolean isQualified { get; set; }
    }
    
    /*public class PreLead{
        
        public string MailerId{get;set;}
        public Boolean isQualified{get;set;}
        public Date MailDate{get;set;}
        public Date ExpirationDate{get;set;}
        public Date InsertDate{get;set;}
        public string FirstName{get;set;}
        public string MiddleName{get;set;}
        public string LastName{get;set;}
        public string Address1{get;set;}
        public string Address2{get;set;}
        public string City{get;set;}
        public string State{get;set;}
        public string Zip{get;set;}
        public string EmailAddress{get;set;}
        public string PhoneNumber{get;set;}
        public Decimal UnsecuredDebtAmount{get;set;}
        public string BestTimeToCall{get;set;}
        public Boolean HasIncomeSource{get;set;}
        
        public PreLead(String mailer_id, DateTime mail_Date, String fName, String lName, String add1, String add2, String pcity, string pstate, string pzip, string pemail, String phone, Decimal debtamt, string timetoCall, Boolean incomesource){
            
            this.MailerId = mailer_id; 
            this.MailDate =mail_Date;
            this.FirstName = fName;
            this.lastName = lName;
            this.Address1= add1; 
            this.Address2 = add2; 
            this.City = pCity; 
            this.State = pstate; 
            this.zip = pzip; 
            this.EmailAddress = pemail; 
            this.PhoneNumber = phone; 
            this.UnsecuredDebtAmount = debtamt; 
            this.BestTimeToCall = timetoCall; 
            this.HasIncomeSource = HasIncomeSource; 
        }
    }*/
    
    public PageReference Save(){
        
        /*PageReference page;
        
        if(pre_Lead.isQualified){
            
            
            //preLead_Patch(pre_Lead);
            
            Id pId=convert(pre_Lead);
            
            page = new PageReference('/'+pId);
            
            page.setRedirect(true);
            
            
        }else{
            
            
            ApexPages.addMessage( new ApexPages.message(ApexPages.Severity.warning,'Not Qualified'));
            
        }
        return page;*/
        return null; 
    }
    
    /*public Id convert(PreLead lead){
        
        nu_dse__Prospect__c prospect = new Nu_dse__Prospect__c(); 
        
        prospect.nu_dse__First_Name__c = lead.firstName; 
        
        prospect.nu_dse__Last_name__c = lead.lastName; 
        
        prospect.nu_dse__Address_Line_1__c = lead.Address1; 
        
        prospect.nu_dse__CO_ADDLINE2__c = lead.Address2; 
        
        prospect.nu_dse__City__c = lead.City; 
        
        prospect.nu_dse__Cell_Phone__c = lead.PhoneNumber; 
        
        prospect.nu_dse__Email_Address__c = lead.EmailAddress; 
        
        insert prospect; 
        
        return prospect.id; 
    }*/
    
    
}