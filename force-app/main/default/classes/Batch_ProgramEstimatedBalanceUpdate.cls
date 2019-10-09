/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for update Program Estimated Balance. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <vsadhasivam@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-08
* @modified       2019-10-08
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_ProgramEstimatedBalanceUpdate implements Database.Batchable<sObject> {
    
    Set<Id> programIds; //set of programIds to which the batch can be run
    Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId(); // recordType Id for draft
    Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();  // recordType Id for fee
    Id settlementRecordTypeId;  // recordType Id for settlement

    public Batch_ProgramEstimatedBalanceUpdate() {

    }
    //configurable contructor to run for set of programs
    public Batch_ProgramEstimatedBalanceUpdate(Set<Id> programIdSet) {
        programIds = new Set<Id>();
        if(programIdSet != null && programIdSet.isEmpty() == false) {
            programIds = programIdSet;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();

        Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};
        Date futureEstimateDate = system.today().toStartOfMonth().addMonths(12).addDays(-1); 
        Set<String> programStatus = new Set<String>{'New Client', 'Active'}; // by default, program status with New Client, Active will be processed

        //custom metadata type for having Program status to be included for calculations
        Program_Status_Configuration__mdt progStatusConfig = [SELECT Id, MasterLabel, Included_Statuses__c 
                                    FROM Program_Status_Configuration__mdt 
                                    WHERE DeveloperName = 'Estimated_Balance_Calculations' LIMIT 1];
        
        if(progStatusConfig != null
            && String.isNotBlank(progStatusConfig.Included_Statuses__c)) {
            programStatus = new Set<String>();
            programStatus.addAll(progStatusConfig.Included_Statuses__c.split(',', 0));
        } 

        String queryStr = 'SELECT Id, nu_dse__Trust_Account_Balance__c, ' + 
                            '(SELECT Id, nu_dse__Total_Amount__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c, nu_dse__Payment_Type__c, RecordTypeId FROM nu_dse__Payments__r ' +
                            'WHERE nu_dse__Schedule_Date__c >= TODAY '+  
                                'AND nu_dse__Schedule_Date__c <= :futureEstimateDate AND RecordTypeId IN :recordTypeIds '+
                                'AND (nu_dse__Transaction_Status__c = \'Scheduled\' OR nu_dse__Transaction_Status__c = \'In Progress\') ORDER BY nu_dse__Schedule_Date__c ASC) '+
                       'FROM nu_dse__Program__c ' +
                       'WHERE nu_dse__Program_Status__c IN :programStatus';
        
        if(programIds != null && programIds.isEmpty() == false) {
            queryStr += ' AND Id IN :programIds';
        }

        system.debug('futureEstimateDate:::'+futureEstimateDate);
        system.debug('queryStr:::'+queryStr);
        return Database.getQueryLocator(queryStr);
    }
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope) {
        
        Map<Id, nu_dse__Program__c> programToUpdateMap = new Map<Id, nu_dse__Program__c>();

        system.debug('scope:::'+scope);

        for(nu_dse__Program__c program : scope) {

            nu_dse__Program__c updateProgram = new nu_dse__Program__c(Id = program.Id, 
                Estimated_Month_2_Balance__c = null, Estimated_Month_3_Balance__c = null, 
                Estimated_Month_6_Balance__c = null, Estimated_Month_9_Balance__c = null,
                Estimated_Month_12_Balance__c = null);

            Decimal programBal = 0;
            
            if(program.nu_dse__Trust_Account_Balance__c != null) {
                programBal = program.nu_dse__Trust_Account_Balance__c;
            }

            system.debug('size:::'+program.nu_dse__Payments__r.size());
            system.debug('programBal1:::'+programBal);

            for(nu_dse__Payment__c payment : program.nu_dse__Payments__r) {
                
                system.debug('nu_dse__Schedule_Date__c:::'+payment.nu_dse__Schedule_Date__c);

                if(payment.RecordTypeId ==  draftRecordTypeId) {
                    programBal += payment.nu_dse__Amount__c;
                } else if(payment.RecordTypeId != feeRecordTypeId 
                        || (payment.nu_dse__Payment_Type__c == 'Fee Withdrawal')) {
                    programBal -= payment.nu_dse__Total_Amount__c;
                }
                system.debug('programBal:::'+programBal);
                
                if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(1).addDays(-1)) {
              
                    updateProgram.Current_Month_Balance__c = programBal;
                
                } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(2).addDays(-1)) {

                    updateProgram.Estimated_Month_2_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(3).addDays(-1)) {

                    updateProgram.Estimated_Month_3_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(6).addDays(-1)) {

                    updateProgram.Estimated_Month_6_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(9).addDays(-1)) {

                    updateProgram.Estimated_Month_9_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.today().toStartOfMonth().addMonths(12).addDays(-1)) {

                    updateProgram.Estimated_Month_12_Balance__c = programBal;

                }
            }
            updateProgram.Estimated_Balance_Calculations_Timestamp__c = System.now();
            programToUpdateMap.put(updateProgram.Id, updateProgram);
        }
        system.debug('programToUpdateList:::'+programToUpdateMap);
        List<nu_dse__Error_Log__c> errLogs = new List<nu_dse__Error_Log__c>();
        for (Database.SaveResult dmlResult: Database.update(programToUpdateMap.values(), false)) {

            if (dmlResult.isSuccess() == false) {
                nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ProgramEstimatedBalanceUpdate.excute',
                                                                        nu_dse__Error_Causing_Record_Id__c = dmlResult.getId(),
                                                                        nu_dse__Stack_Trace__c = JSON.serialize(programToUpdateMap.get(dmlResult.getId())),
                                                                        nu_dse__User_Context__c = UserInfo.getName()
                                                                        );
                for (Database.Error error: dmlResult.getErrors()) {
                    errLog.nu_dse__Message__c += error.getMessage();
                }
                errLogs.add(errLog);
            }
        }
        insert errLogs;
    }
    public void finish(Database.BatchableContext BC) {

    }
}