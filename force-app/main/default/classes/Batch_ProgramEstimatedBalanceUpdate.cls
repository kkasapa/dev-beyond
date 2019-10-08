/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Batch class for update Program Estimated Balance. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vignesh   <vsadhasivam@selastech.com>
* @modifiedBy     Vignesh   <abretto@selastech.com>
* @maintainedBy   Vignesh   <vsadhasivam@selastech.com>
* @version        1.0
* @created        2019-10-08
* @modified       2019-10-08
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class Batch_ProgramEstimatedBalanceUpdate implements Database.Batchable<sObject> {
    
    Set<Id> programIds;
    Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
    Id settlementRecordTypeId, feeRecordTypeId;

    public Batch_ProgramEstimatedBalanceUpdate() {

    }
    public Batch_ProgramEstimatedBalanceUpdate(Set<Id> programIdSet) {
        programIds = new Set<Id>();
        if(programIdSet != null && programIdSet.isEmpty() == false) {
            programIds = programIdSet;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();

        Set<Id> recordTypeIds = new Set<Id> {draftRecordTypeId, settlementRecordTypeId, feeRecordTypeId};
        Date futureEstimateDate = system.today().addMonths(12); 
        Set<String> prgramStatus = new Set<String> {'Active', 'New Client'};

        String queryStr = 'SELECT Id, nu_dse__Trust_Account_Balance__c, ' + 
                            '(SELECT Id, nu_dse__Total_Amount__c, nu_dse__Schedule_Date__c, RecordTypeId FROM nu_dse__Payments__r ' +
                            'WHERE nu_dse__Schedule_Date__c > Today '+  
                                'AND nu_dse__Schedule_Date__c < :futureEstimateDate AND RecordTypeId IN :recordTypeIds '+
                                'AND (nu_dse__Transaction_Status__c = \'Scheduled\' OR nu_dse__Transaction_Status__c = \'Pending\') ORDER BY nu_dse__Schedule_Date__c) '+
                       'FROM nu_dse__Program__c ' +
                       'WHERE nu_dse__Program_Status__c IN :prgramStatus';
        
        if(programIds != null && programIds.isEmpty() == false) {
            queryStr += ' AND Id IN :programIds';
        }

        system.debug('recordTypeIds:::'+recordTypeIds);
        system.debug('queryStr:::'+queryStr);
        return Database.getQueryLocator(queryStr);
    }
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope) {
        
        List<nu_dse__Program__c> programToUpdateList = new List<nu_dse__Program__c>();

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

            for(nu_dse__Payment__c payment : program.nu_dse__Payments__r) {
                
                system.debug('draftRecordTypeId:::'+draftRecordTypeId);

                if(payment.RecordTypeId ==  draftRecordTypeId) {
                    programBal += payment.nu_dse__Total_Amount__c;
                } else {
                    programBal -= payment.nu_dse__Total_Amount__c;
                }

                if(payment.nu_dse__Schedule_Date__c <= system.Today().addMonths(2)) {

                    updateProgram.Estimated_Month_2_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.Today().addMonths(3)) {

                    updateProgram.Estimated_Month_3_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.Today().addMonths(6)) {

                    updateProgram.Estimated_Month_6_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.Today().addMonths(9)) {

                    updateProgram.Estimated_Month_9_Balance__c = programBal;

                } else if(payment.nu_dse__Schedule_Date__c <= system.Today().addMonths(12)) {

                    updateProgram.Estimated_Month_12_Balance__c = programBal;

                }
            }
            programToUpdateList.add(updateProgram);
        }
        system.debug('programToUpdateList:::'+programToUpdateList);
        update programToUpdateList;
    }
    public void finish(Database.BatchableContext BC) {

    }
}
