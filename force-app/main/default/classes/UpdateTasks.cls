global class UpdateTasks {

      
    @InvocableMethod(label='Update Task')

    global static List<UpdateTaskResponse> upsertTask(List<UpdateTaskRequest> request ){
        
         Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        
         holidayMap = Holidays.getHolidaysMap(); 
        
         Map<String,id> templateMap = getTemplateMap(); 
        
        List<Task> taskInsertList = new List<task>(); 
        
        for(UpdateTaskRequest tr: request){
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          Task t = new Task(); 
            
          t.id = tr.id; 
           
          t.subject = tr.subject; 
        
          t.ActivityDate = activityDate; 
        
          t.Unique_Identifier__c = tr.uniqueIdentifier;
         
          t.nu_dse__Communication_Template__c = templateMap.get(tr.templateName);
        
          t.nu_dse__Is_System_Task__c = true; 
            
          t.WhatId = tr.parentId;
              
          t.OwnerId = tr.ownerId; 
            
          taskInsertList.add(t); 
            
        }
       
        List<UpdateTaskResponse>  response = new List<UpdateTaskResponse>(); 
        
        
        try{
            
            update taskInsertList ; 
              
            for(task t: taskInsertList){
                UpdateTaskResponse tresponse =  new UpdateTaskResponse();
                tresponse.Id = t.Id; 
                response.add(tresponse);
            }
        }catch(Exception e){
            
            UpdateTaskResponse tresponse =  new UpdateTaskResponse();
            tresponse.error = 'Insert Failed';
            response.add(tresponse);
            System.debug('insert failed');
        }
        
        
        return response; 
    }

    
     global class UpdateTaskRequest {
        
       @InvocableVariable(required=true)
       global String id;
       @InvocableVariable(required=true)
       global String uniqueIdentifier;
       @InvocableVariable
       global id templateId;
       @InvocableVariable//(required=true)
       global String templateName;
       @InvocableVariable(required=true)
       global String subject; 
       @InvocableVariable(required=true) 
       global Date activityDate;
       @InvocableVariable(required=true) 
       global Id parentId; 
       @InvocableVariable
       global String status; 
        @InvocableVariable
       global Id ownerId; 
        


    } 
    
    global class  UpdateTaskResponse{
        
        @InvocableVariable
        global String Id; 
         @InvocableVariable
        global String error; 
        
    }
    
     global static Map<string,id> getTemplateMap(){
        
        Map<string,id> template = new Map<String,id>();
        
        for(nu_dse__Communication_Template__c temp: [select id, name from nu_dse__Communication_Template__c]){
            
            
            template.put(temp.name,temp.id);
        }
        
        return template; 
    }
    
}