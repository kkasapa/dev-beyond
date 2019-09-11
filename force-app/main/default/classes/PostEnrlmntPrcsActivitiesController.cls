public with sharing class PostEnrlmntPrcsActivitiesController {
    public PostEnrlmntPrcsActivitiesController() {

    }

    @AuraEnabled
    public static string getPostEnrolmntGroupTasks(){
        
        return JSON.serialize([SELECT Id, Name, Program__c, Program__r.Name,nu_dse__Description__c, CreatedDate, Owner_Name__c,
                                nu_dse__Subject__c, nu_dse__Status__c, nu_dse__ActivityDate__c, OwnerId, CreatedBy.Name 
                                FROM nu_dse__Group_task__c WHERE Owner.Name = 'Post Enrollment Queue' ]);
    }
}