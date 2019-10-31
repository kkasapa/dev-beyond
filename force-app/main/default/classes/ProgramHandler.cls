/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for ProgramTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Peter Le  <ple@beyondfinance.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-10-21
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ProgramHandler extends TriggerHandler {

    private Map<Id, nu_dse__Program__c> newProgramMap;
    private Map<Id, nu_dse__Program__c> oldProgramMap;

    public ProgramHandler() {
        this.newProgramMap = (Map<Id, nu_dse__Program__c>) Trigger.newMap;
        this.oldProgramMap = (Map<Id, nu_dse__Program__c>) Trigger.oldMap;
    }

    List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>(); //grouptasks to be inserted 
    List<nu_dse__Payment__c> updatePaymentsList = new List<nu_dse__Payment__c>();  // Payments to be updated
    List<nu_dse__Prospect__c> updatedProspectList = new List<nu_dse__Prospect__c>(); // Prospects to be updated
    Map<String, Task> upsertTaskMap = new Map<String, Task>(); // Tasks to be upserted based on unique Identifier
    Set<Id> terminatedProgramIds = new Set<Id>(); // Terminated Program ids for cancelling their Scheduled Payments
    Map<String, Holiday> holidayMap; // map of Holiday name and Its instance
    Map<String, Id> queueMap; // map of Queue Name and Its Id
    Map<String, Id> comuTempNameIdMap; // map of communication Template Name and Its Id
    Set<Id> velocifyProspectIds = new Set<Id>(); // Set of Prosepct Ids send for Velocify
    List<BLP_Bus__e> BLPBUSEvents = new List<BLP_Bus__e>();

    public override void afterInsert() {

        for (nu_dse__Program__c newProgram : (List<nu_dse__Program__c>)Trigger.New) {
            // Create Group Task for Which Program Cross Collateralized are true 
            createCCGroupTask(newProgram, null);    
            // Collect Prospect List for velocify
            collectProspectList(newProgram); 
            // publishing Platform Event BLP Bus for triggering sync with BLP
            createBLP_BusList(newProgram, null);
        }
        upsert groupTaskList nu_dse__Unique_Identifier__c; // Upsert Group Task based on unique Identifier

        if(velocifyProspectIds.isEmpty() == false) {
            //Pushes fields from prospect to velocify based on datamapping record named "Velocifyleads"
            VelocifyLeadHandler.modifyLeads_Async(velocifyProspectIds);
        }

        if (BLPBUSEvents.isEmpty() == false) {
            EventBus.publish(BLPBUSEvents); // publishing the PE for BLP API push
        }
    }

    public override void beforeUpdate() {

        for (nu_dse__Program__c newProgram : (List<nu_dse__Program__c>)Trigger.New) {
            // Update Programs Campaign Disposition and Campaign Updated fields  
            updateProgramCampaign(newProgram, oldProgramMap.get(newProgram.Id));    
        }
    }

    public override void afterUpdate() {
        System.debug('after update');
        for (nu_dse__Program__c newProgram : (List<nu_dse__Program__c>)Trigger.New) {
            // Create Group Task for Which Program Cross Collateralized are true 
            createCCGroupTask(newProgram, oldProgramMap.get(newProgram.Id));   
            // Collect Terminated Program Ids for cancelling their Scheduled Payments and 
            // Create Termination Confirmation Email Task
            collectTerminatedPrograms(newProgram, oldProgramMap.get(newProgram.Id)); 
            // Update Program status as Prospect status for Did not Sell Programs
            updateProspectStatus(newProgram, oldProgramMap.get(newProgram.Id));
            // Create Task or Group Task for Graduated Programs  
            createGraduatedActivity(newProgram, oldProgramMap.get(newProgram.Id));
            // Create Group Task for Programs Status as Termination Pending
            createTermPendingGroupTask(newProgram, oldProgramMap.get(newProgram.Id)); 
            // publishing Platform Event BLP Bus for triggering sync with BLP
            system.debug('blp bus list');
            createBLP_BusList(newProgram, oldProgramMap.get(newProgram.Id));
            // Creating Loan Record based on Interested Status
            createLoan(newProgram, oldProgramMap.get(newProgram.Id));
            //updateLoanApplication(newProgram, oldProgramMap.get(newProgram.Id));

        }
        if(terminatedProgramIds.isEmpty() == false) {
            // Update Scheduled Payments as cancelled for Terminated Programs
            updatePaymentStatus();
        }

        if (BLPBUSEvents.isEmpty() == false) {
            EventBus.publish(BLPBUSEvents);
        }

        upsert groupTaskList nu_dse__Unique_Identifier__c; // Upsert Group Task based on unique Identifier
        upsert upsertTaskMap.values() Unique_Identifier__c; // Upsert Task based on unique Identifier
        update updatedProspectList; // Prospects to be updated 
        update updatePaymentsList; // Payments to be updated
    }

    //filters Programs that are to be synced with BLP
    public void createBLP_BusList(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
        
        system.debug(newProgram.BLP_Member_Type__c);
        if (newProgram.BLP_Member_Type__c =='Club Member' || newProgram.BLP_Member_Type__c == 'Flat Fee')
        {
            system.debug('added');
            BLPBUSEvents.add(new BLP_Bus__e(action__c='create', program_id__c=newProgram.Id));
        }
        if (String.isNotBlank(newProgram.nu_dse__Fee_Template__c) == true 
                && newProgram.Legal_Plan_Included__c == true) {
            //create BLP Bus events and append to scope variable
            if (Trigger.isInsert) {
                BLPBUSEvents.add(new BLP_Bus__e(action__c='create', program_id__c=newProgram.Id));
            } else if (newProgram.nu_dse__Program_Status__c != oldProgram.nu_dse__Program_Status__c) {
                BLPBUSEvents.add(new BLP_Bus__e(action__c='update', program_id__c=newProgram.Id));
            }
        } 
    }
    // Create Group Task for Termination Pending Programs based on Involuntary Termination
    public void createTermPendingGroupTask(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
        
        if(newProgram.nu_dse__Program_Status__c == 'Termination Pending'
            && (Trigger.isInsert
                || (oldProgram.nu_dse__Program_Status__c != newProgram.nu_dse__Program_Status__c
                    || oldProgram.Involuntary_Termination__c != newProgram.Involuntary_Termination__c))) {

            if(queueMap == null) {
                queueMap = PaymentHandler.getQueueMap();
            }
            nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(OwnerId = queueMap.get('Termination_Request_CS'), nu_dse__ActivityDate__c = system.today(), 
                                                                        nu_dse__Related_To__c = newProgram.Id);
            if(newProgram.Involuntary_Termination__c == true) {
                groupTask.nu_dse__Subject__c = 'Termination Request - INVOL';
                groupTask.nu_dse__Unique_Identifier__c = newProgram.Id + 'Termination Request - INVOL';
            } else {
                groupTask.nu_dse__Subject__c = 'Termination Request';
                groupTask.nu_dse__Unique_Identifier__c = newProgram.Id + 'Termination Request';
            }
            groupTaskList.add(groupTask);
        }
    }

    public void collectProspectList(nu_dse__Program__c newProgram) {

        if(newProgram.Velocify_Id__c != null 
            && newProgram.Prospect_Lookup__c != null) {
            velocifyProspectIds.add(newProgram.Prospect_Lookup__c);
        }
    }
    // Create Group Task for Which Program Cross Collateralized are true  
    public void createCCGroupTask(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
        
        if(newProgram.Cross_Collateralized__c == true
            && (Trigger.isInsert
                || oldProgram.Cross_Collateralized__c != newProgram.Cross_Collateralized__c)) {
            
            nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(OwnerId = newProgram.Salesperson_ID__c, Subject_Pick_List__c = 'Cross Collateralized',
                                                                        nu_dse__ActivityDate__c = system.today().addDays(14), nu_dse__Related_To__c = newProgram.Id,
                                                                        nu_dse__Unique_Identifier__c = newProgram.Id + 'Cross Collateralized');
            groupTaskList.add(groupTask);
        }
    }
    // Collect Terminated Program Ids for cancelling their Scheduled Payments and
    // Create Termination Confirmation Email Task 
    public void collectTerminatedPrograms(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {

        if(newProgram.nu_dse__Program_Status__c == 'Terminated'
            && (Trigger.isInsert
                || oldProgram.nu_dse__Program_Status__c != newProgram.nu_dse__Program_Status__c)) {
            terminatedProgramIds.add(newProgram.Id);

            if(holidayMap == null) {
                holidayMap = Holidays.getHolidaysMap();
            }
            Date activityDate = Holidays.getNextWorkingDay(holidayMap, system.today());
            Task newTask = new Task(ActivityDate = activityDate, Subject = 'Termination Confirmation Email', Unique_Identifier__c = newProgram.Id + 'Termination Confirmation Email', 
                                    nu_dse__Is_System_Task__c = true, WhatId = newProgram.Id);
            upsertTaskMap.put(newTask.Unique_Identifier__c, newTask);
        }
    } 
    // Update Program status as Prospect status for Did not Sell Programs
    public void updateProspectStatus(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
        
        if(newProgram.nu_dse__Program_Status__c == 'Did Not Sell'
            && newProgram.Prospect_ID__c != null
            && (Trigger.isInsert
                || oldProgram.nu_dse__Program_Status__c != newProgram.nu_dse__Program_Status__c)) {
        
            nu_dse__Prospect__c updateProspect = new nu_dse__Prospect__c(Id = Id.valueof(newProgram.Prospect_ID__c), 
                                                 nu_dse__Prospect_Status__c = 'Did Not Sell');
            updatedProspectList.add(updateProspect);
        }
    }
    // Create Task for Graduated Programs with Email address
    // Create Group Task for Graduated Programs without Email address
    public void createGraduatedActivity(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
        
        if(newProgram.nu_dse__Program_Status__c == 'Graduated'
            && (Trigger.isInsert
                || oldProgram.nu_dse__Program_Status__c != newProgram.nu_dse__Program_Status__c)) {
            
            if(comuTempNameIdMap == null) {
                comuTempNameIdMap = PaymentHandler.getTemplateMap();
            }
            if(queueMap == null) {
                queueMap = PaymentHandler.getQueueMap();
            }
            if(holidayMap == null) {
                holidayMap = Holidays.getHolidaysMap();
            }
            Date activityDate = Holidays.getNextWorkingDay(holidayMap, system.today());
            system.debug('String.valueOf(newProgram.OwnerId)::'+String.valueOf(newProgram.OwnerId));
            system.debug('String.valueOf(newProgram.OwnerId)::::'+User.sObjectType.getDescribe().getKeyPrefix());
            if(newProgram.Email_Address__c != null
                && String.valueOf(newProgram.OwnerId).startswith(User.sObjectType.getDescribe().getKeyPrefix())) {
                Task newTask = new Task(ActivityDate = activityDate, Subject = 'Email Grad Package', 
                                        Unique_Identifier__c = newProgram.Id + 'Email Grad Package', 
                                        nu_dse__Communication_Template__c = comuTempNameIdMap.get('Email Grad Package'), 
                                        nu_dse__Is_System_Task__c = true, WhatId = newProgram.Id);
                upsertTaskMap.put(newTask.Unique_Identifier__c, newTask);
            } else {
                nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(nu_dse__subject__c = 'Mail Grad Package', 
                                                    nu_dse__Unique_Identifier__c = newProgram.Id + 'Mail Grad Package', 
                                                    nu_dse__ActivityDate__c = activityDate, nu_dse__Related_To__c = newProgram.Id, 
                                                    ownerId = queueMap.get('Mail_Queue'));
                groupTaskList.add(groupTask);    
            }
        }
    }
    // Update Scheduled Payments status as cancelled for Terminated Programs
    public void updatePaymentStatus() {
        
        for(nu_dse__Payment__c payment : [SELECT Id, nu_dse__Transaction_Status__c FROM nu_dse__Payment__c
                                          WHERE nu_dse__Program__c IN :terminatedProgramIds 
                                          AND nu_dse__Transaction_Status__c = 'Scheduled']) {
            payment.nu_dse__Transaction_Status__c = 'Cancelled';
            updatePaymentsList.add(payment);
        }
    } 
    /*
        Update Programs Campaign Disposition and Campaign Updated as true based on 
        NSF Start/Stop, NSF 2 Start/Stop, NSF Final Start/Stop, NSF InSettlement Start/Stop and Sett Auth Start/Stop   
    */
    public void updateProgramCampaign(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram) {
    
        if(newProgram.NSF_Start__c == true
            || newProgram.NSF_Stop__c == true) {
            
            if(newProgram.NSF_Start_Date__c != null 
                && (newProgram.NSF_Start_Date__c != oldProgram.NSF_Start_Date__c)){
                newProgram.Campaign_Disposition__c = 'STARTNSF1';
                newProgram.Campaign_Updated__c = true;
            }
            if(newProgram.NSF_Stop_Date__c != null 
                && (newProgram.NSF_Stop_Date__c != oldProgram.NSF_Stop_Date__c)){
                newProgram.Campaign_Disposition__c = 'STOPNSF1';
                newProgram.Campaign_Updated__c = true;
            }
        }  

        if(newProgram.NSF_2_Start__c == true
            || newProgram.NSF_2_Stop__c == true){
            if(newProgram.NSF_2_Start_Date__c != null 
                && (newProgram.NSF_2_Start_Date__c != oldProgram.NSF_2_Start_Date__c)){
                newProgram.Campaign_Disposition__c = 'STARTNSF2';
                newProgram.Campaign_Updated__c = true;
            }
            if(newProgram.NSF_2_Stop_Date__c != null 
                && (newProgram.NSF_2_Stop_Date__c != oldProgram.NSF_2_Stop_Date__c)){
                newProgram.Campaign_Disposition__c = 'STOPNSF2';
                newProgram.Campaign_Updated__c = true;
            }
        }

        if(newProgram.NSF_Final_Start__c == true
            || newProgram.NSF_Final_Stop__c == true){
            if(newProgram.NSF_Final_Start_Date__c != null
                && (newProgram.NSF_Final_Start_Date__c != oldProgram.NSF_Final_Start_Date__c)){
                newProgram.Campaign_Disposition__c = 'STARTNSF3';
                newProgram.Campaign_Updated__c = true;
            }
            if(newProgram.NSF_Final_Stop_Date__c != null 
                && (newProgram.NSF_Final_Stop_Date__c != oldProgram.NSF_Final_Stop_Date__c)){
                newProgram.Campaign_Disposition__c = 'STOPNSF3';
                newProgram.Campaign_Updated__c = true;
            }
        }

        if(newProgram.NSF_In_Settlement_Start__c == true
            || newProgram.NSF_In_Settlement_Stop__c == true){
            if(newProgram.NSF_In_Settlement_Start_Date__c != null 
                && (newProgram.NSF_In_Settlement_Start_Date__c != oldProgram.NSF_In_Settlement_Start_Date__c)){
                newProgram.Campaign_Disposition__c = 'STARTNSF1SETT';
                newProgram.Campaign_Updated__c = true;
            }
            
            if(newProgram.NSF_In_Settlement_Stop_Date__c != null 
                && (newProgram.NSF_In_Settlement_Stop_Date__c != oldProgram.NSF_In_Settlement_Stop_Date__c)){
                newProgram.Campaign_Disposition__c = 'STOPNSF1SETT';
                newProgram.Campaign_Updated__c = true;
            }
        } 

        if(newProgram.Sett_Auth_Start__c == true
            || newProgram.Sett_Auth_Stop__c == true){
            if(newProgram.Sett_Auth_Start_Date__c != null 
                && (newProgram.Sett_Auth_Start_Date__c != oldProgram.Sett_Auth_Start_Date__c)){
                newProgram.Campaign_Disposition__c = 'STARTSA';
                newProgram.Campaign_Updated__c = true;
            }
            if(newProgram.Sett_Auth_Stop_Date__c != null 
                && (newProgram.Sett_Auth_Stop_Date__c != oldProgram.Sett_Auth_Stop_Date__c)){
                newProgram.Campaign_Disposition__c = 'STOPSA';
                newProgram.Campaign_Updated__c = true;
            }
        }
    }
    
    // Updates Flow Initiated Checkbox if Client No longer Interested in a Loan
    public void updateLoanApplication(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram){
        if(newProgram.Loan_Interest_Status__c != 'Interested' && newProgram.Loan_Interest_Status__c != oldProgram.Loan_Interest_Status__c){
            newProgram.Flow_Initiated__c = false;
            update newProgram;
        }
    }

    // Create New Lender Application Data for Interested Program Enrolled Clients
    // Uses Loan Interest Status = "Interested" to Run
    public void createLoan(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram){
        if (newProgram.Loan_Interest_Status_2__c == 'Skybridge - Interested'){
            if(newProgram.Loan_Interest_Status_2__c != oldProgram.Loan_Interest_Status_2__c){
                // A Check to Make Sure flow runs once, so multiple loan are not created
                if(!newProgram.Flow_Initiated__c){
                    futureFlowCall(newProgram.Id);
                }
            }
        } 
    }
    
    @future(callout=true)
    public static void futureFlowCall(string ProgramId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('ProgramId', ProgramId);
        try {
            Flow.Interview.Create_Loan Create_Loan = new Flow.Interview.Create_Loan(params);
            Create_Loan.start();
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }

}