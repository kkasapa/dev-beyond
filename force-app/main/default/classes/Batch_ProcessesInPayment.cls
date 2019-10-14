/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for Create payment reminder SMS/Email Tasks. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-08
* @modified       2019-10-11
* @logic           
* @description    This batch will Create payment reminder SMS/Email Tasks.
* @IMPORTANT NOTE 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_ProcessesInPayment implements Database.Batchable<sObject>, Database.Stateful {
    
    // Map of Data mapping Id and list of field mappings
    Map<String, List<nu_dse__Field_mapping__c>> dataMappingAndFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>(); 
    // Set of Data mapping names used for create communication tasks 
    Set<String> dataMappingNameSet = new Set<String>{'Create_Payments_SMS_Reminders', 'Create_Payments_Email_Reminders'};
    Set<String> paymentFieldsToQuerySet = new Set<String>{'Create_Payment_Reminder_Tasks__c'}; // Set of Payment fields to query
    Set<String> programStatusExclusionSet = new Set<String>();// Set of Program status excludes in payment query
    String whereConditionStr;// Addition where Condition for excute batch 
    
    Id draftRecordTypeId;
    public Integer activityPaddingDays;
    
    public Batch_ProcessesInPayment(Integer paddingDays, String whereCondition) {
        
        // Query the data mapping to create dataMappingAndFieldMappingMap
        
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
        }

        draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        // query Program_Status_Configuration meta data for get excluded program Statuses
        Program_Status_Configuration__mdt programStatusConfig = [SELECT Label, DeveloperName, Excluded_Statuses__c 
                                                                        FROM Program_Status_Configuration__mdt 
                                                                        WHERE DeveloperName = 'Deposit_Reminders_Exclusion' LIMIT 1];
        
        if(programStatusConfig != null
            && String.isNotBlank(programStatusConfig.Excluded_Statuses__c)) {
            programStatusExclusionSet = new Set<String>(programStatusConfig.Excluded_Statuses__c.split(',', 0));
        }
        // Assign padding days between payment scheduled date and task activity date
        if(paddingDays != null) {
            
            if(paddingDays < 0) {
                activityPaddingDays = paddingDays;
            } else {
                throw new applicationException('Padding days should be in negative.');
            }
        
        } else {
        
            activityPaddingDays = -3;
        } 
        // Assign addition where condition for task creating payments query
        if(String.isNotBlank(whereCondition) == true) {
        
            whereConditionStr = whereCondition;
        } 
    }
    // Query the payments based on the condition and return to the excute method
    public Database.QueryLocator start(Database.BatchableContext BC) {

        //need some index field filter
        //filter on Sch
        String queryStr = 'SELECT Id FROM nu_dse__Payment__c '+
                           'WHERE RecordTypeId = :draftRecordTypeId AND Create_Payment_Reminder_Tasks__c = True '+
                           'AND Program_Status__c != :programStatusExclusionSet';

        if(String.isNotBlank(whereConditionStr) == true
            && whereConditionStr.contains('nu_dse__Schedule_Date__c')) {
            
            queryStr += ' AND ' + whereConditionStr;
        
        } else {
            
            if(String.isNotBlank(whereConditionStr) == true) {
            
                queryStr += ' AND ' + whereConditionStr;
            }
            Date minScheduleDate = system.today().addDays(2);
            Date maxScheduleDate = system.today().addDays(math.abs(activityPaddingDays) + 7);
            
            queryStr += ' AND nu_dse__Schedule_Date__c >= :minScheduleDate AND nu_dse__Schedule_Date__c <= :maxScheduleDate';
        }  
        system.debug('queryStr::'+queryStr);
        return Database.getQueryLocator(queryStr);
        //RecordTypeId = :draftRecordTypeId AND Create_Payment_Reminder_Tasks__c = True');
    }

    public void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> scope) {

        try {
        
            List<Task> tasksToUpsertList = new List<Task>();
            List<nu_dse__Error_Log__c> errorLogsToInsertList = new List<nu_dse__Error_Log__c>();
            Date minScheduleDate = system.today().addDays(2);
            
            String paymentsQueryFields = '';

            for (String paymentField : paymentFieldsToQuerySet) {

                paymentsQueryFields += paymentField + ', ';
            }

            if (String.isNotBlank(paymentsQueryFields)) {

                paymentsQueryFields = paymentsQueryFields.removeEnd(', ');
            
            } else {

                paymentsQueryFields = ' Id ';
            }
            String paymentsQuery = 'SELECT ' + paymentsQueryFields + ' FROM nu_dse__Payment__c WHERE Id IN :scope AND nu_dse__Schedule_Date__c >= :minScheduleDate';
            System.debug('paymentsQuery--->'+paymentsQuery);
            // Process the payment and create the Payment Reminder - Email and Payment Reminder - SMS tasks
            for (nu_dse__Payment__c paymentRec : Database.query(paymentsQuery)) {
                
                try {

                    if (paymentRec.Create_Payment_Reminder_Tasks__c && dataMappingAndFieldMappingMap.containsKey('Create_Payments_SMS_Reminders')) {

                        Task paymentSMSReminder = new Task();
                        paymentSMSReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - SMS';
                        populateValuesInInstance(paymentSMSReminder, paymentRec, dataMappingAndFieldMappingMap.get('Create_Payments_SMS_Reminders'));
                        tasksToUpsertList.add(paymentSMSReminder);
                    }
                    
                    if (paymentRec.Create_Payment_Reminder_Tasks__c && dataMappingAndFieldMappingMap.containsKey('Create_Payments_Email_Reminders')) {

                        Task paymentEmailReminder = new Task();
                        paymentEmailReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - Email';
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

            List<nu_dse__Payment__c> paymentsToUpdateList = new List<nu_dse__Payment__c>();
            Map<String, nu_dse__Payment__c> payIdReminderMap = new Map<String, nu_dse__Payment__c>();
            
            Integer counter = 0;
            Schema.SObjectField taskExternalIdField = Task.Unique_Identifier__c;
            // Upsert the task based on unique identifier to skip duplicate and update the related payments Create Payment Reminder Tasks field
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
    // Method to create task based on field mapping records
    public Task populateValuesInInstance(Task taskRec, nu_dse__Payment__c paymentRec, List<nu_dse__Field_mapping__c> fieldMappingRecords) {

        if (taskRec != null && fieldMappingRecords != null && fieldMappingRecords.isEmpty() == False) {

            for (nu_dse__Field_mapping__c fieldMappingRec : fieldMappingRecords) {

                String targetField = fieldMappingRec.nu_dse__Target_Field__c;
                String targetFieldDataType = fieldMappingRec.Target_Field_Data_Type__c;
                Object targetFieldValue;
                
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
                            if(Date.valueOf(targetFieldValue) > system.today().addDays(math.abs(activityPaddingDays))) {
                                taskRec.put(targetField, Date.valueOf(targetFieldValue).addDays(activityPaddingDays));
                            } else {
                                taskRec.put(targetField, system.today().addDays(1));
                            } 
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