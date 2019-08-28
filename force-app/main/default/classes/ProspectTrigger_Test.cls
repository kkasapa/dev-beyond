@isTest
public class ProspectTrigger_Test implements HttpCalloutMock {
    
    //creating data for unit test
    @testSetup static void testDataCreation() {
        
        Velocify_API_Settings__c settings = new Velocify_API_Settings__c();
        settings.Username__c = 'TestUserName';
        settings.Password__c = '12345';
        settings.Endpoint__c = 'http://service.leads360.com/ClientService.asmx';
        settings.SOAP_Action_Lead_Action_Update__c = 'https://service.leads360.com/AddLeadAction';
        settings.SOAP_Action_Lead_Update__c = 'https://service.leads360.com/ModifyLeads';
        settings.SOAP_Action_Status_Update__c = 'https://service.leads360.com/ModifyLeadStatus';
        insert settings;
        
        TU_Permission_Audit__c permAudit = new TU_Permission_Audit__c(uuid__c = '187.55', Created_At__c = system.today());
        insert permAudit;
         
        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.nu_dse__Last_Disposition__c = 'Disqualified';
        prospectInstance.Has_Been_Assigned__c = true ;
        prospectInstance.FIve9_Owner_ID__c = userInfo.getUserId();
        insert prospectInstance;
        
        nu_dse__Prospect__c prospectInstance1 = TestRecordCreator.createProspect();
        prospectInstance1.nu_dse__Last_Disposition__c = 'Disqualified';
        prospectInstance1.uuid__c = '187.55';
        insert prospectInstance1;
    }
    static testMethod void validateProspectHandler()
    {
        nu_dse__Prospect__c testp = new nu_dse__Prospect__c(nu_dse__First_Name__c='Test Prospect', nu_dse__Last_Name__c='Prospect');
        insert testp;
        nu_dse__Prospect__c testProspect = [SELECT Id FROM nu_dse__Prospect__c WHERE nu_dse__First_Name__c = 'Test Prospect' AND nu_dse__Last_Name__c= 'Prospect' LIMIT 1];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(testProspect.id);
        app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(app);
        testProspect.Recalled_Approval__c = true;
        update testProspect;
    }
    
    //testing trigger updates on Disposition Email Type
    @isTest
    public static void updateDispositionEmailType_Test() {
    
        List<nu_dse__Prospect__c> prospectList = [SELECT Id FROM nu_dse__Prospect__c LIMIT 1];
        
        prospectList[0].nu_dse__Last_Disposition__c = 'LTLending';
        update prospectList;
        
        List<nu_dse__Prospect__c> updatedProspectList = [SELECT Id, Disposition_Email_Type__c, FIve9_Owner_ID__c, OwnerId, uuid__c  
                                                         FROM nu_dse__Prospect__c LIMIT 2];
        system.assertEquals('LTLending', updatedProspectList[0].Disposition_Email_Type__c);
        system.assertEquals(Id.valueof(updatedProspectList[0].FIve9_Owner_ID__c), updatedProspectList[0].OwnerId);
        system.assert(updatedProspectList[0].uuid__c != null);
        system.assertEquals('PullTU-NotQualified', updatedProspectList[1].Disposition_Email_Type__c);
    }
    
    //testing sync with Velocify on updating Last Disposition with proper Velocify id
    @isTest
    public static void modifyLeadTests() {
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = TestRecordCreator.createDataMapping('VelocifyLead', '', '');
        insert dataMappingInstance1;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c> ();
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead1 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'LTLending',
                                                                                                          '498', False, null);
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead2 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'nu_dse__Last_Disposition__c',
                                                                                                          '499', False, null);                                                                                     
        fieldMappingList.add(fieldMappingInstanceVelocifyLead1);
        fieldMappingList.add(fieldMappingInstanceVelocifyLead2);
        insert fieldMappingList;
        
        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.velocify_id__c = '1';
        prospectInstance.uuid__c = '187.50';
        insert prospectInstance;
        prospectInstance.nu_dse__Last_Disposition__c = 'Waiting on EA';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new ProspectTrigger_Test());
            update prospectInstance;
        Test.stopTest();
    }

    //testing sync with Velocify on updating Last Disposition with proper Velocify id - failure case
    @isTest
    public static void modifyLeadTestFaliTest() {
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = TestRecordCreator.createDataMapping('VelocifyLead', '', '');
        insert dataMappingInstance1;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c> ();
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead1 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'LTLending',
                                                                                                          '498', False, null);
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead2 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'nu_dse__Last_Disposition__c',
                                                                                                          '499', False, null);                                                                                     
        fieldMappingList.add(fieldMappingInstanceVelocifyLead1);
        fieldMappingList.add(fieldMappingInstanceVelocifyLead2);
        insert fieldMappingList;
        
        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.velocify_id__c = '1';
        prospectInstance.uuid__c = '187.50';
        insert prospectInstance;
        prospectInstance.nu_dse__Last_Disposition__c = 'Waiting on EA';

        Velocify_API_Settings__c velocifyApi = [SELECT Id, Password__c FROM Velocify_API_Settings__c]; 
        velocifyApi.Password__c = '56789';
        update velocifyApi;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new ProspectTrigger_Test());
            update prospectInstance;
        Test.stopTest();
    }
    
    // testing Velocify lead Status update when Prospect Status(Last Diposition through WF) is updated
    @isTest
    public static void modifyLeadStatus() {
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = TestRecordCreator.createDataMapping('VelocifyLeadStatusMapping', 'nu_dse__Prospect__c', 'Velocify');
        insert dataMappingInstance1;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c> ();
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead1 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'Waiting on EA',
                                                                                                          '209', False, null);
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead2 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'Interested',
                                                                                                          '57', False, null);                                                                                     
        fieldMappingList.add(fieldMappingInstanceVelocifyLead1);
        fieldMappingList.add(fieldMappingInstanceVelocifyLead2);
        insert fieldMappingList;
        
        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.velocify_id__c = '1';
        prospectInstance.uuid__c = '187.50';
        insert prospectInstance;

        prospectInstance.nu_dse__Last_Disposition__c = 'Waiting on EA';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new ProspectTrigger_Test());
            update prospectInstance;
        Test.stopTest();
    }
    
    // testing Velocify lead Action update when Prospect Status(Last Diposition through WF) is updated
    @isTest
    public static void addLeadAction() {
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = TestRecordCreator.createDataMapping('VelocifyActionMap', 'Lead', 'Velocify');
        insert dataMappingInstance1;
        
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead1 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'Waiting on EA',
                                                                                                          '76', False, null);
        insert fieldMappingInstanceVelocifyLead1;
        
        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.velocify_id__c = '1';
        prospectInstance.uuid__c = '187.50';
        insert prospectInstance;
        prospectInstance.nu_dse__Last_Disposition__c = 'Waiting on EA';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new ProspectTrigger_Test());
            update prospectInstance;
        Test.stopTest();
    }
    
    public HTTPResponse respond(HTTPRequest req) {

        String SOAP_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String SOAP12_NS = 'http://www.w3.org/2003/05/soap-envelope';
        String XSI = 'http://www.w3.org/2001/XMLSchema-instance';
        String XSD = 'http://www.w3.org/2001/XMLSchema';
        String SERVICE_NS = 'https://service.leads360.com';
        String wsa = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
        String wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
        String wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';

        Dom.Document docment = req.getBodyDocument();
        Dom.XMLNode root = docment.getRootElement();     
        string password = ServiceLeads360.getXmlNodeValue(root, 'password').trim();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope  = doc.createRootElement('Envelope', SOAP_NS, 'soap');
        envelope.setNamespace('soap', SOAP12_NS);
        envelope.setNamespace('xsi', XSI);
        envelope.setNamespace('xsd', XSD);
        envelope.setNamespace('wsa', wsa);
        envelope.setNamespace('wsse', wsse);
        envelope.setNamespace('wsu', wsu);
        dom.XmlNode header  = envelope.addChildElement('Header', SOAP_NS, 'soap');
        dom.XmlNode body =  envelope.addChildElement('Body', SOAP_NS, 'soap');

        if(password != '56789') {
            dom.XmlNode Fault =  body.addChildElement('Fault', SOAP_NS, 'soap');
            dom.XmlNode Reason =  Fault.addChildElement('Reason', SOAP_NS, 'soap');
            dom.XmlNode Text =  Reason.addChildElement('Text', SOAP_NS, 'soap');
            Text.addTextNode('System.Web.Services.Protocols.SoapException: Server was unable to process request.');
            res.setStatusCode(500);
        } else {
            dom.XmlNode modifyLeads =  body.addChildElement('ModifyLeadsResponse', null, null);
            modifyLeads.setNamespace('',SERVICE_NS);
            dom.XmlNode ModifyLeadsResult =  modifyLeads.addChildElement('ModifyLeadsResult', null, null);
            dom.XmlNode Response =  ModifyLeadsResult.addChildElement('Response', null, null);
            dom.XmlNode Modifications =  Response.addChildElement('Modifications', null, null);
            Dom.XmlNode Lead = Modifications.addChildElement('Lead', null, null);
            Lead.setAttribute('id', '1');
            Lead.setAttribute('status', '4');
            Lead.setAttribute('message', 'No update needed');
            Dom.XmlNode Field = Lead.addChildElement('Field', null, null);
            Field.setAttribute('id', '1');
            Field.setAttribute('status', '4');
            Field.setAttribute('message', 'No update needed'); 
            res.setStatusCode(200);
        }
        res.setBody(doc.toXmlString());
        return res;
    }
}