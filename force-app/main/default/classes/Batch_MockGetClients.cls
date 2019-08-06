public with sharing class Batch_MockGetClients implements Database.Batchable<sObject>{
    
    public Id progId;

    public Batch_MockGetClients(Id progIdparam) {

        progId = progIdparam;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator('SELECT Id, nu_dse__Program_Status__c FROM nu_dse__Program__c WHERE Id = :progId');
    }

    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programs) {

        List<nu_dse__Program__c> progs = new List<nu_dse__Program__c>();
        for (nu_dse__Program__c prog: programs) {
            prog.nu_dse__OFAC_Status__c = 'Verified';
            prog.nu_dse__SPAA_status__c = 'VERIFIED';
            prog.nu_dse__CIP_Status__c = 'Verified';
            prog.nu_dse__Processor_Status__c = 'Active';
            prog.nu_dse__Program_Status__c = 'New Client';
            progs.add(prog);
        }

    update progs;
    }

    public void finish(Database.BatchableContext BC) {}

}