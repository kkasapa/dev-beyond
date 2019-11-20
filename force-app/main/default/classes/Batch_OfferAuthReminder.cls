/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for Create Offer Authorization reminder SMS/Email Tasks. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-11-11
* @modified       2019-11-12
* @logic           
* @description    This batch will Create Offer Authorization reminder SMS/Email Tasks.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_OfferAuthReminder implements Database.Batchable<sObject>, Database.Stateful {
    
    List<Default_Task_Assignments_to_User__mdt> defaultTaskAssignConfigList = new List<Default_Task_Assignments_to_User__mdt>();
    Map<String, Id> communicationTemplateMap = new Map<String, Id>();
    Set<Id> filterOfferIds = new Set<Id>();

    public Batch_OfferAuthReminder() {

        getBasicConfig();
    }

    public Batch_OfferAuthReminder(Set<Id> offerIds) {

        getBasicConfig();

        if(offerIds != null && offerIds.isEmpty() == false) {

            filterOfferIds.addAll(offerIds);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> offerStatusSet = new Set<String>{'03-Offer Approved (Pre-payment setup)'};
        DateTime futurePreApprovedDate = system.today().addDays(-30);
        String queryStr = 'SELECT Id, Client_Authorization_Received__c, nu_dse__First_Payment_Date__c, Accepted_Date__c, nu_dse__Status__c '+
                          'FROM nu_dse__Offer__c '+
                          'WHERE (nu_dse__Status__c IN :offerStatusSet OR (Offer_Pre_Approved_Date__c >= :futurePreApprovedDate '+
                          'AND (Client_Authorization_Received__c = true OR nu_dse__First_Payment_Date__c >= TODAY)))';

        if(filterOfferIds.isEmpty() == false) {
            queryStr += ' AND Id IN :filterOfferIds';
        }
        system.debug('queryStr:::'+queryStr);
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<nu_dse__Offer__c> scope) {

        List<Task> taskToUpsertList = new List<Task>();
        List<Id> authorizedOfferIds = new List<Id>();
        List<Task> taskToDeleteList = new List<Task>();

        for(nu_dse__Offer__c acceptedOffer : scope) {

            if(acceptedOffer.nu_dse__Status__c == '03-Offer Approved (Pre-payment setup)'
                && acceptedOffer.Client_Authorization_Received__c == false
                && acceptedOffer.nu_dse__First_Payment_Date__c > system.today()) {

                Integer daysDiff = acceptedOffer.Accepted_Date__c.daysBetween(system.today());

                if(daysDiff == 0) { 

                    system.debug('defaultTaskAssignConfigList::'+defaultTaskAssignConfigList);

                    Task newSMSTask = new Task(activityDate = system.today(), whatId = acceptedOffer.Id, subject = 'Offer Auth SMS Day '+ daysDiff,
                        Unique_Identifier__c = acceptedOffer.Id + 'Offer Auth SMS Day '+daysDiff, ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                        nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth SMS'));

                    taskToUpsertList.add(newSMSTask);

                    Task newEmailTask = new Task(activityDate = system.today(), whatId = acceptedOffer.Id, subject = 'Offer Auth Email Day '+ daysDiff,
                        Unique_Identifier__c = acceptedOffer.Id+'Offer Auth Email Day '+daysDiff, ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                        nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth Email'));
                    
                    taskToUpsertList.add(newEmailTask);    
                }

                if(daysDiff == 0 || math.mod(daysDiff, 2) == 0) {

                    Task newSMSTask = new Task(activityDate = system.today().addDays(2), whatId = acceptedOffer.Id, subject = 'Offer Auth SMS Day '+ (daysDiff + 2),
                        Unique_Identifier__c = acceptedOffer.Id+'Offer Auth SMS Day '+(daysDiff + 2), ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                        nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth SMS'));

                    taskToUpsertList.add(newSMSTask);

                    Task newEmailTask = new Task(activityDate = system.today().addDays(2), whatId = acceptedOffer.Id, subject = 'Offer Auth Email Day '+ (daysDiff + 2),
                        Unique_Identifier__c = acceptedOffer.Id+'Offer Auth Email Day '+(daysDiff + 2), ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                        nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth Email'));
                    
                    taskToUpsertList.add(newEmailTask);
                }
            } else {
                authorizedOfferIds.add(acceptedOffer.Id);
            }
        }

        if(authorizedOfferIds.isEmpty() == false) {
            
            taskToDeleteList = [SELECT Id FROM Task 
                                WHERE whatId IN :authorizedOfferIds AND Status != 'Completed'
                                    AND Unique_Identifier__c LIKE 'Offer Auth %'];
        }

        delete taskToDeleteList;
        upsert taskToUpsertList;
    }

    public void finish(Database.BatchableContext BC) {

    }

    // Query the Default_Task_Assignments_to_User and Communication templates
    public void getBasicConfig() {
    
        getdefaultTaskAssignUserCMD();

        if(defaultTaskAssignConfigList.isEmpty() == true 
            || defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c == null) {
            throw new applicationException('The default Task Assign User Id not configured properly.');
        }
        system.debug('defaultTaskAssignConfigList::'+defaultTaskAssignConfigList);
        getCommunicationTemplateMap();

        if(communicationTemplateMap.isEmpty() == true 
            || communicationTemplateMap.containskey('Get Offer Auth SMS') == false
            || communicationTemplateMap.containskey('Get Offer Auth Email') == false) {

            throw new applicationException('Offer Auth SMS/Email communication template is not available.');
        }
    }

    // Query the Default_Task_Assignments_to_User meta data 
    public void getdefaultTaskAssignUserCMD() {

        if (Test.isRunningTest() == true) {
            defaultTaskAssignConfigList = new List<Default_Task_Assignments_to_User__mdt>{ 
                                                                        new Default_Task_Assignments_to_User__mdt(
                                                                            MasterLabel = 'Offer Auth SMS/Email', 
                                                                            DeveloperName = 'Offer_Auth_SMS_Email', 
                                                                            Task_Assignement_User_Id__c = userInfo.getUserId())};

        } else {
            defaultTaskAssignConfigList = [SELECT Task_Assignement_User_Id__c
                                            FROM Default_Task_Assignments_to_User__mdt
                                            WHERE DeveloperName = 'Offer_Auth_SMS_Email' LIMIT 1];

        }
    }

    // Query the Communication template list
    public void getCommunicationTemplateMap() {

        for(nu_dse__Communication_Template__c temp: [SELECT Id, Name 
                                                    FROM nu_dse__Communication_Template__c 
                                                    WHERE Name LIKE 'Get Offer Auth%']){
            communicationTemplateMap.put(temp.name,temp.id);
        }
    }

    public class applicationException extends Exception {}
}