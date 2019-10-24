/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for PaymentTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-10-23
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class PaymentHandler extends TriggerHandler {

    private Map<Id, nu_dse__Payment__c> newPaymentMap;
    private Map<Id, nu_dse__Payment__c> oldPaymentMap;
    
    List<nu_dse__Payment__c> filteredPayments = new List<nu_dse__Payment__c>();
    Set<Id> paymentSPIds = new Set<Id>();
    Set<Id> SPIdsForTask = new Set<Id>();
    Map<Id, nu_dse__Program__c> programsToBeUpdatedMap = new Map<Id, nu_dse__Program__c>(); // Map of Program that are to be updated
    Map<String, Task> taskToUpsertMap = new Map<String, Task>(); //tasks to be upserted based on unique Identifier
    Set<Id> completedPaymentProgramIds = new Set<Id>(); //Set of program Id which has completed payments
    List<nu_dse__Group_Task__c> groupTaskToInsert = new List<nu_dse__Group_Task__c>();  //grouptasks to be inserted 
    Map<String, Id> queueMap;       //Map of QueueName and QueueName
    List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>(); 
    Set<Id> cancelledPaymentIds = new Set<Id>(); //cancelled payment ids for deleting their tasks
    Map<String, Holiday> holidayMap;
    Map<String, Id> comuTempNameIdMap; // map of communication Template Name and Its Id
    static Map<Id, User> userMailMap = new Map<Id, User>(); //Map of user Id and Email
    List<nu_dse__Payment__c> verbalAuthRecivedPayments= new List<nu_dse__Payment__c>(); //payments with verbal authorization as true
    Set<Id> verbalAuthRecivedPaymentProgramIds = new Set<Id>(); // collect program id of payment which has verbal auth received = true
    Set<Id> draftDateUpdateProgramIds = new Set<Id>();
    Map<Id, Date> updatedIdscheduleDateMap = new Map<Id, Date>(); // Map of Payment Ids and those payments scheduleDate 
    static Set<Id> processedPaymentIds = new Set<Id>(); 

    String MissingCommTemps = '';

    public PaymentHandler() {
        this.newPaymentMap = (Map<Id, nu_dse__Payment__c>) Trigger.newMap;
        this.oldPaymentMap = (Map<Id, nu_dse__Payment__c>) Trigger.oldMap;
    }

    Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
    Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
    
    public override void beforeInsert() {
        
        for (nu_dse__Payment__c newPayment: (List<nu_dse__Payment__c>)Trigger.New) {
            //Process only for Payments on a Program and not Prospect
            if(newPayment.nu_dse__Program__c != null) {
                collectpaymentSPIds(newPayment, null);
                updateNSFDate(newPayment, null);          
            }
        }
        if(paymentSPIds.isEmpty() == false || SPIdsForTask.isEmpty() == false) {
            updateManagerEmail();
        }
    }
    
    public override void beforeUpdate() {
        
        for (nu_dse__Payment__c newPayment: (List<nu_dse__Payment__c>)Trigger.New) {
            //Process only for Payments on a Program and not Prospect
            if(newPayment.nu_dse__Program__c != null) {
                // Collect Salesperson Id to update Manager email
                collectpaymentSPIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // Update NSF date as today for failed payments
                updateNSFDate(newPayment, oldPaymentMap.get(newPayment.Id));   
                // Update Create Payment Reminder Tasks checkbox as true for Schedule date changed Payments.
                updateCreatePaymentReminderTask(newPayment, oldPaymentMap.get(newPayment.Id));       
            }
        }
        if(paymentSPIds.isEmpty() == false || SPIdsForTask.isEmpty() == false) {
            updateManagerEmail();
        }
    }

    public override void afterInsert() {
    
        for (nu_dse__Payment__c newPayment: (List<nu_dse__Payment__c>)Trigger.New) {
            //Process only for Payments on a Program and not Prospect
            if(newPayment.nu_dse__Program__c != null) {
                // If Transaction status is changed to Completed, collecting the paymentId to update the program Phase and progress
                collectCompletedPaymentProgramIds(newPayment, null);
                // collect payment Ids of Verbal Authorization Received payments to Create Group tasks under those payments and assigns it to Payment Authorization Queue
                collectVerbalAuthPaymentIds(newPayment, null);
                // this method adds programs based on Consecutive NSF/Dont Consider fields to a map which is updated programs's NSF Start/Stop at the end
                updateProgramNSFStartStop(newPayment, null); 
                // this method creates Task instance for NSF payments and adds to a map that is to be upserted based Unique Identifier
                instantiateNSFTasks(newPayment, null);
                //Creates a NSF Taskes and assign to Salesperson
                createSalespersonNSFNotifiTask(newPayment, null);
            }
        }
        if(completedPaymentProgramIds.isEmpty() == false) {
            // updates program with Complete % and Phase
            updateProgramPhaseAndProgress(); 
        }
        if(verbalAuthRecivedPaymentProgramIds.isEmpty() == false) {
            //creates a Group tasks for Verbal Authorization and assigns it to Payment Authorization Queue
            createVerbalAuthGroupTask();      
        }                       
        update programsToBeUpdatedMap.values(); // finally updating all programs that are to be modified
        upsert taskToUpsertMap.values() Unique_Identifier__c; // finally upsertng tasks based on Unique_Identifier__c field
        upsert groupTaskToInsert nu_dse__Unique_Identifier__c ; //finally upserting group tasks
        insert errorLogList; // if any error logs were captured during execution it will be inserted for track of failure
    }
    
    public override void afterUpdate() {
        
        for (nu_dse__Payment__c newPayment: (List<nu_dse__Payment__c>)Trigger.New) {
            //Process only for Payments on a Program and not Prospect
            if(newPayment.nu_dse__Program__c != null) {
                // If Transaction status is changed to Completed, collecting the paymentId to update the program Phase and progress
                collectCompletedPaymentProgramIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // collect payment Ids of Cancelled payments to delete the existing tasks under those payments
                collectCancelledPaymentIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // collect payment Ids and schedule date of schedule date updated payments to update the existing tasks activity date under those payments
                collectscheduleDateUpdatedPaymentIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // collect payment Ids of Verbal Authorization Received payments to Create Group tasks under those payments and assigns it to Payment Authorization Queue
                collectVerbalAuthPaymentIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // Collect Program Ids to update next Draft Payment date
                collectUpdateProgramIds(newPayment, oldPaymentMap.get(newPayment.Id));
                // this method adds programs based on Consecutive NSF/Dont Consider fields to a map which is updated programs's NSF Start/Stop at the end
                updateProgramNSFStartStop(newPayment, oldPaymentMap.get(newPayment.Id)); 
                // this method creates Task instance for NSF payments and adds to a map that is to be upserted based Unique Identifier
                instantiateNSFTasks(newPayment, oldPaymentMap.get(newPayment.Id));  
                //Creates a NSF Taskes and assign to Salesperson
                createSalespersonNSFNotifiTask(newPayment, oldPaymentMap.get(newPayment.Id));  
            }
        }   
        if(completedPaymentProgramIds.isEmpty() == false) {
            // updates program with Complete % and Phase
            updateProgramPhaseAndProgress();  
        }
        if(cancelledPaymentIds.isEmpty() == false
            || updatedIdscheduleDateMap.isEmpty() == false) {
            // When a payment was cancelled, We delete the task to skip them from Batch processing it
            // or schedule date changed, We change the Task activity date. 
            PaymentHandler.updateDeleteTask(cancelledPaymentIds, updatedIdscheduleDateMap);
        }
        if(verbalAuthRecivedPaymentProgramIds.isEmpty() == false) {
            //creates a Group tasks for Verbal Authorization and assigns it to Payment Authorization Queue
            createVerbalAuthGroupTask(); 
        }            
        if(draftDateUpdateProgramIds.isEmpty() == false) {
            // Updated Program NextDraftDate as upcoming draft Payment schedule date
            updateProgramNextDraftDate();
        }                
        update programsToBeUpdatedMap.values(); // finally updating all programs that are to be modified
        upsert taskToUpsertMap.values() Unique_Identifier__c; // finally upsertng tasks based on Unique_Identifier__c field
        upsert groupTaskToInsert nu_dse__Unique_Identifier__c ; //finally upserting group tasks
        insert errorLogList; // if any error logs were captured during execution it will be inserted for track of failure
    }
    /* * Filter for "Send Salesperson Cleared Payment Notifiication" process
       * If first draft payment's Transaction Status or Payment Sequence Number changes and Transaction status is Completed/Cleared 
       * and salesperson ID formula is not null, collecting payment instance to assign with salesperson Email.
    */
    public void collectpaymentSPIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        
        //<Resly 05/20> - Remove unnecessary criteria
        if(newPayment.nu_dse__Transaction_Status__c == 'Completed' 
            && newPayment.nu_dse__Payment_Sequence_Number__c == 1 
            && newPayment.RecordTypeId == draftRecordTypeId 
            && newPayment.Salesperson_ID_Formula__c != null
            && (Trigger.isInsert 
                || (oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c 
                    || oldPayment.nu_dse__Payment_Sequence_Number__c  != newPayment.nu_dse__Payment_Sequence_Number__c))) {
                
            paymentSPIds.add(newPayment.Salesperson_ID_Formula__c);
            filteredPayments.add(newPayment); 
        }
    }
    // Update NSF date as Today date for Failed Prospects
    public void updateNSFDate(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
    
        if(newPayment.nu_dse__Transaction_Status__c == 'Failed' 
            && newPayment.RecordTypeId == draftRecordTypeId
            && (Trigger.isInsert 
                || oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c)) {
           
            SPIdsForTask.add(newPayment.Salesperson_ID_Formula__c);
            newPayment.NSF_Date__c = System.today(); // Populating NSF Date if Transaction status is changed to Failed
        }  
    }
    /* conversion of "Send Salesperson Cleared Payment Notifiication" process
      * with completedPaymentSPIds query user's Beyond_Manager_Email__c and mapping it as userId => Beyond Manager Email 
    */   
    public void updateManagerEmail() {
        
        for(User user : [SELECT Id, Beyond_Manager_Email__c, IsActive FROM User WHERE Id IN :paymentSPIds OR Id IN :SPIdsForTask]) {
            userMailMap.put(user.Id, user);
            system.debug('usermailMap::'+userMailMap);
        }
        if(userMailMap.isEmpty() == false) { // with the help of userMailMap, assigning manager email field in payment
            for(nu_dse__Payment__c newPayment : filteredPayments) {
                if(userMailMap.containskey(newPayment.Salesperson_ID_Formula__c)) {
                    newPayment.Manager_Email__c = userMailMap.get(newPayment.Salesperson_ID_Formula__c).Beyond_Manager_Email__c;
                }
            }
        }
    }
    /* Update Create Payment Reminder Tasks checkbox as true for Schedule date changed Payments.
       This checkbox update used for updating activity date based on Padding days in processInPayment batch  */
    public void updateCreatePaymentReminderTask(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        
        if(newPayment.nu_dse__Schedule_date__c != null
            && oldPayment.nu_dse__Schedule_date__c  != newPayment.nu_dse__Schedule_date__c
            && newPayment.nu_dse__Schedule_date__c > system.today().addDays(1)) {
            newPayment.Create_Payment_Reminder_Tasks__c = true;
        }
    }
    /* When a Transaction Status is changed from Completed or To Completed,
        collecting programIds for processing
    */
    public void collectCompletedPaymentProgramIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        if(newPayment.nu_dse__Transaction_Status__c == 'Completed'
            && newPayment.RecordTypeId == draftRecordTypeId
            && (Trigger.isInsert 
                || newPayment.nu_dse__Transaction_Status__c != oldPayment.nu_dse__Transaction_Status__c)){
            completedPaymentProgramIds.add(newPayment.nu_dse__Program__c);   
        }
    }
    //If nu_dse__Transaction_Status__c changes to Cancelled, we collect paymentIds to delete the Tasks under the payment
    public void collectCancelledPaymentIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        if(newPayment.nu_dse__Transaction_Status__c == 'Cancelled'
            && oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c
            && processedPaymentIds.contains(newPayment.Id) == false) {
            cancelledPaymentIds.add(newPayment.Id);
            processedPaymentIds.add(newPayment.Id);
        }
    }
    //If nu_dse__Schedule_date__c updates, we collect paymentIds and Schedule date to update the Tasks activity date under the payment
    public void collectscheduleDateUpdatedPaymentIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        if(newPayment.RecordTypeId == draftRecordTypeId
            && newPayment.nu_dse__Schedule_date__c != null
            && oldPayment.nu_dse__Schedule_date__c != newPayment.nu_dse__Schedule_date__c
            && processedPaymentIds.contains(newPayment.Id) == false) {
            updatedIdscheduleDateMap.put(newPayment.Id, newPayment.nu_dse__Schedule_date__c);
            processedPaymentIds.add(newPayment.Id);
        }
    }
    //If nu_dse__Transaction_Status__c changes to Failed, we collect paymentIds to Create the Group Tasks under the payment
    public void collectVerbalAuthPaymentIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        if(newPayment.nu_dse__Offer__c != null 
            && newPayment.RecordTypeId == settlementRecordTypeId
            && newPayment.Verbal_Authorization_Received__c == true
            && (Trigger.isInsert 
                || oldPayment.Verbal_Authorization_Received__c == false)) {
            verbalAuthRecivedPayments.add(newPayment);
            verbalAuthRecivedPaymentProgramIds.add(newPayment.nu_dse__Program__c);
        }
    }
    // Collect Program Ids to update next Draft Payment date
    public void collectUpdateProgramIds(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        
        if(newPayment.RecordTypeId == draftRecordTypeId 
            && (newPayment.nu_dse__Transaction_Status__c == 'Scheduled'
                || oldPayment.nu_dse__Transaction_Status__c == 'Scheduled') 
            && (oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c 
                    || oldPayment.nu_dse__Schedule_date__c  != newPayment.nu_dse__Schedule_date__c)) {
                
            draftDateUpdateProgramIds.add(newPayment.nu_dse__Program__c);
        }
    }
    /* * conversion for "Updated NSF Remove Campaign", "Updated NSF Campaign" processes
       * triggered only on change of Transaction Status/ Consecutive NSF, Dont Consider
       * If a draft record has Failed Status and Consecutive NSf as 1/2/3, updating equivalent NSF Start/Stop dates in program
    */
    public void updateProgramNSFStartStop(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) {
        
        nu_dse__Program__c program = new nu_dse__Program__c();
        if (programsToBeUpdatedMap.containsKey(program.Id) == true) {
            program = programsToBeUpdatedMap.get(program.Id);
        } else {               
            program = new nu_dse__Program__c(Id=newPayment.nu_dse__Program__c);
        }
        // for Failed payment with consecutive NSF 1/2/3, update Program with appropriate NSF Start/Stop
        if(newPayment.RecordTypeId == draftRecordTypeId && newPayment.nu_dse__Transaction_Status__c == 'Failed'
            && (Trigger.isInsert 
                || (oldPayment.Consecutive_NSF_Count__c != newPayment.Consecutive_NSF_Count__c 
                    || oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c 
                    || oldPayment.nu_dse__Dont_Consider__c != newPayment.nu_dse__Dont_Consider__c 
                    || oldPayment.RecordTypeId != newPayment.RecordTypeId)) 
            && (newPayment.Consecutive_NSF_Count__c == 1 
                || newPayment.Consecutive_NSF_Count__c == 2 
                || newPayment.Consecutive_NSF_Count__c == 3)) {
            system.debug('newPayment.Consecutive_NSF_Count__c:::'+newPayment.Consecutive_NSF_Count__c);
            if (newPayment.nu_dse__Dont_Consider__c == true) {
                switch on Integer.valueOf(newPayment.Consecutive_NSF_Count__c) {
                   when 1 {
                       program.NSF_Start__c = false;
                       program.NSF_Stop__c = true;
                   }
                   when 2 {
                       program.NSF_2_Start__c = false;
                       program.NSF_2_Stop__c = true;
                   }
                   when 3 {
                       program.NSF_Final_Start__c = false;
                       program.NSF_Final_Stop__c = true;
                   }
                }            
            } else if (newPayment.nu_dse__Dont_Consider__c == false) {
                switch on Integer.valueOf(newPayment.Consecutive_NSF_Count__c) {
                   when 1 {
                       program.NSF_Start__c = true;
                       program.NSF_Stop__c = false;
                   }
                   when 2 {
                       program.NSF_2_Start__c = true;
                       program.NSF_2_Stop__c = false;
                   }
                   when 3 {
                       program.NSF_Final_Start__c = true;
                       program.NSF_Final_Stop__c = false;
                   }
               }    
            }
            programsToBeUpdatedMap.put(program.Id, program);
        }
        //If the Transaction status changes to Failed and consecutive NSF is 3, updated program Involuntary_Termination__c as true and nu_dse__Program_Status__c as Termination Pending
        if(newPayment.nu_dse__Transaction_Status__c == 'Failed' && newPayment.Consecutive_NSF_Count__c == 3
            && (Trigger.isInsert 
                || (oldPayment.Consecutive_NSF_Count__c != newPayment.Consecutive_NSF_Count__c 
                    || oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c))) {
            
            program.Involuntary_Termination__c = true;
            program.nu_dse__Program_Status__c = 'Termination Pending';
            programsToBeUpdatedMap.put(program.Id, program);
        }
    }
    //creates a NSF tasks for failed pamyents 
    public void instantiateNSFTasks(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) { 
    
        if(newPayment.nu_dse__Transaction_Status__c == 'Failed' 
           && newPayment.RecordTypeId == draftRecordTypeId
           && (newPayment.Consecutive_NSF_Count__c == 1 || newPayment.Consecutive_NSF_Count__c == 2)
           && (Trigger.isInsert 
               || (oldPayment.Consecutive_NSF_Count__c != newPayment.Consecutive_NSF_Count__c 
                   || oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c 
                   || newPayment.nu_dse__Dont_Consider__c != oldPayment.nu_dse__Dont_Consider__c))) { 
            
            MissingCommTemps = '';           
            if(comuTempNameIdMap == null) {
                comuTempNameIdMap = getTemplateMap();
                holidayMap = Holidays.getHolidaysMap();
            }
            // below method creates tasks instance and adds to a map that is upserted at the rnd of execution
            getTaskInstance(new TaskWrapper('NSF SMS 1', newPayment.Id+'NSFSMS1', 'NSF SMS',newPayment.NSF_Date__c.addDays(1), newPayment));  
            getTaskInstance(new TaskWrapper('NSF EMAIL', newPayment.Id+'NSFEMAIL1', 'NSF EMAIL',newPayment.NSF_Date__c.addDays(1), newPayment)); 
            getTaskInstance(new TaskWrapper('NSF SMS 2', newPayment.Id+'NSFSMS20', 'NSF SMS BEYOND FINANCE Second Attempt',newPayment.NSF_Date__c.addDays(4), newPayment)); 
            getTaskInstance(new TaskWrapper('NSF Email 2', newPayment.Id+'NSFEMAIL20', 'NSF No Contact Email',newPayment.NSF_Date__c.addDays(4), newPayment));
            if(String.isNotBlank(MissingCommTemps)) {
                nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'PaymentHandler.afterUpdate', nu_dse__Error_Causing_Record_Id__c = newPayment.Id,
                                                                         nu_dse__Message__c = 'Following Communication Templates were missing: ' + MissingCommTemps, nu_dse__User_Context__c = userInfo.getUserName());
                
                errorLogList.add(errorLog);
            }
        }
    }
    //creates a Salesperson NSF tasks for failed pamyents 
    public void createSalespersonNSFNotifiTask(nu_dse__Payment__c newPayment, nu_dse__Payment__c oldPayment) { 
        
        if(newPayment.RecordTypeId == draftRecordTypeId && newPayment.NSF_Date__c != null 
            && newPayment.nu_dse__Transaction_Status__c == 'Failed' 
            && userMailMap.containskey(newPayment.Salesperson_ID_Formula__c)
            && userMailMap.get(newPayment.Salesperson_ID_Formula__c).IsActive == true
            && (Trigger.isInsert 
                || oldPayment.nu_dse__Transaction_Status__c != newPayment.nu_dse__Transaction_Status__c)) {
            
            Task notifytask = new Task(ownerId = newPayment.Salesperson_ID_Formula__c, WhatId = newPayment.nu_dse__Program__c, Subject = 'Recent Failed Payment',
                                       ActivityDate = system.Today(), Salesperson_Email__c = newPayment.Salesperson_Email_Formula__c, 
                                       Send_Salesperson_NSF_Email__c = true, Client_Name__c = newPayment.Client_Name__c, Program_Number__c = newPayment.Program_Name__c,
                                       NSF_Reason__c = newPayment.nu_dse__Failure_Reason__c, TDI__c = String.valueof(newPayment.Total_Debit_Included__c), 
                                       Date_Enrolled__c = newPayment.Date_Enrolled__c, Manager_Email__c = userMailMap.get(newPayment.Salesperson_ID_Formula__c).Beyond_Manager_Email__c,
                                       Payment_Scheduled_Date__c = newPayment.nu_dse__Schedule_Date__c, Unique_Identifier__c = newPayment.Id + 'Recent Failed Payment');
            taskToUpsertMap.put(notifytask.Unique_Identifier__c, notifytask);         
        }   
    }
    /*  * Check payments for change in Transaction Status = 'Completed', Collect Program Ids
        * Query Program and Payments, Find number of Completed payments in each program.
        * If Completed Payments == 3, -> Program_Phase__c = 'Preparation'
            Completed Payments == 8, -> Program_Phase__c = 'Deployment'
        * Program_Complete % = Total Completed Payment/totalNoofPayments * 100 (i.e) Total Completed % = (6 / 60) * 100 = 10%
        * Update the program. 
    */
    public void updateProgramPhaseAndProgress(){
                
        for(nu_dse__Program__c program : [SELECT Id, Program_Complete__c, (SELECT Id, nu_dse__Program__c, nu_dse__Schedule_date__c, nu_dse__Transaction_Status__c 
                                                FROM nu_dse__Payments__r WHERE nu_dse__Dont_Consider__c = false AND RecordType.Id = :draftRecordTypeId) FROM nu_dse__Program__c 
                                                WHERE Id IN :completedPaymentProgramIds]) {
            Decimal totalSize = program.nu_dse__Payments__r.size(); 
            Decimal totalCompleted = 0; 
            for(nu_dse__Payment__c payment: program.nu_dse__Payments__r){
                if(payment.nu_dse__Transaction_Status__c == 'Completed'){
                    totalCompleted++; 
                }
            }    
            /*System.debug('Size: '+ totalsize); 
            System.debug('completed:'+ totalcompleted);
            System.debug('calculated: '+ totalCompleted.divide(totalsize,2));*/
            nu_dse__Program__c programInst = new nu_dse__Program__c();
            if (programsToBeUpdatedMap.containsKey(program.Id) == true) {
                programInst = programsToBeUpdatedMap.get(program.Id);
            } else {               
                programInst = new nu_dse__Program__c(Id = program.Id);
            }
            programInst.Program_Complete__c = totalCompleted.divide(totalSize, 2) * 100;
            if(programInst.Program_Complete__c != program.Program_Complete__c) {
                if(totalCompleted == 3) {
                    programInst.Program_Phase__c = 'Preparation'; 
                } else if(totalcompleted == 8) {
                    programInst.Program_Phase__c = 'Deployment';
                }  
                programsToBeUpdatedMap.put(programInst.Id, programInst); 
            }                                
        }
    }
    // Updated Program NextDraftDate as upcoming draft Payment schedule date
    public void updateProgramNextDraftDate() {
    
        for (AggregateResult payment : [SELECT nu_dse__Program__c, nu_dse__Program__r.Next_Draft_Date__c nextDraftDate, 
                                            MIN(nu_dse__Schedule_Date__c) scheduleDate
                                            FROM nu_dse__Payment__c 
                                            WHERE nu_dse__Program__c IN :draftDateUpdateProgramIds 
                                                AND RecordType.Name = 'Draft' AND nu_dse__Schedule_Date__c > Today 
                                                AND nu_dse__Transaction_Status__c = 'Scheduled'
                                                AND nu_dse__Program__c != null
                                                GROUP BY nu_dse__Program__c, nu_dse__Program__r.Next_Draft_Date__c]) {
            
            if(payment.get('scheduleDate') != null
                && (payment.get('nextDraftDate') == null
                    || (Date.valueof(payment.get('scheduleDate')) != Date.valueof(payment.get('nextDraftDate'))))) {
                
                nu_dse__Program__c program = new nu_dse__Program__c();
                if (programsToBeUpdatedMap.containsKey(String.ValueOf(payment.get('nu_dse__Program__c'))) == true) {
                    program = programsToBeUpdatedMap.get(String.ValueOf(payment.get('nu_dse__Program__c')));
                } else {               
                    program = new nu_dse__Program__c(Id=String.ValueOf(payment.get('nu_dse__Program__c')));
                }
                program.Next_Draft_Date__c = Date.valueof(payment.get('scheduleDate'));
                programsToBeUpdatedMap.put(program.Id, program);
            }
            draftDateUpdateProgramIds.remove(String.ValueOf(payment.get('nu_dse__Program__c')));
        }
        // Cleared Next Draft Date when no payment was scheduled(End of the Program)
        for (Id programId : draftDateUpdateProgramIds){

            nu_dse__Program__c program = new nu_dse__Program__c();
            if (programsToBeUpdatedMap.containsKey(program.Id) == true) {
                program = programsToBeUpdatedMap.get(programId);
            } else {               
                program = new nu_dse__Program__c(Id=programId);
            }
            program.Next_Draft_Date__c = null;
            programsToBeUpdatedMap.put(program.Id, program);
        }
    }
    
    //creates a Group task and assigns to a Queue if Verbal_Authorization_Received__c = true
    public void createVerbalAuthGroupTask() { 
        
        Map<Id, String> programLastCallMap = new Map<Id, String>();
        for(nu_dse__Program__c program : [SELECT Id, Last_Call_Recording__c FROM nu_dse__Program__c WHERE Id IN :verbalAuthRecivedPaymentProgramIds AND Last_Call_Recording__c != null]) {
            programLastCallMap.put(program.id, program.Last_Call_Recording__c);
        }
        for(nu_dse__Payment__c newPayment : verbalAuthRecivedPayments) {
            if(comuTempNameIdMap == null) {
                comuTempNameIdMap = getTemplateMap();
                holidayMap = Holidays.getHolidaysMap();
            }
            if(queueMap == null) {
                queueMap = getQueueMap();
            }
            Date activityDate = system.today(); 
            activityDate = Holidays.getNextWorkingDay(holidayMap, ActivityDate);
            String programLastCallRecording;
            if(programLastCallMap.containskey(newPayment.nu_dse__Program__c)){
                programLastCallRecording = programLastCallMap.get(newPayment.nu_dse__Program__c);
            }
            // nu_dse__Description__c = Program.Last_call_Recording__c && No nu_dse__Status__c Variable && No nu_dse__Communication_Template__c 
            nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(nu_dse__subject__c = 'Review Payment Authorization', nu_dse__ActivityDate__c = activityDate, 
                                                        nu_dse__Unique_Identifier__c = newPayment.Id + 'Review Payment Authorization', nu_dse__Related_To__c = newPayment.Id,
                                                        ownerId = queueMap.get('Payment_Authorization'), nu_dse__Description__c = programLastCallRecording); 
            groupTaskToInsert.add(groupTask); 
        }
    }
    // Method to get Communication Templates   
    public static Map<String,Id> getTemplateMap(){
        
        Map<String,Id> template = new Map<String,Id>();
        for(nu_dse__Communication_Template__c temp: [SELECT Id, Name FROM nu_dse__Communication_Template__c]){
            template.put(temp.name,temp.id);
        }
        return template; 
    }  
    // Method to get Queues
    public static Map<String, Id> getQueueMap(){

        Map<String,Id> queueName = new Map<String,Id>(); 
        for(Group q: [SELECT Id, Name, DeveloperName, Type, Email, ownerId FROM Group WHERE Type = 'Queue']){
            queueName.put(q.developerName, q.id);
        }
        return queueName; 
    } 
    //creates a Task instance based on input parameter, and adds to a map to upsert
    public void getTaskInstance(TaskWrapper taskWrap) {

        if(comuTempNameIdMap.containskey(taskWrap.commTempName)) {
            Task taskInstance = new Task(WhatId = taskWrap.paymentInstance.Id, Subject = taskWrap.subject , ActivityDate = taskWrap.activityDate, 
                                        nu_dse__Communication_Template__c = comuTempNameIdMap.get(taskWrap.commTempName), Unique_Identifier__c = taskWrap.uniqueIdentifier , 
                                        nu_dse__Is_System_Task__c = true, OwnerId = Id.valueof('00546000001WqLu'));
                                        
            if(taskWrap.paymentInstance.nu_dse__Dont_Consider__c == true && taskWrap.paymentInstance.NSF_Date__c != null) {
                taskInstance.ActivityDate = Holidays.getNextWorkingDay(holidayMap, taskWrap.activityDate);
                taskInstance.Status = 'Completed';
            }
            taskToUpsertMap.put(taskInstance.Unique_Identifier__c , taskInstance);
        } else {
            MissingCommTemps = taskWrap.commTempName;
        } 
    }
    // Using to Create Task 
    public class TaskWrapper {

        String subject;
        String uniqueIdentifier;
        String commTempName;
        Date activityDate;
        nu_dse__Payment__c paymentInstance;

        public TaskWrapper(String subjectParam, String uniqueIdentifierParam, String commTempNameParam, Date activityDateParam, nu_dse__Payment__c paymentInstanceParam) {
            this.subject = subjectParam;
            this.uniqueIdentifier = uniqueIdentifierParam;
            this.commTempName = commTempNameParam;
            this.activityDate = activityDateParam;
            this.paymentInstance = paymentInstanceParam;
        }
    }

    // for all cancelled payments, deleting child tasks
    // and schedule date changed, Updating child Tasks activity date. 
    @future
    public static void updateDeleteTask(Set<Id> cancelledPaymentIds, Map<Id, Date> updatedIdscheduleDateMap) {

        List<Task> taskToDeleteList = new List<Task>(); // Delete the Task when Payment was cancelled
        Map<String, Task> taskToUpsertMap = new Map<String, Task>(); //tasks to be upserted based on unique Identifier
        Map<Integer, Integer> paddingDaysMap = new Map<Integer, Integer>(); 
        Map<Id, Date> prospectIdSMSTaskMaxSchDateMap = new Map<Id, Date>();
        Set<Id> EmailPaymentIdSet = new Set<Id>();
        Set<Id> SMSPaymentIdSet = new Set<Id>();

        for(Deposit_Reminder_Configuration__mdt depositReminderConfig : [SELECT Padding_Days__c, Sequence_number__c 
                                                                         FROM Deposit_Reminder_Configuration__mdt
                                                                         WHERE Padding_Days__c > 0
                                                                         ORDER BY Padding_Days__c DESC]){
            paddingDaysMap.put(Integer.valueOf(depositReminderConfig.Sequence_number__c), Integer.valueOf(depositReminderConfig.Padding_Days__c));
        }

        for(Task task : [SELECT Id, Unique_Identifier__c, WhatId, activityDate FROM Task WHERE Status != 'Completed' AND Unique_Identifier__c != null 
                                                                                 AND nu_dse__Communication_Sent__c != true
                                                                                 AND (WhatId IN :cancelledPaymentIds
                                                                                 OR WhatId IN :updatedIdscheduleDateMap.keySet())
                                                                                 ORDER BY activityDate DESC]) {
            if(cancelledPaymentIds.contains(task.WhatId) == true) {
                taskToDeleteList.add(task);
            } else if(updatedIdscheduleDateMap.containsKey(task.WhatId)){
                
                Integer padding = 0;

                if(task.Unique_Identifier__c.contains('SMS') 
                    && String.isNotBlank(task.Unique_Identifier__c.substringAfterLast('SMS '))
                    && paddingDaysMap.containsKey(Integer.valueOf(task.Unique_Identifier__c.substringAfterLast('SMS ')))) {
                    
                    padding = paddingDaysMap.get(Integer.valueOf(task.Unique_Identifier__c.substringAfterLast('SMS ')));
                    if(updatedIdscheduleDateMap.get(task.WhatId).addDays(-padding) > system.today()) {
                        task.activityDate = updatedIdscheduleDateMap.get(task.WhatId).addDays(-padding);
                        taskToUpsertMap.put(task.Unique_Identifier__c, task);
                    } else if(updatedIdscheduleDateMap.get(task.WhatId) != system.today()
                              && SMSPaymentIdSet.contains(task.WhatId) == false) {
                        task.activityDate = system.today().addDays(1);
                        taskToUpsertMap.put(task.Unique_Identifier__c, task);
                    } else {
                        taskToDeleteList.add(task);
                    }

                    if(task.activityDate == system.today().addDays(1)) {
                        SMSPaymentIdSet.add(task.WhatId);
                    }

                } else if(task.Unique_Identifier__c.contains('Email') 
                    && String.isNotBlank(task.Unique_Identifier__c.substringAfterLast('Email '))
                    && paddingDaysMap.containsKey(Integer.valueOf(task.Unique_Identifier__c.substringAfterLast('Email ')))) {
                    
                    padding = paddingDaysMap.get(Integer.valueOf(task.Unique_Identifier__c.substringAfterLast('Email ')));
                    if(updatedIdscheduleDateMap.get(task.WhatId).addDays(-padding) > system.today()) {
                        task.activityDate = updatedIdscheduleDateMap.get(task.WhatId).addDays(-padding);
                        taskToUpsertMap.put(task.Unique_Identifier__c, task);
                    } else if(updatedIdscheduleDateMap.get(task.WhatId) != system.today()
                              && EmailPaymentIdSet.contains(task.WhatId) == false){
                        task.activityDate = system.today().addDays(1);
                        taskToUpsertMap.put(task.Unique_Identifier__c, task);
                    } else {
                        taskToDeleteList.add(task);
                    }

                    if(task.activityDate == system.today().addDays(1)) {
                        EmailPaymentIdSet.add(task.WhatId);
                    }
                } else {
                    taskToDeleteList.add(task);
                }
            }
        }
        upsert taskToUpsertMap.values() Unique_Identifier__c; // finally upsertng tasks based on Unique_Identifier__c field
        delete taskToDeleteList; // delete the cancelled payment related tasks list
    }
}