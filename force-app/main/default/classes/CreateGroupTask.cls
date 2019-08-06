global class CreateGroupTask {

 /*   
    global static List<Response> invoke(List<Request> req){
     
         
         Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        
         holidayMap = Holidays.getHolidaysMap(); 
         
         Map<String,id> templateMap = getTemplateMap(); 
        
        List<nu_dse__Group_Task__c> taskInsertList = new List<nu_dse__Group_Task__c>(); 
        
        for(Request tr: req){
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          Task t = new Task(); 
        
          t.subject = tr.subject; 
        
          t.ActivityDate = activityDate; 
        
          t.Unique_Identifier__c = tr.uniqueIdentifier;
         
          t.nu_dse__Communication_Template__c = templateMap.get(tr.templateName);
        
            
          t.WhatId = tr.parentId;
              
          taskInsertList.add(t); 
            
        }
       
        List<CreateTaskResponse>  response = new List<CreateTaskResponse>(); 
        
        
        try{
            
            insert taskInsertList ; 
              
            for(task t: taskInsertList){
                CreateTaskResponse tresponse =  new CreateTaskResponse();
                tresponse.Id = t.Id; 
                response.add(tresponse);
            }
        }catch(Exception e){
            
            CreateTaskResponse tresponse =  new CreateTaskResponse();
            tresponse.error = 'Insert Failed';
            response.add(tresponse);
            System.debug('insert failed');
        }
        
        
        
        
        return null; 
    }
     global class Request{
         
       @InvocableVariable(required=true)
       global String uniqueIdentifier;
       @InvocableVariable
       global String templateName;
       @InvocableVariable(required=true)
       global String subject; 
       @InvocableVariable(required=true) 
       global Date activityDate;
       @InvocableVariable(required=true) 
       global Id parentId; 
       @InvocableVariable
       global String status; 
     }
    
     global class Response{
         
        @InvocableVariable
        global String Id; 
        
        @InvocableVariable
        global String error; 
     }
    */
}