public with sharing class Batch_OfferAuthReminder implements Database.Batchable<sObject>, Database.Stateful {
    
    static List<Default_Task_Assignments_to_User__mdt> defaultTaskAssignConfigList = new List<Default_Task_Assignments_to_User__mdt>();
    static Map<String, Id> communicationTemplateMap = new Map<String, Id>();
    public Batch_OfferAuthReminder() {

        getdefaultTaskAssignUserCMD();

        if(defaultTaskAssignConfigList.isEmpty() == true 
            || defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c == null) {
            throw new applicationException('The default Task Assign User Id not configured properly.');
        }

        getCommunicationTemplateMap();

        if(communicationTemplateMap.isEmpty() == false 
            && communicationTemplateMap.containskey('Get Offer Auth SMS') == true
            && communicationTemplateMap.containskey('Get Offer Auth Email') == true) {

            throw new applicationException('Offer Auth SMS/Email communication template is not available.');
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String queryStr = 'SELECT Id, Accepted_Date__c FROM nu_dse__Offer__c '+
                          'WHERE nu_dse__Program_Status__c == \'03-Offer Approved (Pre-payment setup)\' AND '+
                          'Verbal_Authorization_Received__c == true AND nu_dse__First_Payment_Date__c < TODAY';
        
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<nu_dse__Offer__c> scope) {

        List<Task> taskToUpsertList = new List<Task>();

        for(nu_dse__Offer__c acceptedOffer : scope) {

            Integer daysDiff = acceptedOffer.Accepted_Date__c.daysBetween(system.today());

            if(daysDiff == 0 || math.mod(daysDiff, 2) == 0) {

                Task newSMSTask = new Task(activityDate = system.today(), whatId = acceptedOffer.Id, subject = 'Offer Auth SMS Day '+ daysDiff,
                    Unique_Identifier__c = acceptedOffer.Id+'Offer Auth SMS Day '+daysDiff, ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                    nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth SMS'));

                taskToUpsertList.add(newSMSTask);

                Task newEmailTask = new Task(activityDate = system.today(), whatId = acceptedOffer.Id, subject = 'Offer Auth Email Day '+ daysDiff,
                    Unique_Identifier__c = acceptedOffer.Id+'Offer Auth Email Day '+daysDiff, ownerId = defaultTaskAssignConfigList[0].Task_Assignement_User_Id__c,
                    nu_dse__Communication_Template__c = communicationTemplateMap.get('Get Offer Auth Email'));
                
                taskToUpsertList.add(newEmailTask);
            }
        }

        upsert taskToUpsertList;
    }

    public void finish(Database.BatchableContext BC) {

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
