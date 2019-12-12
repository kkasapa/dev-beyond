/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Inbound email handler class for creating Compliance request and attch with related Contact. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-12-09
* @modified       2019-12-11
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class ComplianceRequestEmailHander implements Messaging.InboundEmailHandler {
 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
        String myPlainText= '';
        myPlainText = email.plainTextBody;

        try {
            
            List<nu_dse__Field_mapping__c> fieldMappingList = Utility.getFieldMapping('EmailToComplianceRequest');

            // Query the related Contact using from email address
            List<Contact> relatedConList = [SELECT Id, Email FROM Contact
                                            WHERE Email = :email.fromAddress
                                            ORDER BY LastmodifiedDate DESC LIMIT 1];

            Compliance_Request__c complainceReq = new Compliance_Request__c();
            String emailStr = JSON.serialize(email);
            Map<String, Object> emailMap = (Map<String, Object>) JSON.deserialize(emailStr, Map<String, Object>.class);

            for(nu_dse__Field_mapping__c fieldMapping : fieldMappingList) {

                if(fieldMapping.nu_dse__setDefaultValue__c == true) {
                    complainceReq.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                } else if(emailMap.get('plainTextBody') != null){
                   // complainceReq.put(fieldMapping.nu_dse__Target_Field__c, email.get(fieldMapping.nu_dse__Source_Field__c));
                }
            }

            if(relatedConList.isEmpty() == false) {
                
                complainceReq.Contact__c = relatedConList[0].Id;
            
            } else {

                Default_Task_Assignments_to_User__mdt reqAssignDefault = [SELECT Task_Assignement_User_Id__c 
                                                                   FROM Default_Task_Assignments_to_User__mdt
                                                                   WHERE DeveloperName = 'Complaince_Request_Email' LIMIT 1];

                if(reqAssignDefault != null 
                    && String.isNotBlank(reqAssignDefault.Task_Assignement_User_Id__c) == true
                    && (reqAssignDefault.Task_Assignement_User_Id__c.length() == 15 
                        || reqAssignDefault.Task_Assignement_User_Id__c.length() == 18)
                    && Id.valueOf(reqAssignDefault.Task_Assignement_User_Id__c).getSobjectType().getDescribe().getName() == 'Contact') {
                    
                    complainceReq.Contact__c = reqAssignDefault.Task_Assignement_User_Id__c;

                } else {
                    throw new CustomException('Invalid Contact Id for task assignment. Please check Custom metadata record with Developer Name \'Complaince_Request_Email\'');
                }
            }
            result.success = true;

        } catch (Exception e) {
            
            // Exception created as error log
            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ComplianceRequestEmailHander.handleInboundEmail',
                    nu_dse__Stack_Trace__c = JSON.serialize(email), nu_dse__User_Context__c = UserInfo.getName(),
                    nu_dse__Message__c = e.getMessage());

            insert errLog;
            result.success = false;
        }
        
        return result;
    }
}