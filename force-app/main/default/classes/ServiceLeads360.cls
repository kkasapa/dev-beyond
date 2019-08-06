public class ServiceLeads360 {

    public static final String SOAP_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static final String SOAP12_NS = 'http://www.w3.org/2003/05/soap-envelope';
    public static final String XSI = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String XSD = 'http://www.w3.org/2001/XMLSchema';
    public static final String SERVICE_NS = 'https://service.leads360.com';
    
    public  String userName{get;set;}
    public  String password{get;set;}
    public  String endpoint{get;set;}
    public  String SOAP_Action_Lead_Action_Update{get;set;}
    public  String SOAP_Action_Lead_Update{get;set;}
    public  String SOAP_Action_Status_Update{get;set;}
    public Boolean containsLeadNode = False;
    
    public ServiceLeads360(){
        
        Velocify_API_Settings__c settings = Velocify_API_Settings__c.getInstance(UserInfo.getUserId());
        if(settings !=null){
            userName = settings.Username__c; 
            password = settings.Password__c; 
            endpoint = settings.Endpoint__c; 
            SOAP_Action_Lead_Action_Update = settings.SOAP_Action_Lead_Action_Update__c; 
            SOAP_Action_Lead_Update = settings.SOAP_Action_Lead_Update__c; 
            SOAP_Action_Status_Update = settings.SOAP_Action_Status_Update__c; 
        } 
    }
    /* This method not used in any codes
    public   Dom.Document getLeadByIdRequest(String leadId){
          
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP_NS, 'soapenv');
        envelope.setNamespace('ser', SERVICE_NS);
        
        //envelope.setAttributeNS('schemaLocation', SOAP_NS, XSI, 'soapenv');
        dom.XmlNode header  = envelope.addChildElement('Header', SOAP_NS, 'soapenv');
        dom.XmlNode body =  envelope.addChildElement('Body', SOAP_NS, 'soapenv');
        dom.XmlNode getlead =  body.addChildElement('GetLead', SERVICE_NS, 'ser');
        getlead.addChildElement('username', SERVICE_NS, 'ser').addTextNode(userName);
        getlead.addChildElement('password', SERVICE_NS, 'ser').addTextNode(password);
        getlead.addChildElement('leadId', SERVICE_NS, 'ser').addTextNode(leadId);
        System.debug(doc.toXmlString());
        return doc; 
    }*/
    // Method to create XML Node for each leads
    public  dom.xmlNode getLeadXML( Dom.XmlNode leadsElement,  nu_dse__Prospect__c lead, Map<String,String> fieldMap, 
                                    nu_dse__Program__c programRec, Map<String,String> programFieldMap){
        
        Dom.XmlNode leadElement = leadsElement.addChildElement('Lead', null, null);
        leadElement.setAttribute('Id', lead.velocify_id__c);
        // leadElement.addChildElement('Status',null,null).setAttribute('StatusId','');
        Dom.XmlNode fields = leadElement.addChildElement('Fields',null,null); 
        Map<String, Schema.SObjectField> peospectFieldsMap = Schema.SObjectType.nu_dse__Prospect__c.fields.getMap();
        Set<String> programFields = new Set<String>{'Id', 'Name'};
        
        for(String prospectField : peospectFieldsMap.keySet()){
            
            if(fieldMap !=null 
                && fieldMap.containsKey(prospectField.toUpperCase()) 
                && lead.get(prospectField.toUpperCase()) != null){
                dom.xmlNode fieldNode = fields.addChildElement('Field',null,null); 
                fieldNode.setAttribute('FieldId', fieldMap.get(prospectField.toUpperCase()));
                fieldNode.setAttribute('Value', String.valueOf(lead.get(prospectField.toUpperCase())));
                containsLeadNode = True;                    
            }
        }
        if(programRec != null) {
            for(String programField : programFields) {
                
                if(programFieldMap.containsKey(programField.toUpperCase())
                    && programRec.get(programField.toUpperCase()) != null) {

                    dom.xmlNode fieldNode = fields.addChildElement('Field',null,null); 
                    fieldNode.setAttribute('FieldId', programFieldMap.get(programField.toUpperCase()));
                    fieldNode.setAttribute('Value', String.valueOf(programRec.get(programField.toUpperCase())));
                    containsLeadNode = True;  
                }
            }
        }
        return leadsElement; 
    }
    
    public  void modifyLeads(List<nu_dse__Prospect__C> leads){
        
        Map<String, Id> velocifyIdSFIdMap = new Map<String, Id>();
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        List<nu_dse__Prospect__c> updateProspectList = new List<nu_dse__Prospect__c>();

        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
        envelope.setNamespace('xsi', XSI);
        envelope.setNamespace('xsd', XSD);
        //envelope.setNamespace('ser',SERVICE_NS);
        //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
        dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
        dom.XmlNode modifyLeads =  body.addChildElement('ModifyLeads', null, null);
    
        modifyLeads.setNamespace('',SERVICE_NS);
        modifyLeads.addChildElement('username', null, null).addTextNode(userName);
        modifyLeads.addChildElement('password', null, null).addTextNode(password);
        Dom.XmlNode leadsElement = modifyLeads.addChildElement('leads', null, null);
        leadsElement = leadsElement.addChildElement('Leads', null, null);
        Map<String,string> fieldMap = new Map<String,string>(); 
        Map<String,string> programFieldMap = new Map<String,string>(); 
        Map<Id, nu_dse__Program__c> prospectIdProgramMap = new Map<Id, nu_dse__Program__c>();
        Set<String> dataMappingName = new Set<String>{'VelocifyLead', 'VelocifyProgram'};

        for(nu_dse__Field_mapping__c fieldMapping : [SELECT Id, nu_dse__Data_Mapping__c, nu_dse__Source_Field__c, 
                                                        nu_dse__Target_Field__c, nu_dse__Data_Mapping__r.Name 
                                                    FROM nu_dse__Field_mapping__c 
                                                    WHERE nu_dse__Data_Mapping__r.Name IN :dataMappingName]){ //query datamapping for both prospect/Program
            if(fieldMapping.nu_dse__Data_Mapping__r.Name == 'VelocifyLead') { //filtering field mappings based on datamapping name - for prospect
                fieldMap.put(fieldMapping.nu_dse__Source_Field__c.toUpperCase(), fieldMapping.nu_dse__Target_Field__c);
            }
            if(fieldMapping.nu_dse__Data_Mapping__r.Name == 'VelocifyProgram') { //filtering field mappings based on datamapping name - for program
                programFieldMap.put(fieldMapping.nu_dse__Source_Field__c.toUpperCase(), fieldMapping.nu_dse__Target_Field__c);
            }
        }
        for(nu_dse__Program__c program : [SELECT Id, Name, Prospect_Lookup__c 
                                          FROM nu_dse__Program__c 
                                          WHERE Prospect_Lookup__c IN :leads]) { //query program for sending data from program
            prospectIdProgramMap.put(program.Prospect_Lookup__c, program);
        }
        for(nu_dse__Prospect__C leadInst : leads){

            nu_dse__Program__c programRec;
            if(prospectIdProgramMap.containskey(leadInst.Id)) {
                programRec = prospectIdProgramMap.get(leadInst.Id);
            }
            leadsElement = getLeadXML(leadsElement, leadInst, fieldMap, programRec, programFieldMap);
            velocifyIdSFIdMap.put(leadInst.velocify_id__c, leadInst.Id);
        }
        System.debug('XML String: '+ doc.toXMLString());
        //check whether it contains atleast one Lead node...
        if (containsLeadNode == True) {
        
            String endpoint= endpoint; // 'http://service.leads360.com/ClientService.asmx'  // Moved to custom settings
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('SOAPAction', SOAP_Action_Lead_Update); // 'https://service.leads360.com/ModifyLeads'  // Moved to custom settings
            req.setHeader('Content-Type','text/xml;charset=UTF-8');
            //req.setbody(doc.toXMLString());
            req.setBodyDocument(doc);
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            System.debug('doc.toXMLString()--->'+doc.toXMLString());
            System.debug('request--->'+req);
            res = http.send(req);

            system.debug('res.getBody():::'+res.getBody());
            if(res.getStatusCode()  == 500 
                && string.isNotBlank(res.getBody())) { //parsing the response for errors at 500

                Dom.Document docment = new Dom.Document();
                String responseBody = res.getBody();
                //response body contains few HTML content which is trimmed in below logic to get proper xml response.
                if(responseBody.contains('</html>')) {
                    responseBody = responseBody.substringAfter('</html>').trim();
                }
                docment.load(responseBody);
                Dom.XMLNode root = docment.getRootElement();     
                string errorString = getXmlNodeValue(root, 'Text').trim();

                //If the response has errors, we create error logs for tracking what went wrong
                if(String.isNotBlank(errorString)) {
                    
                    for(nu_dse__Prospect__C leadInst : leads){

                        nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ServiceLeads360.modifyLeads',
                            nu_dse__Error_Causing_Record_Id__c = leadInst.Id,
                            nu_dse__Message__c = errorString, nu_dse__User_Context__c = userInfo.getUserName());
                    
                        errorLogList.add(errorLog);
                    }
                }
            } else if(res.getStatusCode()  == 200 
                        && string.isNotBlank(res.getBody())) { //parsing the response for errors at 200
                
                system.debug('body::'+res.getBody());
                XmlStreamReader responseReader = new XmlStreamReader(res.getBody());
                Boolean isSafeToGetNextXmlElement = true;

                while(isSafeToGetNextXmlElement) {
                    if (responseReader.getLocalName() == 'lead' 
                        && responseReader.isStartElement()) {
                        
                        if(responseReader.getAttributeValue(null, 'statusId') != '2'
                            && responseReader.getAttributeValue(null, 'statusId') != '3') {
                            //creating errorlogs for any failures
                            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ServiceLeads360.modifyLeads',
                                nu_dse__Error_Causing_Record_Id__c = velocifyIdSFIdMap.get(responseReader.getAttributeValue(null, 'id')),
                                nu_dse__Message__c = responseReader.getAttributeValue(null, 'message'), nu_dse__User_Context__c = userInfo.getUserName());
                
                            errorLogList.add(errorLog);
                        }
                        responseReader.next();

                    } else if (responseReader.hasNext()) {
                        responseReader.next();
                    } else {
                        isSafeToGetNextXmlElement = false;
                        break;
                    }
                }
            }
            if(errorLogList.isEmpty() == false) {
                insert errorLogList; //inserting error logs.
                for (nu_dse__Error_Log__c errorlog : errorLogList){
                    nu_dse__Prospect__c prospectInst = new nu_dse__Prospect__c(Id = errorlog.nu_dse__Error_Causing_Record_Id__c, 
                            nu_dse__Processor_Error__c = errorlog.Id);
                    updateProspectList.add(prospectInst);
                }
                update updateProspectList; // errorlogs are tied to prospects with Processor Error Field.
            }
        }
    }
    
    public void modifyLeadStatus(List<ModifyLeadApiRequestWrapper> modifyLeadStatusRequestWrapperList ){
        
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        List<nu_dse__Prospect__c> updateProspectList = new List<nu_dse__Prospect__c>();

        for(ModifyLeadApiRequestWrapper leadStatusRequest : modifyLeadStatusRequestWrapperList) {
            
            if (leadStatusRequest.leadId != null 
                && leadStatusRequest.leadStatusId != null) {
              
                DOM.Document doc = new DOM.Document();
                dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
                envelope.setNamespace('xsi', XSI);
                envelope.setNamespace('xsd', XSD);
                //envelope.setNamespace('ser',SERVICE_NS);
                //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
                dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
                dom.XmlNode modifyLeadsStatus =  body.addChildElement('ModifyLeadStatus', null, null);
                modifyLeadsStatus.setNamespace('',SERVICE_NS);
                modifyLeadsStatus.addChildElement('username', null, null).addTextNode(userName);
                modifyLeadsStatus.addChildElement('password', null, null).addTextNode(password);
                modifyLeadsStatus.addChildElement('leadId', null, null).addTextNode(leadStatusRequest.leadId);
                modifyLeadsStatus.addChildElement('statusId', null, null).addTextNode(leadStatusRequest.leadStatusId);
                System.debug('XML String: '+ doc.toXMLString());
        
                String endpoint= endpoint; // 'http://service.leads360.com/ClientService.asmx'   // Moved to custom settings
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('SOAPAction', SOAP_Action_Status_Update); //'https://service.leads360.com/ModifyLeadStatus'  // Moved to custom settings
                req.setHeader('Content-Type','text/xml;charset=UTF-8');
                //req.setbody(doc.toXMLString());
                req.setBodyDocument(doc);
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                res = http.send(req);

                System.debug('**** response of modifyLeadStatus ' + res.getBody());
                if(res.getStatusCode()  == 500 
                    && string.isNotBlank(res.getBody())) {

                    Dom.Document docment = new Dom.Document();
                    String responseBody = res.getBody();
                    if(responseBody.contains('</html>')) {
                        responseBody = responseBody.substringAfter('</html>').trim();
                    }
                    docment.load(responseBody);
                    Dom.XMLNode root = docment.getRootElement();     
                    string errorString = getXmlNodeValue(root, 'Text').trim();

                    if(String.isNotBlank(errorString)) {
                        
                        nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ServiceLeads360.modifyLeadStatus',
                            nu_dse__Error_Causing_Record_Id__c = leadStatusRequest.leadSFId,
                            nu_dse__Message__c = errorString, nu_dse__User_Context__c = userInfo.getUserName());
                        errorLogList.add(errorLog);
                    }
                }
            }
        }
        if(errorLogList.isEmpty() == false) {
            insert errorLogList;
            for (nu_dse__Error_Log__c errorlog : errorLogList){
                nu_dse__Prospect__c prospectInst = new nu_dse__Prospect__c(Id = errorlog.nu_dse__Error_Causing_Record_Id__c, 
                        nu_dse__Processor_Error__c = errorlog.Id);
                updateProspectList.add(prospectInst);
            }
            update updateProspectList;
        }
    }
    
    public void addLeadAction(List<ModifyLeadApiRequestWrapper> modifyLeadStatusRequestWrapperList){
        
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        List<nu_dse__Prospect__c> updateProspectList = new List<nu_dse__Prospect__c>();

        for(ModifyLeadApiRequestWrapper leadStatusRequest : modifyLeadStatusRequestWrapperList) {
          
            if (leadStatusRequest.leadId != null && leadStatusRequest.actionID != null) {
                
                DOM.Document doc = new DOM.Document();
                dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP12_NS, 'soap12');
                envelope.setNamespace('xsi', XSI);
                envelope.setNamespace('xsd', XSD);
                //envelope.setNamespace('ser',SERVICE_NS);
                //dom.XmlNode header  = envelope.addChildElement('Header', SOAP12_NS, 'soapenv');
                dom.XmlNode body =  envelope.addChildElement('Body', SOAP12_NS, 'soap12');
                dom.XmlNode addActions =  body.addChildElement('AddLeadAction', null, null);
                addActions.setNamespace('',SERVICE_NS);
                addActions.addChildElement('username', null, null).addTextNode(userName);
                addActions.addChildElement('password', null, null).addTextNode(password);
                addActions.addChildElement('leadId', null, null).addTextNode(leadStatusRequest.leadId);
                addActions.addChildElement('actionTypeId', null, null).addTextNode(leadStatusRequest.actionID);
                addActions.addChildElement('actionNote', null, null).addTextNode((leadStatusRequest.actionNote != null)?leadStatusRequest.actionNote : '');
                System.debug('XML String: '+ doc.toXMLString());
                
                String endpoint = endpoint; // 'http://service.leads360.com/ClientService.asmx'   // Moved to custom settings
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('SOAPAction', SOAP_Action_Lead_Action_Update); // 'https://service.leads360.com/AddLeadAction'   // Moved to custom settings
                req.setHeader('Content-Type','text/xml;charset=UTF-8');
                //req.setbody(doc.toXMLString());
                req.setBodyDocument(doc);
               
                Http http = new Http();
                //HttpResponse res = http.send(req);
                HttpResponse res = new HttpResponse();
                res = http.send(req);

                system.debug('res.getBody():::'+res.getBody());
                if(res.getStatusCode()  == 500 
                    && string.isNotBlank(res.getBody())) {

                    Dom.Document docment = new Dom.Document();
                    String responseBody = res.getBody();
                    if(responseBody.contains('</html>')) {
                        responseBody = responseBody.substringAfter('</html>').trim();
                    }
                    docment.load(responseBody);
                    Dom.XMLNode root = docment.getRootElement();     
                    string errorString = getXmlNodeValue(root, 'Text').trim();

                    if(String.isNotBlank(errorString)) {
                        
                        nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ServiceLeads360.addLeadAction',
                            nu_dse__Error_Causing_Record_Id__c = leadStatusRequest.leadSFId,
                            nu_dse__Message__c = errorString, nu_dse__User_Context__c = userInfo.getUserName());
                        errorLogList.add(errorLog);
                    }
                }
            }
        }
        if(errorLogList.isEmpty() == false) {
            insert errorLogList;
            for (nu_dse__Error_Log__c errorlog : errorLogList){
                nu_dse__Prospect__c prospectInst = new nu_dse__Prospect__c(Id = errorlog.nu_dse__Error_Causing_Record_Id__c, 
                        nu_dse__Processor_Error__c = errorlog.Id);
                updateProspectList.add(prospectInst);
            }
            update updateProspectList;
        }
    }
    /*  
    public class Lead {
        
        public String id{get;set;}
        public list<ServiceLeads360.FieldValues> field_values{get;set;} 
        public Lead(String externalId, List<FieldValues> fmap){
            this.id = externalId; 
            this.field_values = fmap; 
        }
    }
   
   public class FieldValues{
        
        public string field{get;set;}
        public string value{get;set;}
        public FieldValues(String f, string v){
            this.field = f; 
            this.value = v; 
        }
    }
    
    public class ResponseWrapper {
    
        public String statusCode;
        public String statusMessage;
        public ResponseWrapper(String statusCode, String message) {
            this.statusCode = statusCode;
            this.statusMessage = message;
        }
    }*/
    
    public class ModifyLeadApiRequestWrapper {
        
        public String leadId;
        public String leadStatusId;
        public String actionId;
        public String actionNote;
        public String leadSFId;
    }

    public static String getXmlNodeValue(DOM.XMLNode node, String field) {
        
        String result = '\n';
        
        if(node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            
            if(node.getName().trim() == field) {
                result += node.getText().trim();
            }
            
            for(DOM.XMLNode child : node.getChildElements()) {
                result += getXmlNodeValue(child, field);
            }
            return result;
        }
        return result;
    }
}