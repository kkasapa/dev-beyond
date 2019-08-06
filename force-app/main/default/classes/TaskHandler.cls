/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for TaskTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2017-05-11
* @modified       2019-06-13
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class TaskHandler extends TriggerHandler{

    private Map<Id, Task> newTaskMap;
    private Map<Id, Task> oldTaskMap;
    
    public TaskHandler() {
        this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
        this.oldTaskMap = (Map<Id, Task>) Trigger.oldMap;
    }
    
    Set<Id> affiliateProspectIds = new Set<Id>(); //Prospect Ids with Affiliate to be copied to UTM_Value
    List<Task> filteredTasks = new List<Task>(); //Tasks to be updated with UTM_Value from prospects affiliate
    Set<Id> instantSMSTaskIds = new Set<Id>(); //Tasks that has Is Instant SMS checked true
    Map<Id, nu_dse__prospect__c> updateProspectMap = new Map<Id, nu_dse__prospect__c>(); // prospects to be updated at end of trigger
    Map<Id, nu_dse__Program__c> updateProgramMap = new Map<Id, nu_dse__Program__c>(); // programs to be updated at end of trigger
    Map<Id, String> prospectIdFive9DNISMap = new Map<Id, String>(); // Map of ProspectId and Five9 DNIS
    List<Task> taskToInsert = new List<Task>(); //tasks to be inserted at the end of trigger
    
    public override void beforeInsert() {
    
        for (Task newTask : (List<Task>)Trigger.New) {
            collectProspectTasks(newTask, null); // collects tasks that are under Prospect and has Five9_Session Id changed to some value
        }
        if(affiliateProspectIds.isEmpty() == false) {
            updateTaskUTMValue(); // update tasks UTM value from Prospect's Affiliate
        }
    }
    
    public override void beforeUpdate() {
    
        for (Task newTask : (List<Task>)Trigger.New) {
            collectProspectTasks(newTask, oldTaskMap.get(newTask.Id));  // collects tasks that are under Prospect and has Five9_Session Id changed to some value
        }
        if(affiliateProspectIds.isEmpty() == false) {
            updateTaskUTMValue(); // update tasks UTM value from Prospect's Affiliate
        }
    }
    
    public override void afterInsert() {
    
        for (Task newTask : (List<Task>)Trigger.New) {
            collectInstantSMSTasks(newTask, null); // collects Tasks that has IsInstant checked true
            collectFive9DNIS(newTask); // collects a Map of Prospect's task with Five9 DNIS 
            updateProspects(newTask); // updates Prospect based on Task's values
            updatePrograms(newTask); // updates Program based on Task's values
        }
        if(instantSMSTaskIds.isEmpty() == false) {
            invokeSendSMS(); // invokes SMS notification sending logic
        }
        if(prospectIdFive9DNISMap.isEmpty() == false) {
            updateProspectDNIS(); // updates Prospect's Affiliate based on Task's Five9 DNIS and Add to Five9 list
        }
        update updateProspectMap.values(); // final update of Prospects
        update updateProgramMap.values(); // final update of Programs
    }
    
    public override void afterUpdate() {
    
        for (Task newTask : (List<Task>)Trigger.New) {
            collectInstantSMSTasks(newTask, oldTaskMap.get(newTask.Id)); // collects Tasks that has IsInstant checked true
        }
        if(instantSMSTaskIds.isEmpty() == false) {
            invokeSendSMS(); // invokes SMS notification sending logic
        }
    }
    
    public void collectProspectTasks(Task newTask, Task oldTask) { // filters Prospect Tasks and Tasks with Five9 Session Id
        // filter for Prospect Tasks and Tasks with not null Five9 SessionId and change
        if(newTask.WhatId != null
           && newTask.Five9__Five9SessionId__c != null
           && (trigger.isInsert 
               || (newTask.WhatId != oldTask.WhatId
                   || (newTask.Five9__Five9SessionId__c != oldTask.Five9__Five9SessionId__c
                       && oldTask.Five9__Five9SessionId__c == null)))) {
            string objName = newTask.WhatId.getSObjectType().getDescribe().getName();
            if(objName =='nu_dse__prospect__c'){ // filtering only for Tasks under Prospect
                affiliateProspectIds.add(newTask.whatId); // collects Prospect Id to query prospects
                filteredTasks.add(newTask);  // collecting filtered tasks for updating UTM Value
            }
        }
    }
    
    public void collectInstantSMSTasks(Task newTask, Task oldTask) { // collecting tasks that has IsInstant checked true
        // filtering tasks with Communication Template and Instant SMS and Completed status
        if(newTask.nu_dse__Communication_Template__c != null
           && newTask.Is_Instant_SMS__c == true
           && (trigger.isInsert 
               || (newTask.Status == 'Completed'
                   && newTask.Status != oldTask.Status))) {
            instantSMSTaskIds.add(newTask.Id); // Collecting task ids for querying Communication template      
        }
    }
    
    public void collectFive9DNIS(Task newTask) { // collecting map of prospect Id and DNIS 
        
        if(newTask.whatId != null
           && String.valueOf(newTask.whatId).startswith(nu_dse__Prospect__c.sObjectType.getDescribe().getKeyPrefix())
           && newTask.Five9__Five9DNIS__c != null
           && newTask.UTM_Value__c == null) {
           prospectIdFive9DNISMap.put(newTask.whatId, newTask.Five9__Five9DNIS__c);
        }
    }
    
    public void updateProspects(Task newTask) {
        // set of Call Disposition(Call results) that are to be removed from Five9 Campaign
        Set<String> removeCallDispoSet = new Set<String>{'Term Lost - Crossed Collateralized', 'Term Lost - No Reason Given', 'Term Lost - Misunderstood Program',
                                                         'Term Lost - Secured', 'Term Lost - Blacklist', 'Term Lost - Unserviceable', 
                                                         'Term Lost - Paying Debt in Full', 'Term Lost - Cancelled CFT', 'Term Lost - Bankruptcy',
                                                         'Term Lost - Adverse credit effects', 'Term Lost - Cant afford payment', 'Term Lost - Medical',
                                                         'Term Lost - NSF - Payment issues', 'Term Lost - Dissatisfied', 'Term Lost - Moral - Ethical concerns',
                                                         'Term Lost - Enrolled with Competitor'};
        // set of Call Disposition(Call results) that are to be removed from Five9 Campaign and updating Prospect STOP SMS as true
        Set<String> removeUnifiedDispoSet = new Set<String>{'03 Disqualified', '07 General Question', '08 Termination Requested', '11 Contact Info Update',
                                                            '16 DO NOT CALL', '08 Not Interested', '09 Spanish Call', '10 CSD Transfer',
                                                            '11 Service Call Handled', '12 Wrong Number', '13 Unsupported Language', '01 Undecided',
                                                            '02 Interested', 'Not Eligible - IAPDA', 'Lead Transferred to LT Lending', 'Lending Tree Failed Transfers'};
        //set of Call Disposition(Call results) that are to be removed from Five9 Campaign and updates prospect
        Set<String> ownershipDispoSet = new Set<String>{'01 Undecided', '02 Interested'};
        
        if(newTask.CallDisposition != null 
            && newTask.whatId != null
            && String.valueOf(newTask.whatId).startswith(nu_dse__Prospect__c.sObjectType.getDescribe().getKeyPrefix())) {
        
            nu_dse__prospect__c updateProspectInst = new nu_dse__prospect__c(Id = newTask.whatId);
            if(updateProspectMap.containskey(newTask.whatId)) {
                updateProspectInst = updateProspectMap.get(newTask.whatId);            
            }
             // Five9 Termination Dispo Remove From Campaigns                                                 
            if(removeCallDispoSet.contains(newTask.CallDisposition)) {
                updateProspectInst.Remove_from_Five9_Campaign__c = true;
            }
            // Five9 Remove from Unified
            if(removeUnifiedDispoSet.contains(newTask.CallDisposition)) {
                updateProspectInst.Remove_from_Five9_Campaign__c = true;
                updateProspectInst.Stop_SMS__c = true;
            }
            // Five9 Based Prospect Ownership Process
            if(ownershipDispoSet.contains(newTask.CallDisposition)) {
                updateProspectInst.Remove_from_Five9_Campaign__c = true;
                updateProspectInst.CustomStop1__c = true;   
                updateProspectInst.FIve9_Owner_ID__c = newTask.ownerId;
                updateProspectInst.Has_Been_Assigned__c = true;  
            }
            // Five9 Based Prospect Ownership Process
            if(newTask.CallDisposition == '08 Not Interested') {
                updateProspectInst.Remove_from_Five9_Campaign__c = true;
                updateProspectInst.CustomStop1__c = true;   
                updateProspectInst.FIve9_Owner_ID__c = newTask.ownerId;
                updateProspectInst.Has_Been_Assigned__c = true;
                updateProspectInst.Not_Interested__c = true;     
            }
            // F9CopyCallValuetoProspect
            if(newTask.Five9__Five9SessionId__c != null) {
                updateProspectInst.F9LastDisposition__c = newTask.CallDisposition; // Copies value from Call Disposition(Call Result) to Prospect's F9LastDisposition
            }
            updateProspectMap.put(updateProspectInst.Id, updateProspectInst);
        }
    }
    
    public void updatePrograms(Task newTask) {
    
        if(newTask.CallDisposition != null 
            && newTask.whatId != null
            && String.valueOf(newTask.whatId).startswith(nu_dse__Program__c.sObjectType.getDescribe().getKeyPrefix())) {
            
            nu_dse__Program__c updateProgramInst = new nu_dse__Program__c(Id = newTask.whatId);
            if(updateProgramMap.containskey(newTask.whatId)) {
                updateProgramInst = updateProgramMap.get(newTask.whatId);            
            }
            // PROGRAM WELCOME CALL COMPLETED - Welcome Call Completed logic is checked true when task created with Call result 14 Welcome Call
            /* Logic added on 7/29/19. Ref Jira ticket SF-56
             * when a task is Created with CallDisposition as 14 Welcome Call, 
             * Five9 session Id is copied to program.
            */
            if(newTask.CallDisposition == '14 Welcome Call') {
            
                updateProgramInst.Five9_Session_Id__c = newTask.Five9__Five9SessionId__c;
                updateProgramInst.Welcome_Call_Complete__c = true;
            }
            // Call Recording Sync to Program V2
            if(newTask.Recording_Link__c != null
                && newTask.S3_Recording_Link__c != null
                && (newTask.CallDisposition == '12 Offer Authorization'
                    || newTask.CallDisposition == 'Offer Verbal Authorization Received')) {
            
                updateProgramInst.Last_Call_Recording__c = newTask.S3_Recording_Link__c;
            }
            if(newTask.Recording_Link__c != null
                && newTask.S3_Recording_Link__c != null
                && (newTask.CallDisposition == '10 NSF Makeup'
                    || newTask.CallDisposition == '13 Payment Authorization')) {
            
                updateProgramInst.Last_Payment_Auth_Call_Recording__c = newTask.S3_Recording_Link__c;
            }
            updateProgramMap.put(updateProgramInst.Id, updateProgramInst);
        }    
    }
    
    public void updateTaskUTMValue() { // updating Task's UTM value from Prospect's Affiliate
        
        Map<Id, String> prospectIdAffiliateMap = new Map<Id, String>();
        for(nu_dse__prospect__c prospect : [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c 
                                            WHERE Id IN :affiliateProspectIds AND nu_dse__Affiliate__c != null]){
            prospectIdAffiliateMap.put(prospect.Id ,prospect.nu_dse__Affiliate__c);
        }
        for(Task newTask : filteredTasks) {
            if(prospectIdAffiliateMap.containskey(newTask.whatId)) {
                newTask.UTM_Value__c = prospectIdAffiliateMap.get(newTask.whatId); // updating Task's UTM value from Prospect's Affiliate
            }
        }
    }
    /*
        The Affiliate and Add to five9 list are updated in Prospect by Data Mapping and Field Mapping
        Source Field as DNIS and Target as Affiliate value, Has Add to five9 list Id in Default Value field
    */
    public void updateProspectDNIS() { // Updating Affiliate in Prospect based on Task's DNIS, 
        
        Map<String, String> DNISAffiliateMap = new Map<String, String>(); // maintaining map of DNIS-> Affiliate
        Map<String, String> DNISFive9IdMap = new Map<String, String>(); // maintaining map of DNIS-> Five9 List Id
        for(nu_dse__Field_mapping__c fieldMap : [SELECT nu_dse__Source_Field__c, nu_dse__Target_Field__c, nu_dse__Default_Value__c
                                                 FROM nu_dse__Field_mapping__c 
                                                 WHERE nu_dse__Source_Field__c IN :prospectIdFive9DNISMap.values() AND nu_dse__Data_Mapping__r.Name = 'TasktoProspect']) {
            DNISAffiliateMap.put(fieldMap.nu_dse__Source_Field__c , fieldMap.nu_dse__Target_Field__c); // constructing Map of DNIS-> Affiliate
            if(fieldMap.nu_dse__Default_Value__c != null) {
                DNISFive9IdMap.put(fieldMap.nu_dse__Source_Field__c , fieldMap.nu_dse__Default_Value__c); // constructing Map of DNIS-> Five9 List Id
            }                                               
        }
        
        for(Id prospectId : prospectIdFive9DNISMap.keyset()) { // Loop itereates over Prospects and updates Affilaite and Add to Five9 List
            
            nu_dse__prospect__c updateProspectInst = new nu_dse__prospect__c(Id = prospectId);
            if(updateProspectMap.containskey(prospectId)) {
                updateProspectInst = updateProspectMap.get(prospectId);            
            }
            updateProspectInst.Five9_Source_DNIS__c = prospectIdFive9DNISMap.get(prospectId);
            if(DNISAffiliateMap.containskey(prospectIdFive9DNISMap.get(prospectId))) {
                updateProspectInst.nu_dse__Affiliate__c = DNISAffiliateMap.get(prospectIdFive9DNISMap.get(prospectId)); // Affiliate assignment based on map of DNIS-> Affiliate
            }
            if(DNISFive9IdMap.containskey(prospectIdFive9DNISMap.get(prospectId))) {
                updateProspectInst.Add_to_f9list_id__c = DNISFive9IdMap.get(prospectIdFive9DNISMap.get(prospectId));  // Add to five 9 list assignment based on map of DNIS-> Five9 List Id
            }
            updateProspectMap.put(updateProspectInst.Id, updateProspectInst); // Map of Prospect for update at the end
        }
    }
    
    public void invokeSendSMS() { // SMS sending logic with help of Communication Template
        
        List<Id> sendSMSTaskIds = new List<Id>();
        for(Task task : [SELECT Id, nu_dse__Communication_Template__c, nu_dse__Communication_Template__r.nu_dse__Action_Type__c
                         FROM Task WHERE Id IN :instantSMSTaskIds AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'SMS']){
            sendSMSTaskIds.add(task.Id);                    
        }
        if(sendSMSTaskIds.isEmpty() == false) {
            sendSMS(sendSMSTaskIds);
        }
    }
    
    @Future(Callout=true)
    public static void sendSMS(List<Id> taskIds){ // Future method to send SMS, invokes callout to Twilio. As callouts can't be in Triggger context.       
        
        Map<Id,String> recIdPhonenumberMap = new Map<id,String>(); 
        Set<Id> programIds = new Set<Id>(); 
        Set<id> prospectIds = new Set<Id>();
        
        List<Task> taskList = [SELECT Id, whatId, nu_dse__Communication_Template__r.nu_dse__TwiML__c, nu_dse__Communication_Template__r.nu_dse__From__c, 
                               nu_dse__Communication_Template__r.nu_dse__SMS_Body__c FROM Task WHERE Id IN :TaskIds];
                               
        for(Task task : taskList){ // filtering Program/Prospect to run different query for getting Phone numbers
            if(String.valueOf(task.whatId).startswith(nu_dse__Program__c.sObjectType.getDescribe().getKeyPrefix())){
                programIds.add(task.whatId); // collecting programIds for query Phones               
            } else if(String.valueOf(task.whatId).startswith(nu_dse__Prospect__c.sObjectType.getDescribe().getKeyPrefix())){
                prospectIds.add(task.whatId); // collecting prospectIds for query Phones           
            } 
        }
        /*
            Iterates the Program recs and gets Phone from PersonHomePhone, PersonMobilePhone or Phone of the phone fields 
        */
        for(nu_dse__Program__c program : [SELECT Id, nu_dse__Account__r.Phone, nu_dse__Account__r.PersonHomePhone, nu_dse__Account__r.PersonMobilePhone 
                                          FROM nu_dse__Program__c WHERE Id IN :programIds]){ 
            if (program.nu_dse__Account__r.Phone != null) {                    
                recIdPhonenumberMap.put(program.Id, program.nu_dse__Account__r.Phone);
            } else if (program.nu_dse__Account__r.PersonHomePhone != null) {
                recIdPhonenumberMap.put(program.Id, program.nu_dse__Account__r.PersonHomePhone);
            } else if (program.nu_dse__Account__r.PersonMobilePhone != null) {
                recIdPhonenumberMap.put(program.Id, program.nu_dse__Account__r.PersonMobilePhone);
            }
        }    
        /*
            Iterates the Program recs and gets Phone from Best_Phone__c, nu_dse__Work_Phone__c, nu_dse__Home_Phone__c, nu_dse__Cell_Phone__c of the phone fields 
        */
        for(nu_dse__Prospect__c prospect : [SELECT Id, nu_dse__Cell_Phone__c, nu_dse__Home_Phone__c, nu_dse__Work_Phone__c, Best_Phone__c 
                                            FROM nu_dse__Prospect__c WHERE Id IN :prospectIds]){
            if (prospect.Best_Phone__c != null) {
                recIdPhonenumberMap.put(prospect.Id, prospect.Best_Phone__c);                
            } else if (prospect.nu_dse__Work_Phone__c != null) {
                recIdPhonenumberMap.put(prospect.Id, prospect.nu_dse__Work_Phone__c);
            } else if (prospect.nu_dse__Home_Phone__c != null) {
                recIdPhonenumberMap.put(prospect.Id, prospect.nu_dse__Home_Phone__c);                
            } else if(prospect.nu_dse__Cell_Phone__c!=null){                
                recIdPhonenumberMap.put(prospect.Id, prospect.nu_dse__Cell_Phone__c);                
            }            
        }
        for(Task task : taskList){ 
            if(recIdPhonenumberMap.containsKey(task.whatId)){ // Invokes Twilio to send SMS notification
                nu_dse.TwilioCommunications.sendSMS(recIdPhonenumberMap.get(task.whatId), task.nu_dse__Communication_Template__r.nu_dse__SMS_Body__c);
            }    
        }
    }
}