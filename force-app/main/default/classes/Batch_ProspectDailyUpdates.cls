/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for updates Prospect day field in Prospect. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @version        1.0
* @modified       2019-06-18
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

global class Batch_ProspectDailyUpdates implements Database.Batchable<sObject>,Schedulable  {

    global  String query = '';
    Set<String> F9LastDispositionSet = new Set<String>{'Busy', 'No Answer', '06 Voicemail', '07 Dead Air', '12 Wrong Number'};
    
    global Batch_ProspectDailyUpdates(){
        // Added few filters from "Lending tree process" to reduce the number of records processed Since this field(Prospect Day) is Used only in "Lending Tree Process". Ref: Monday PulseId:248160050
        query = 'SELECT Id, Prospect_Day__c, CreatedDate FROM nu_dse__Prospect__c WHERE nu_dse__Converted__c != true ';
        query = query + 'AND UTM_Source__c = \'lendingtree\' AND UTM_Medium__c = \'Affiliate\' AND F9LastDisposition__c IN :F9LastDispositionSet';
    }
    
    global   Database.QueryLocator start(Database.BatchableContext BC){
        //Deprecated Five9 custom setting update on 17-June-2019
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<nu_dse__Prospect__c> updatedProspects = new List<nu_dse__Prospect__c>(); 
        for(nu_dse__Prospect__c prospect : (List<nu_dse__Prospect__c>)scope){
            prospect.Prospect_Day__c = String.valueOf(getProspectDay(prospect.createdDate.date()));
            updatedProspects.add(prospect);
        }
        update updatedProspects;
    }
    
    global void finish(Database.BatchableContext BC){
         //Deprecated Five9 custom setting update on 17-June-2019
     }
    
    global void execute(SchedulableContext SC) { // Invokes this Batch from a Scheduled context
        Batch_ProspectDailyUpdates batch = new Batch_ProspectDailyUpdates(); 
        Database.executeBatch(batch,10);
    }
    
    private static integer getProspectDay(Date createddate){
        return createdDate.daysBetween(Date.today()); // return Prospect Day by calculating days between today and created day
    }
}