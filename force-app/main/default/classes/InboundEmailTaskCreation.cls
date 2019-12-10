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

            Id relatedAccId, defaultAccId;
            // Query the related person Account using from email address
            List<Account> relatedAccList = [SELECT Id, PersonEmail FROM Account
                                        WHERE PersonEmail = :email.fromAddress OR LastName = 'Email Task Default Account' 
                                        LIMIT 2];

            for (Account acc: relatedAccList) {

                if(acc.PersonEmail == email.fromAddress) {
                    relatedAccId = acc.Id;
                } else {
                    defaultAccId = acc.Id;
                }
            }
            if(relatedAccList.isEmpty() == false) {
                
                // Create the task and attach with realted person Account

                Task newTask = new Task(Description =  myPlainText, Priority = 'Normal', Status = 'Inbound Email',
                    Subject = email.subject);
                newTask.whatId =  relatedAccId != null ? relatedAccId : defaultAccId;
                insert newTask;    
                System.debug('New Task Object: ' + newTask );  
            
            } else {

                throw new CustomException('Email Task Default Account is not available. Please create Account with Last name as Email Task Default Account.');
            }
            result.success = true;

        } catch (Exception e) {
            
            // Exception created as error log
            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'InboundEmailTaskCreation',
                    nu_dse__Stack_Trace__c = JSON.serialize(email), nu_dse__User_Context__c = UserInfo.getName(),
                    nu_dse__Message__c = e.getMessage());

            insert errLog;
            result.success = false;
        }
        
        return result;
    }
}