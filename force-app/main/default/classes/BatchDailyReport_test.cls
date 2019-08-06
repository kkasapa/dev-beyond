@isTest
private class BatchDailyReport_test{

    static testmethod void test() {
        String query = 'Select id,name,nu_dse__Disposition__c,Campaign_Updated__c,Campaign_Disposition__c '
            +' from nu_dse__Program__c where Campaign_Updated__c = true'; 
        nu_dse__Program__c  prog = new nu_dse__Program__c ();
        prog.Prospect_Name__c ='DailyProgramReport';
        prog.Campaign_Updated__c = true; 
        prog.Campaign_Disposition__c =  'NSF1Start';
        prog.File_Review_Checklist_Start__c = true;
        prog.File_Review_Checklist_Start_Date__c = system.now();
        prog.File_Review_Checklist_Stop_Date__c = system.now();
        insert prog;

       Test.startTest();
       BatchDailyReport c = new BatchDailyReport();
       Database.executeBatch(c);
       Test.stopTest();

      
    }
}