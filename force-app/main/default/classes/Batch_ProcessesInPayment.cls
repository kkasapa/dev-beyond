/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for Create payment reminder SMS/Email Tasks. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-08
* @modified       2019-10-31
* @logic           
* @description    This batch will Create payment reminder SMS/Email Tasks.
* @IMPORTANT NOTE 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_ProcessesInPayment implements Database.Batchable<sObject>, Database.Stateful {
    
    // Map of Data mapping Id and list of field mappings
    Map<String, List<nu_dse__Field_mapping__c>> dataMappingAndFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>(); 
    // Set of Data mapping names used for create communication tasks 
    Set<Id> draftPaymentIds = new Set<Id>(); //set of payment Ids for running batch for specific tests
    Set<String> dataMappingNameSet = new Set<String>{'Create_Payments_SMS_Reminders', 'Create_Payments_Email_Reminders'};
    Set<String> paymentFieldsToQuerySet = new Set<String>{'Create_Payment_Reminder_Tasks__c'}; // Set of Payment fields to query
    Set<String> programStatusExclusionSet = new Set<String>();// Set of Program status excludes in payment query
    String whereConditionStr;// Addition where Condition for excute batch 
    Map<Integer, Integer> paddingDaysMap = new Map<Integer, Integer>(); 
    Integer maxPaddingDay;
    
    Id draftRecordTypeId;

    public Batch_ProcessesInPayment(String whereCondition) {
        
        getMappings();
        getPaddingDayConfigurations();
        // Assign addition where condition for task creating payments query
        if(String.isNotBlank(whereCondition) == true) {
        
            whereConditionStr = whereCondition;
        } 
    }

    
    public Batch_ProcessesInPayment(Set<Id> paymentIds) {
        String whereClauseStr;
        getMappings();
        getPaddingDayConfigurations();
        if(paymentIds.isEmpty() == false) {
            draftPaymentIds = paymentIds;
            whereConditionStr = ' Id IN :draftPaymentIds';
        } 
    }

    public void getMappings(){
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
    }

    public List<Deposit_Reminder_Configuration__mdt> getDepositRemidersCMD() {

        List<Deposit_Reminder_Configuration__mdt> depositReminderConfigList = new List<Deposit_Reminder_Configuration__mdt>();

        if (Test.isRunningTest() == true) {
            depositReminderConfigList = new List<Deposit_Reminder_Configuration__mdt>{ 
                                                                        new Deposit_Reminder_Configuration__mdt(
                                                                            MasterLabel = 'Deposit Reminder One', 
                                                                            DeveloperName = 'Deposit_Reminder_One', 
                                                                            Padding_Days__c = 2, 
                                                                            Sequence_number__c = 1)};

        } else {
            depositReminderConfigList = [SELECT Sequence_number__c, Padding_Days__c 
                                                                        FROM Deposit_Reminder_Configuration__mdt
                                                                        WHERE Padding_Days__c > 0
                                                                        ORDER BY Padding_Days__c ASC];

        }
        return depositReminderConfigList;
    }

    public Program_Status_Configuration__mdt getProgramConfigurationsCMD() {

        Program_Status_Configuration__mdt progStatusConfig = new Program_Status_Configuration__mdt();

        if (Test.isRunningTest() == true) {
            progStatusConfig = new Program_Status_Configuration__mdt(
                                        MasterLabel = 'Deposit Reminder Exclusion', 
                                        DeveloperName = 'Deposit_Reminders_Exclusion', 
                                        Excluded_Statuses__c = 'Terminated, Graduated');

        } else {
            progStatusConfig = [SELECT Label, DeveloperName, Excluded_Statuses__c 
                                        FROM Program_Status_Configuration__mdt 
                                        WHERE DeveloperName = 'Deposit_Reminders_Exclusion' LIMIT 1];

        }
        return progStatusConfig;
    }

    public void getPaddingDayConfigurations() {

        maxPaddingDay = 0;
        List<Deposit_Reminder_Configuration__mdt> depositReminderConfigList = getDepositRemidersCMD();

        for(Deposit_Reminder_Configuration__mdt depositReminderConfig : depositReminderConfigList) {
            paddingDaysMap.put(Integer.valueOf(depositReminderConfig.Sequence_number__c), Integer.valueOf(depositReminderConfig.Padding_Days__c));
            maxPaddingDay = Integer.valueOf(depositReminderConfig.Padding_Days__c);
        }
        
        draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        // query Program_Status_Configuration meta data for get excluded program Statuses
        Program_Status_Configuration__mdt programStatusConfig = getProgramConfigurationsCMD();

        if(programStatusConfig != null
            && String.isNotBlank(programStatusConfig.Excluded_Statuses__c)) {
            programStatusExclusionSet = new Set<String>(programStatusConfig.Excluded_Statuses__c.split(',', 0));
        }

        // Assign padding days between payment scheduled date and task activity date
        if(paddingDaysMap.isEmpty() == true) {
            throw new applicationException('Deposit Reminder Configuration metadata record does not have enough information');
        }
    }
    // Query the payments based on the condition and return to the excute method
    public Database.QueryLocator start(Database.BatchableContext BC) {

        //need some index field filter
        //filter on Sch
        String queryStr = 'SELECT Id FROM nu_dse__Payment__c '+
                           'WHERE RecordTypeId = :draftRecordTypeId AND ((Create_Payment_Reminder_Tasks__c = True '+
                           'AND Program_Status__c != :programStatusExclusionSet) OR nu_dse__Transaction_Status__c = \'Cancelled\')';

        if(String.isNotBlank(whereConditionStr) == true
            && whereConditionStr.contains('nu_dse__Schedule_Date__c')) {
            
            queryStr += ' AND ' + whereConditionStr;
        
        } else {
            
            if(String.isNotBlank(whereConditionStr) == true) {
            
                queryStr += ' AND ' + whereConditionStr;
            }
            Date minScheduleDate = system.today().addDays(2);
            Date maxScheduleDate = system.today().addDays(maxPaddingDay + 7);
            
            queryStr += ' AND nu_dse__Schedule_Date__c >= :minScheduleDate AND nu_dse__Schedule_Date__c <= :maxScheduleDate';
        }  
        system.debug('queryStr::'+queryStr);
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> scope) {

        try {
        
            List<Task> tasksToUpsertList = new List<Task>();
            new List<Task>();
            Set<Id> cancelledPaymentIdSet = new Set<Id>();
            List<nu_dse__Error_Log__c> errorLogsToInsertList = new List<nu_dse__Error_Log__c>();
            Set<Id> EmailPaymentIdSet = new Set<Id>();
            Set<Id> SMSPaymentIdSet = new Set<Id>();

            Date minScheduleDate = system.today().addDays(2);
            
            String paymentsQueryFields = '';

            for (String paymentField : paymentFieldsToQuerySet) {

                if(paymentField != 'nu_dse__Transaction_Status__c') {
                    paymentsQueryFields += paymentField + ', ';
                }
            }

            if (String.isNotBlank(paymentsQueryFields)) {

                paymentsQueryFields = paymentsQueryFields.removeEnd(', ');
            
            } else {

                paymentsQueryFields = ' Id ';
            }
            String paymentsQuery = 'SELECT nu_dse__Transaction_Status__c, ' + paymentsQueryFields + ' FROM nu_dse__Payment__c WHERE Id IN :scope AND nu_dse__Schedule_Date__c >= :minScheduleDate';
            System.debug('paymentsQuery--->'+paymentsQuery);
            // Process the payment and create the Payment Reminder - Email and Payment Reminder - SMS tasks
            for (nu_dse__Payment__c paymentRec : Database.query(paymentsQuery)) {
                
                if(paymentRec.nu_dse__Transaction_Status__c != 'Cancelled') {

                    for(Integer sequenceNum : paddingDaysMap.keySet()) {

                        try {

                            if (paymentRec.Create_Payment_Reminder_Tasks__c 
                                && dataMappingAndFieldMappingMap.containsKey('Create_Payments_SMS_Reminders')
                                && SMSPaymentIdSet.contains(paymentRec.Id) == false) {

                                Task paymentSMSReminder = new Task();
                                paymentSMSReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - SMS '+sequenceNum;
                                populateValuesInInstance(paymentSMSReminder, paymentRec, dataMappingAndFieldMappingMap.get('Create_Payments_SMS_Reminders'), paddingDaysMap.get(sequenceNum));
                                if(paymentSMSReminder.activityDate == system.today().addDays(1)) {
                                    SMSPaymentIdSet.add(paymentSMSReminder.whatId);
                                }
                                tasksToUpsertList.add(paymentSMSReminder);
                            }
                            
                            if (paymentRec.Create_Payment_Reminder_Tasks__c 
                                && dataMappingAndFieldMappingMap.containsKey('Create_Payments_Email_Reminders')
                                && EmailPaymentIdSet.contains(paymentRec.Id) == false) {

                                Task paymentEmailReminder = new Task();
                                paymentEmailReminder.Unique_Identifier__c = paymentRec.Id + 'Payment Reminder - Email '+sequenceNum;
                                populateValuesInInstance(paymentEmailReminder, paymentRec, dataMappingAndFieldMappingMap.get('Create_Payments_Email_Reminders'), paddingDaysMap.get(sequenceNum));
                                if(paymentEmailReminder.activityDate == system.today().addDays(1)) {
                                    EmailPaymentIdSet.add(paymentEmailReminder.whatId);
                                }
                                tasksToUpsertList.add(paymentEmailReminder);
                            }

                        } catch(Exception e) {

                            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                                    nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProcessesInPayment.Execute[Payment Iteration]', 
                                    nu_dse__Error_Causing_Record_Id__c = paymentRec.Id);

                            errorLogsToInsertList.add(errorLog);
                        }
                    }
                } else {

                    cancelledPaymentIdSet.add(paymentRec.Id);
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

            if(cancelledPaymentIdSet.isEmpty() == false) {

                List<Task> tasksToDeleteList = [SELECT Id FROM Task 
                                                WHERE whatId IN:cancelledPaymentIdSet AND Status != 'Completed'
                                                    AND nu_dse__Communication_Sent__c != true];
        
                try {
                    delete tasksToDeleteList;
                } catch(exception e) {
                    nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                        nu_dse__User_Context__c = UserInfo.getName(), nu_dse__Class_Method__c = 'Batch_ProcessesInPayment.Execute');
                    errorLogsToInsertList.add(errorLog);
                }
            }
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
    public Task populateValuesInInstance(Task taskRec, nu_dse__Payment__c paymentRec, List<nu_dse__Field_mapping__c> fieldMappingRecords, Integer paddingDays) {

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
                            if(Date.valueOf(targetFieldValue) > system.today().addDays(paddingDays)) {
                                taskRec.put(targetField, Date.valueOf(targetFieldValue).addDays(-paddingDays));
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

                        if(targetField != 'Subject') {
                            taskRec.put(targetField, String.valueOf(targetFieldValue));
                        } else {
                            taskRec.put(targetField, String.valueOf(targetFieldValue) + ' - DAY '+paddingDays);
                        }
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