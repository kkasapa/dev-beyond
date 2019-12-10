/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Inbound email handler class for creating task and attch with related person Account. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-12-09
* @modified       2019-12-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class InboundEmailTaskCreation implements Messaging.InboundEmailHandler {
 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
        String myPlainText= '';
        myPlainText = email.plainTextBody;

        try {
            // Query the related person Account using from email address
            Account relatedAcc = [SELECT Id, PersonEmail FROM Account
                                 WHERE PersonEmail = :email.fromAddress
                                LIMIT 1];

            if(relatedAcc != null) {
                
                // Create the task and attach with realted person Account

                Task newTask = new Task(Description =  myPlainText, Priority = 'Normal', Status = 'Inbound Email',
                    Subject = email.subject, whatId =  relatedAcc.Id);
                insert newTask;    
                System.debug('New Task Object: ' + newTask );  
            } 
        
        } catch (Exception e) {
            
            // Exception created as error log
            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'InboundEmailTaskCreation',
                    nu_dse__Stack_Trace__c = JSON.serialize(email), nu_dse__User_Context__c = UserInfo.getName(),
                    nu_dse__Message__c = e.getMessage());

            insert errLog;
        }
        result.success = true;
        return result;
    }
}