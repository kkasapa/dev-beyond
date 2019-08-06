/* Date         : 13-12-2017
 * Description  : To Update the schedule date for all settlement and fee payments
                  Whose Offer Sub Status in Out For Authorization
 */

global class Batch_UpdateOfferPaymentsScheduleDate implements Database.Batchable<sObject>, Queueable {

    //Empty constructor 
    public Batch_UpdateOfferPaymentsScheduleDate() {
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Map<String, Schema.RecordTypeInfo> paymentRecordTypeMap = nu_dse__Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Set<Id> recordTypeIdSet = new Set<Id>();
       /* 
        if(paymentRecordTypeMap.containsKey('Settlement')) {
        
            recordTypeIdSet.add(paymentRecordTypeMap.get('Settlement').getRecordTypeId());
        }
        */
        if(paymentRecordTypeMap.containsKey('Fee')) {
        
            recordTypeIdSet.add(paymentRecordTypeMap.get('Fee').getRecordTypeId());
        }
        
        String queryString = 'SELECT Id, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c WHERE RecordTypeId IN :recordTypeIdSet '  
                           + 'AND nu_dse__Offer__r.Sub_Status__c = \'Out For Authorization\' ' 
                           + 'AND nu_dse__Schedule_Date__c = tomorrow ';
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> paymentList) {
        
        try {
            
            if(paymentList != null && paymentList.isEmpty() == FALSE) {
                
                List<nu_dse__Payment__c> paymentToUpdateList = new List<nu_dse__Payment__c>();
                
                for(nu_dse__Payment__c paymentInstance : paymentList) {
                    
                    nu_dse__Payment__c paymentToUpdate = new nu_dse__Payment__c(Id = paymentInstance.Id);
                    
                    Date paymentDate = paymentInstance.nu_dse__Schedule_Date__c;
                    paymentToUpdate.nu_dse__Schedule_Date__c = paymentDate.addDays(7);
                    
                    paymentToUpdateList.add(paymentToUpdate);
                }
                
                if (paymentToUpdateList.isEmpty() == False) {
                
                    System.enqueueJob(new Batch_UpdateOfferPaymentsScheduleDate(paymentToUpdateList));
                }
            }
        } catch(Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_UpdateOfferPaymentsScheduleDate', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
            insert errorlog;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    
    }  
    
    //global payments list to update
    List<nu_dse__Payment__c> paymentsToUpdateList = new List<nu_dse__payment__c>();
    
    //Constructor for queueable class
    public Batch_UpdateOfferPaymentsScheduleDate(List<nu_dse__Payment__c> paymentsList) {
    
        paymentsToUpdateList = paymentsList;
    }
    
    //Queueable execute method
    public void execute(QueueableContext QC) {
    
        List<nu_dse__Error_Log__c> errorlogList = new List<nu_dse__Error_Log__c>();
        
        system.debug('paymentsToUpdateList-->'+paymentsToUpdateList);
        
        if(paymentsToUpdateList.isEmpty() == FALSE) {
                    
            try {
            
                Database.SaveResult[] paymentToUpdateResultList = Database.update(paymentsToUpdateList, false);
                
                if(paymentToUpdateResultList.isEmpty() == FALSE) {
                
                    integer index = 0;
                    for(Database.SaveResult sr : paymentToUpdateResultList) {
                        
                        if(sr.isSuccess() == False) {
                            
                            String errMsg = '';
                            
                            for(Database.Error err : sr.getErrors()) {
                            
                                errMsg += err.getMessage() + '; ';
                            }
                            
                            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Error_Causing_Record_Id__c = paymentsToUpdateList[index].Id, nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_UpdateOfferPaymentsScheduleDate', nu_dse__Message__c = errMsg);
                            errorlogList.add(errLog);
                        }
                        index++;
                    }
                }
            } catch(Exception e) {
            
                nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_UpdateOfferPaymentsScheduleDate', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
                errorlogList.add(errorlog);
            }
            
            if (errorlogList.isEmpty() == False) {
            
                insert errorlogList;
            }
        }
    }
}