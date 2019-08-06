/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for updates Prospect day field in Prospect. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @modified       2019-06-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class Batch_ProgramDailyUpdates implements Database.Batchable<sObject>,Schedulable   {

    global  String queryString = '';
    
    //initialize a query excuding the program statuses Cancelled, Graduated, Terminated, Sold to 3rd Party, Did Not Sell, Termination Pending, Closed
    global Batch_ProgramDailyUpdates(){
        queryString = 'SELECT Id, Program_Day__c, CreatedDate FROM nu_dse__Program__c WHERE NOT nu_dse__Program_Status__c in  (\'Cancelled\', \'Graduated\', \'Terminated\',\'Sold to 3rd Party\',\'Did Not Sell\',\'Termination Pending\',\'Closed\') ';
    }
    
    global   Database.QueryLocator start(Database.BatchableContext BC){
        //Deprecated Five9 custom setting update on 18-June-2019
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        
        List<nu_dse__Program__c> programsTobeUpdated = new List<nu_dse__Program__c>(); 
        List<Id> programIds = new list<Id>();
        List<nu_dse__Payment__c> paymentsTobeUpdated = new List<nu_dse__Payment__c>();

        for(nu_dse__Program__c p: (List<nu_dse__Program__c>)scope){
            p.Program_Day__c = String.valueOf(getProgramDay(p.createdDate.date())); //calculate program day based on CreatedDate
            programsTobeUpdated.add(p);
            programIds.add(p.id);
        }
        
        System.enqueueJob(new ProgramDailyUpdatesHandler(programsTobeUpdated)); // performing DML in a seperate Queuable context
       
        for(nu_dse__Payment__c p: [SELECT Id,nu_dse__Schedule_Date__c FROM nu_dse__Payment__c WHERE nu_dse__Program__c IN :programIds]){
            if(p.nu_dse__Schedule_Date__c != null && p.nu_dse__Schedule_Date__c.isSameDay(System.date.today())){
                p.Is_Today__c = true; //update payment if Schedule date is today
                paymentsTobeUpdated.add(p);
            }
        }
       update paymentsTobeUpdated; 
    }
    
    global void finish(Database.BatchableContext BC){
        //Deprecated Five9 custom setting update on 18-June-2019
    }
    
    global void execute(SchedulableContext SC) { // Invokes this Batch from a Scheduled context
      Batch_ProgramDailyUpdates batchable = new Batch_ProgramDailyUpdates(); 
      Database.executeBatch(batchable,10);
   }
    
    private static integer getProgramDay(Date createddate){
       return createdDate.daysBetween(Date.today()); // return Program Day by calculating days between today and created day
    }
    
}