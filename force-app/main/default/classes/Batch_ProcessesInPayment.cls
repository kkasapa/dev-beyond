public with sharing class Batch_ProcessesInPayment implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<String, List<nu_dse__Field_mapping__c>> dataMappingAndFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>();
    Set<String> dataMappingNameSet = new Set<String>{'Create_Payments_SMS_Reminders', 'Create_Payments_Email_Reminders'};
    Set<String> paymentFieldsToQuerySet = new Set<String>{'Create_Payment_Reminder_Tasks__c'};
    Set<String> programStatusExclusionSet = new Set<String>();
    
    Id draftRecordTypeId;
    public Integer activityPaddingDays;
    
    public Batch_ProcessesInPayment(Integer paddingDays) {

        String query = 'SELECT nu_dse__Data_Mapping__r.External_Id__c, ' + Utility.getQueryFields('nu_dse__Field_mapping__c') +  ' FROM nu_dse__Field_mapping__c ' +
                            ' WHERE nu_dse__Data_Mapping__r.External_Id__c IN :dataMappingNameSet';
        
        for (nu_dse__Field_mapping__c fieldMapping : Database.query(query)) {

            if (dataMappingAndFieldMappingMap.containsKey(fieldMapping.nu_dse__Data_Mapping__r.External_Id__c) == False) {

                dataMappingAndFieldMappingMap.put(fieldMapping.nu_dse__Data_Mapping__r.External_Id__c, new List<nu_dse__Field_mapping__c>());   
            }
            dataMappingAndFieldMappingMap.get(fieldMapping.nu_dse__Data_Mapping__r.External_Id__c).add(fieldMapping);
            
            if (String.isNotBlank(fieldMapping.nu_dse__Source_Field__c)) {

                paymentFieldsToQuerySet.add(fieldMapping.nu_dse__Source_Field__c);
            }
            system.debug('dataMappingAndFieldMappingMap::'+dataMappingAndFieldMappingMap);
        }

        draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        for (Program_Status_Exclusion__mdt programStatus : [SELECT Label FROM Program_Status_Exclusion__mdt]) {
        
            programStatusExclusionSet.add(programStatus.Label);
        }
        
        if(paddingDays != null) {
        
            activityPaddingDays = paddingDays;
        
        } else {
        
            activityPaddingDays = -2;
        } 
        system.debug('activityPaddingDays::::'+activityPaddingDays);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        //need some index field filter
        return Database.getQueryLocator('SELECT Id FROM nu_dse__Payment__c WHERE RecordTypeId = :draftRecordTypeId AND Create_Payment_Reminder_Tasks__c = True AND Program_Status__c != :programStatusExclusionSet');
        //RecordTypeId = :draftRecordTypeId AND Create_Payment_Reminder_Tasks__c = True');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        try {
        
            List<Task> tasksToUpsertList = new List<Task>();
            List<nu_dse__Error_Log__c> errorLogsToInsertList = new List<nu_dse__Error_Log__c>();
            
            Map<Id, nu_dse__Payment__c> paymentMap = new Map<Id, nu_dse__Payment__c>((List<nu_dse__Payment__c>)scope);
            Set<Id> paymentIdSet = new Set<Id>(paymentMap.keySet());
            //paymentMap.clear();
            system.debug('activityPaddingDays::::'+activityPaddingDays);

            String paymentsQueryFields = '';

            for (String paymentField : paymentFieldsToQuerySet) {

                paymentsQueryFields += paymentField + ', ';
            }

            if (String.isNotBlank(paymentsQueryFields)) {

                paymentsQueryFields = paymentsQueryFields.removeEnd(', ');
            
            } else {

                paymentsQueryFields = ' Id ';
            }
            system.debug('paymentIdSet::'+paymentIdSet);
            String paymentsQuery = 'SELECT ' + paymentsQueryFields + ' FROM nu_dse__Payment__c WHERE Id IN :paymentIdSet';
            
            System.debug('paymentsQuery--->'+paymentsQuery);
            
            for (nu_dse__Payment__c paymentRec : Database.query(paymentsQuery)) {
                
                system.debug('paymentRecTest::::'+paymentRec);
                try {

                    if (paymentRec.Create_Payment_Reminder_Tasks__c && dataMappingAndFieldMappingMap.containsKey('Create_Payments_SMS_Reminders')) {

                        Task paymentSMSReminder = new Task();
                        paymentSMSReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - SMS';
                        system.debug('paymentRecSMS::::'+paymentRec);
                        populateValuesInInstance(paymentSMSReminder, paymentRec, dataMappingAndFieldMappingMap.get('Create_Payments_SMS_Reminders'));
                        tasksToUpsertList.add(paymentSMSReminder);
                    }
                    
                    if (paymentRec.Create_Payment_Reminder_Tasks__c && dataMappingAndFieldMappingMap.containsKey('Create_Payments_Email_Reminders')) {

                        Task paymentEmailReminder = new Task();
                        paymentEmailReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - Email';
                        system.debug('paymentRec::'+paymentRec);
                        populateValuesInInstance(paymentEmailReminder, paymentRec, dataMappingAndFieldMappingMap.get('Create_Payments_Email_Reminders'));
                        tasksToUpsertList.add(paymentEmailReminder);
                    }

                } catch(Exception e) {

                    nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                            nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProcessesInPayment.Execute[Payment Iteration]', 
                            nu_dse__Error_Causing_Record_Id__c = paymentRec.Id);

                    errorLogsToInsertList.add(errorLog);
                }
            }
            paymentIdSet.clear();

            List<nu_dse__Payment__c> paymentsToUpdateList = new List<nu_dse__Payment__c>();
            Map<String, nu_dse__Payment__c> payIdReminderMap = new Map<String, nu_dse__Payment__c>();
            
            Integer counter = 0;
            Schema.SObjectField taskExternalIdField = Task.Unique_Identifier__c;

            for (Database.UpsertResult upsertResult : Database.upsert(tasksToUpsertList, taskExternalIdField, False)) {

                String paymentId = tasksToUpsertList[counter].whatId;
                
                nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c();
                errorLog.nu_dse__User_Context__c = UserInfo.getName();
                errorLog.nu_dse__Class_Method__c = 'Batch_ProcessesInPayment.Execute[Task DML]';
                errorLog.nu_dse__Error_Causing_Record_Id__c = paymentId;

                if (upsertResult.isSuccess() == False) {

                    String errorMsg = '';

                    for (Database.Error errorMessage : upsertResult.getErrors()) {

                        errorMsg += errorMessage.getMessage();
                    }
                    
                    errorLog.nu_dse__Message__c = errorMsg;
                    errorLogsToInsertList.add(errorLog);
                    
                    payIdReminderMap.put(paymentId, new nu_dse__Payment__c(Id = paymentId, Create_Payment_Reminder_Tasks__c = true));
                    
                } else {
                    
                    if(payIdReminderMap.containskey(paymentId) == false) {
                        
                        payIdReminderMap.put(paymentId, new nu_dse__Payment__c(Id = paymentId, Create_Payment_Reminder_Tasks__c = False));
                        
                    }  
                }
                counter++;
            }
            
            update payIdReminderMap.values();
            insert errorLogsToInsertList;

            /*List<sObject> sobjectsToUpdateList = new List<sObject>();
            
            for (nu_dse__Error_Log__c errLog : errorLogsToInsertList) {

                if (errorLog.nu_dse__Error_Causing_Record_Id__c != null) {
                        
                    String objectName = Id.valueOf(errorLog.nu_dse__Error_Causing_Record_Id__c).getSObjectType().getDescribe().getName();
                    SObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
                    sObj.put('Id', Id.valueOf(errorLog.nu_dse__Error_Causing_Record_Id__c));
                    sObj.put('nu_dse__Processor_Error__c', errorLog.Id);
                    sobjectsToUpdateList.add(sObj);
                }
            }

            update sobjectsToUpdateList;*/

        } catch(Exception e) {

            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                    nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProcessesInPayment.Execute');
            
            insert errorLog;
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    public Task populateValuesInInstance(Task taskRec, nu_dse__Payment__c paymentRec, List<nu_dse__Field_mapping__c> fieldMappingRecords) {

        if (taskRec != null && fieldMappingRecords != null && fieldMappingRecords.isEmpty() == False) {

            for (nu_dse__Field_mapping__c fieldMappingRec : fieldMappingRecords) {

                String targetField = fieldMappingRec.nu_dse__Target_Field__c;
                String targetFieldDataType = fieldMappingRec.Target_Field_Data_Type__c;
                Object targetFieldValue;
                
                system.debug('activityPaddingDays::'+activityPaddingDays);
                
                if (fieldMappingRec.nu_dse__setDefaultValue__c) {  

                    targetFieldValue = fieldMappingRec.nu_dse__Default_Value__c;
                
                } else if (paymentRec != null && String.isNotBlank(fieldMappingRec.nu_dse__Source_Field__c)) {

                    targetFieldValue = paymentRec.get(fieldMappingRec.nu_dse__Source_Field__c);
                }

                if (targetFieldValue != null) {
                
                    if (targetFieldDataType == 'Id') {

                        taskRec.put(targetField, Id.valueOf(String.valueOf(targetFieldValue)));

                    } else if (targetFieldDataType == 'Date') {
                        
                        if(targetField != 'ActivityDate') {
                        
                            taskRec.put(targetField, Date.valueOf(targetFieldValue));
                        
                        } else {
                        
                            taskRec.put(targetField, Date.valueOf(targetFieldValue).addDays(activityPaddingDays));
                        } 

                    } else if (targetFieldDataType == 'DateTime') {

                        taskRec.put(targetField, DateTime.valueOf(targetFieldValue));

                    } else if (targetFieldDataType == 'Decimal') {

                        taskRec.put(targetField, Decimal.valueOf(String.valueOf(targetFieldValue)));

                    } else if (targetFieldDataType == 'Boolean') {

                        taskRec.put(targetField, Boolean.valueOf(targetFieldValue));

                    } else {

                        taskRec.put(targetField, String.valueOf(targetFieldValue));
                    } 

                    if (fieldMappingRec.nu_dse__Is_Required__c && taskRec.get(fieldMappingRec.nu_dse__Target_Field__c) == null) {

                        throw new applicationException('The required field ' + fieldMappingRec.nu_dse__Target_Field__c + 'is not populated.');
                    }
                }
            }
        }
        system.debug('taskRec::'+taskRec);
        return taskRec;
    }

    public class applicationException extends Exception {}
}