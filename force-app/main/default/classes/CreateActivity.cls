@RestResource(urlMapping='/CreateActivity/Task/*')
global class CreateActivity {

    
    //@HTTPPOST
    
    global static void doPost(List<Task> taskList){
        
         
        try{
            
            upsert taskLIst ; 
            
        }catch(Exception e){
            
        }
        
    }
    
        @HTTPGet
    
    global static String doGet(){
        
        RestRequest req = RestContext.request;
        String res = '';
        
        String[] types = new String[]{'Activity'};
        
      
        Task t = new task(); 
        
        t.Subject = req.params.get('subject');
        t.OwnerId = req.params.get('Owner') !=null && req.params.get('Owner').startswith('005') ? req.params.get('Owner') : System.UserInfo.getUserId() ;
        t.ActivityDate = req.params.get('ActivityDate'.tolowerCase()) !=null ? Date.valueOf(req.params.get('ActivityDate'.tolowerCase())) : System.date.today();
        //t.email = req.params.get('Email'.toLowerCase());
        t.WhatId =  req.params.get('whatid') !=null && req.params.get('whatid') !='' ? req.params.get('whatid') : null;
        t.Status = req.params.get('Status'.tolowerCase()) !=null ? req.params.get('Status'.tolowerCase()) : 'Not Started' ;
        t.CallDurationInSeconds = req.params.get('CallDurationInSeconds') !=null? Integer.valueOf(req.params.get('CallDurationInSeconds')):0;
        t.Five9__Five9WrapTime__c = req.params.get('five9__five9WrapTime__c'.tolowerCase());
        t.Five9__Five9Agent__c = req.params.get('Five9__Five9Agent__c'.toLowerCase());
        t.Five9__Five9AgentExtension__c = req.params.get('Five9__Five9AgentExtension__c'.toLowerCase());
        t.Five9__Five9AgentName__c = req.params.get('Five9__Five9AgentName__c'.toLowerCase());
        t.Five9__Five9ANI__c = req.params.get('Five9__Five9ANI__c'.toLowerCase());
        t.Five9__Five9CallbackCampaignId__c = req.params.get('Five9__Five9CallbackCampaignId__c'.toLowerCase());
        t.Five9__Five9CallbackCampaignName__c = req.params.get('Five9__Five9CallbackCampaignName__c'.toLowerCase());
        t.Five9__Five9CallbackId__c = req.params.get('Five9__Five9CallbackNumber__c'.toLowerCase());
        t.Five9__Five9CallType__c = req.params.get('Five9__Five9CallType__c'.toLowerCase());
        t.Five9__Five9Campaign__c = req.params.get('Five9__Five9Campaign__c'.tolowerCase()); 
        t.Five9__Five9Cost__c = req.params.get('Five9__Five9Cost__c'.tolowerCase()) !=null ? Decimal.valueOf(req.params.get('Five9__Five9Cost__c'.tolowerCase())) : 0.00 ;
        t.Five9__Five9DNIS__c = req.params.get('Five9__Five9DNIS__c'.toLowerCase());
        t.Five9_Offer_ID__c = req.params.get('Five9_Offer_ID__c'.toLowerCase()); 
        t.Five9_Payment_ID__c = req.params.get('Five9_Payment_ID__c'.toLowerCase());
        t.Five9_Program_ID__c = req.params.get('Five9_Program_ID__c'.toLowerCase());
        t.Five9_Prospect_ID__c = req.params.get('Five9__Five9SessionId__c'.toLowerCase()); 
        t.nu_dse__Group_Task__c = req.params.get('nu_dse__Group_Task__c'.toLowerCase());
        t.nu_dse__Is_System_Task__c = req.params.get('nu_dse__Is_System_Task__c'.toLowerCase()) !=null ?  Boolean.valueOf( req.params.get('nu_dse__Is_System_Task__c'.toLowerCase())) :false; 
        t.Task_Type__c = req.params.get('Task_Type__c'.toLowerCase()); 
        t.transactionid__c = req.params.get('transactionid__c'.toLowerCase()); 
        t.Unique_Identifier__c = req.params.get('Unique_Identifier__c'.toLowerCase());
        t.CallType = req.params.get('CallType'.toLowerCase());
        t.Five9__Five9CallType__c  = req.params.get('Five9__Five9CallType__c'.toLowerCase());
        t.Five_9_Time_Stamp_Start__c = req.params.get('Five_9_Time_Stamp_Start__c'.toLowerCase()) !=null &&  req.params.get('Five_9_Time_Stamp_Start__c'.toLowerCase()) !='' ? req.params.get('Five_9_Time_Stamp_Start__c'.toLowerCase()) : null;
        t.Five_9_Time_Stamp_End__c  = req.params.get('Five_9_Time_Stamp_End__c'.toLowerCase()) !=null &&  req.params.get('Five_9_Time_Stamp_End__c'.toLowerCase()) !='' ? req.params.get('Five_9_Time_Stamp_End__c'.toLowerCase()) : null;
        
     
            
        try{
            
           insert t; 
            
           res = 'OK'; 
          
            
        }catch(Exception e){
            
           
           res = 'Error: '+ e.getMessage();
            
        }
        
        return res; 
    }
    
  
    
    
}