global with sharing class StickyNotesController {
    
    @RemoteAction
    global static List<Notes> getNotes(Id whatId) {
        List<Task> taskList = [SELECT Id, Subject, Description, ActivityDate FROM Task WHERE WhatId = :whatId AND  nu_dse__Is_Sticky_Note__c = true ORDER BY CreatedDate LIMIT 4];
        
        List<Notes> noteList = new List<Notes>();
        
        for(Task task : taskList) {
            noteList.add(new Notes(task));
        }
        
        return noteList;
    }
    
    @RemoteAction
    global static void deleteNote(Id recordId) {
        Task deleteTask = new Task(Id = recordId);
        delete deleteTask;
    }
    
    global class Notes {
        public String subject;
        public Id recordId;
        public String description;
        public Date activityDate;
        
        global Notes(Task task) {
            this.subject = task.Subject;
            this.recordId = task.Id;
            this.description = task.Description;
            this.activityDate = task.ActivityDate;
        }
    }
}