@isTest
public class DeleteTask_Test {

    @testsetup
    public static void data(){
        
         nu_dse__Program__c program = new nu_dse__Program__c(); 
        
         
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
       nu_dse__Communication_Template__c Comtemplate = new nu_dse__Communication_Template__c(); 
        Comtemplate.name = 'Testing';
        
        insert Comtemplate; 
    }
    
    
    public testmethod static void testUpdateTasks(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
         
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
       nu_dse__Communication_Template__c Comtemplate = new nu_dse__Communication_Template__c(); 
        Comtemplate.name = 'Testing';
        
        insert Comtemplate; 
        
        Task taskObj = new Task();
        taskObj.Status = 'Completed';
        taskObj.nu_dse__Communication_Template__c = template.Id;
        taskObj.Unique_Identifier__c = '1122';
        taskObj.WhatId = program.id;
        taskObj.subject = 'Test';
        taskObj.ActivityDate = System.today();
        insert taskObj;
        
        List<DeleteTasks.DeleteTaskRequest> deleteRequestList = new List<DeleteTasks.DeleteTaskRequest>();
        
        DeleteTasks.DeleteTaskRequest deleterequest = new  DeleteTasks.DeleteTaskRequest(); 
        
        deleterequest.uniqueIdentifier = taskObj.Unique_Identifier__c; 
        
        
        deleteRequestList.add(deleterequest);
        
        DeleteTasks.DeleteTasks(deleteRequestList);
        
    }
}