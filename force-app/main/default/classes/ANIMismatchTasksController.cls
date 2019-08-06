public class ANIMismatchTasksController {
    
    public Set<String> phoneNumberSet = new Set<String>();
    public nu_dse__Prospect__c ProspectInstance = new nu_dse__Prospect__c();
    Map<Id, Task> editModeTasksAndIdMap = new Map<Id, Task>();
    public List<Task> ProgramTaskList = new List<Task>();
    
    public List<taskEditableWrapper> taskWrapperList {get; set;}
    
    public ANIMismatchTasksController(ApexPages.StandardController controller) {
        
        taskWrapperList = new List<taskEditableWrapper>();
        List<nu_dse__Prospect__c> ProspectInstanceList = [SELECT Id, Name, nu_dse__Home_Phone__c, nu_dse__Work_Phone__c, nu_dse__Cell_Phone__c
                                                        FROM nu_dse__Prospect__c
                                                        WHERE Id = :(Id)controller.getRecord().Id];
        
        if (ProspectInstanceList != null && ProspectInstanceList.isEmpty() == False) {
            
            ProspectInstance = ProspectInstanceList[0];
        }
        if (ProspectInstance.nu_dse__Home_Phone__c != null) {
            
            phoneNumberSet.add(formatPhoneNumber(ProspectInstance.nu_dse__Home_Phone__c));
        }
        if (ProspectInstance.nu_dse__Work_Phone__c != null) {
            
            phoneNumberSet.add(formatPhoneNumber(ProspectInstance.nu_dse__Work_Phone__c));
        }
        if (ProspectInstance.nu_dse__Cell_Phone__c != null) {
            
            phoneNumberSet.add(formatPhoneNumber(ProspectInstance.nu_dse__Cell_Phone__c));
        }
        queryTasks();
    }
    
    public void queryTasks() {
        
        if (ProspectInstance.Id != null) {
            
            taskWrapperList = new List<taskEditableWrapper>();
            ProgramTaskList = [SELECT Id, Subject, Status, ActivityDate, Five9__Five9ANI__c, Five9ANI_phone_Formatted__c, whatId
                               FROM Task
                               WHERE whatId = :ProspectInstance.Id AND Five9__Five9ANI__c NOT IN :phoneNumberSet and Five9__Five9SessionId__c  != null
                               Limit 10];
            
            for (Task tsk : ProgramTaskList) {
                    
                taskEditableWrapper taskEditableWrapperInst = new taskEditableWrapper();
                taskEditableWrapperInst.programTask = tsk;
                taskEditableWrapperInst.isEditable = False;
                
                if (editModeTasksAndIdMap.containsKey(tsk.Id)) {
                
                    taskEditableWrapperInst.isEditable = True;
                    taskEditableWrapperInst.programTask = editModeTasksAndIdMap.get(tsk.Id);
                }
                taskWrapperList.add(taskEditableWrapperInst);
            }
        }
    }
    
    public void editTaskTable() {
        
        String taskId = ApexPages.currentPage().getParameters().get('taskIdValEdit');
        
        if (taskId != null) {
            
            for (taskEditableWrapper tskIns : taskWrapperList) {
                
                if (tskIns.programTask.Id == taskId) {
                    
                    tskIns.isEditable = True;
                    editModeTasksAndIdMap.put(tskIns.programTask.Id, tskIns.programTask);
                    break;
                }
            }
        }
    }
    
    public void saveTaskInstance() {
        
        String taskId = ApexPages.currentPage().getParameters().get('taskIdValSave');
        
        try{
            
            if (taskId != null) {
                
                for (taskEditableWrapper tskIns : taskWrapperList) {
                    
                    if (tskIns.programTask.Id == taskId) {
                        
                        update tskIns.programTask;
                        tskIns.isEditable = False;
                        editModeTasksAndIdMap.remove(tskIns.programTask.Id);
                        break;
                    }
                }
            }
        } catch(Exception e) {
              
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage() ));
        }
        queryTasks();
    }
    
    public void cancelEditTable() {
        
        String taskId = ApexPages.currentPage().getParameters().get('taskIdValCancel');
        
        if (taskId != null) {
            
            for (taskEditableWrapper tskIns : taskWrapperList) {
                
                if (tskIns.programTask.Id == taskId) {
                    
                    tskIns.isEditable = False;
                    editModeTasksAndIdMap.remove(tskIns.programTask.Id);
                    break;
                }
            }
        }
        queryTasks();
    }
    
    public String formatPhoneNumber(String phoneNumber) {
        
        if (phoneNumber != null) {
            
            String formatedNumber = String.valueOf(phoneNumber).remove('(').remove(')').remove('+').remove('-').deleteWhitespace();
            return formatedNumber;
        }
        return null;
    }
    
    public class taskEditableWrapper {
        
        public Task programTask {get; set;}
        public Boolean isEditable {get; set;}
    }
}