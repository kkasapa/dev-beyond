@isTest
public class ANIMismatchTasksController_Test {

    static testMethod void testANIMismatchTasks() {
        
        List<RecordType> accRectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Client' AND 
                       SObjectType = 'Account' AND isActive = True];

        Account acc = TestRecordCreator.createAccount('Account', accRectypeList[0].Id);
        insert acc;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        insert processor;
        
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
        prospect.nu_dse__Home_Phone__c = '2547856985';
        prospect.nu_dse__Work_Phone__c = '5478596532';
        prospect.nu_dse__Cell_Phone__c = '3652145874';
        insert prospect;
        
        Task taskInstance = TestRecordCreator.createTask(prospect.Id);
        taskInstance.Five9__Five9SessionId__c = '12335kda';
        insert taskInstance;
        
        Test.startTest();
            
            ApexPages.currentPage().getParameters().put('taskIdValEdit', taskInstance.Id);
            
            ApexPages.currentPage().getParameters().put('taskIdValSave', taskInstance.Id);
            
            ApexPages.currentPage().getParameters().put('taskIdValCancel', taskInstance.Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(prospect);
            
            ANIMismatchTasksController animismatch = new ANIMismatchTasksController(sc);
            
            animismatch.editTaskTable();
            
            animismatch.queryTasks();
            
        if(animismatch.taskWrapperList.isEmpty()==FALSE){
             animismatch.taskWrapperList[0].programTask.Five9__Five9ANI__c = '1122334455';
        }
            animismatch.saveTaskInstance();
            
            animismatch.cancelEditTable();
            
        Test.stopTest();  
        
        List<Task> taskList = [SELECT Id, Five9__Five9ANI__c FROM Task WHERE Id =:taskInstance.Id];
        System.assertEquals('1122334455', taskList[0].Five9__Five9ANI__c); 
    }
}