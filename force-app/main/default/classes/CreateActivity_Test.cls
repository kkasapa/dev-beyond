@isTest
public class CreateActivity_Test {
    
    public static String recordTypeNameEquToClient = 'Client';
    public static String accountSObj = Account.sObjectType.getDescribe().getName();
    
    public testmethod static void test1(){
      
        List<Task> taskList = new List<Task>(); 
        
        Task t = new Task(); 
        t.Subject = 'Testing'; 
        t.ActivityDate = System.date.today(); 
        t.Description = 'Testing'; 
        
        taskLIst.add(t); 
        
        CreateActivity.doPost(taskList);
        
        
        /* On 20-06-2017:
         * Forming the HTTP Request and caling the doGet method
         */ 
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/CreateActivity/Task/t.Id';
        request.httpMethod = 'GET';
        RestContext.request = request;
        String resp = CreateActivity.doGet();
        Test.stopTest();
        
        System.assertEquals('OK', resp);
        
       // CreateActivity.doGet(); 
    }
    
    public testmethod static void test2(){
          
        /* On 20-06-2017:
         * Inserting tasks to Call VoiceBroadCast and SMS through TaskHandler
         */
          
        nu_dse__Processor__c processor = new nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True);
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
                                                                    
        Account accStr = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), 
                                   Phone  = '9845764876', PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', 
                                   PersonMailingCity = 'city', personMailingState = 'AL', personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', 
                                   PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', PersonOtherPostalCode = 'OtherPostalCode', 
                                   RecordTypeId = recordTypeList[0].Id, PersonHomePhone = '7854123652');
        
        insert accStr;
        
        nu_dse__Program__c prgm =  new nu_dse__Program__c (nu_dse__Account__c = accStr.Id, nu_dse__Processor__c = processor.Id, nu_dse__Processor_Status__c = 'No Account');
        
        insert prgm;
        
          
        List<Task> taskList = new List<Task>{new Task(Subject = 'Testing1',ActivityDate = System.date.today(), Description = 'Test', WhatId = prgm.Id),
                                             new Task(Subject = 'Testing2',ActivityDate = System.date.today(), Description = 'Test2', WhatId = prgm.Id)}; 
        
        insert taskList;       
        
        Test.startTest();
        if(taskLIst.isEmpty() == FALSE) {
            
            List<nu_dse__Communication_Template__c> communicationTemplateList = new List<nu_dse__Communication_Template__c>{ 
                                                                                new nu_dse__Communication_Template__c(Name='Test Communication1', nu_dse__Action_Type__c = 'Voice Broadcast', nu_dse__TwiML__c = 'Test Message'),
                                                                                new nu_dse__Communication_Template__c(Name='Test Communication2', nu_dse__Action_Type__c = 'SMS', nu_dse__TwiML__c = 'Test Message')};
            
            insert communicationTemplateList;
                                                                            
            taskList[0].Status = 'Completed';
            taskList[1].Status = 'Completed';
            taskList[0].nu_dse__Communication_Template__c = communicationTemplateList[0].Id;
            taskList[1].nu_dse__Communication_Template__c = communicationTemplateList[1].Id;
            
            update taskList;
            
        }
        
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task];
        
        System.assertEquals(2, tasks.size());
    }
    
}