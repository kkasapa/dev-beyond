@isTest 
private class ProspectOpenTaskTrigger_Test{
    static /*testMethod*/ void validateOpenTask() {
       Test.startTest();
       List<RecordType> recType = [SELECT id FROM RecordType WHERE SObjectType = 'nu_dse__Prospect__c' and DeveloperName='Debt_Settlement' LIMIT 1];
       
       if(recType.size() > 0){
           nu_dse__Prospect__c p = new nu_dse__Prospect__c();
           p.nu_dse__First_Name__c ='John'; 
           p.nu_dse__Last_Name__c ='Doe'; 
           p.nu_dse__Email_Address__c = 'jdoe@testemail.com';
           p.RecordTypeId = recType[0].Id;
           
           System.debug('Insert Prospect');
           insert p;
           
           // Retrieve the Prospect.
           List<nu_dse__Prospect__c> pQuery = [SELECT Id, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__Email_Address__c, Contact__c, Remove_from_Five9_Campaign__c, RecordTypeId FROM nu_dse__Prospect__c WHERE Id = :p.Id];
           System.debug('Prospect Found' + pQuery[0].Id);
           
           
           //Create Open Task
           Task t = new Task();
           t.OwnerId = UserInfo.getUserId();
           t.Subject = 'E-mail Client on New Offer (Test)';
           t.Status = 'Not Started';
           t.WhatId = pQuery[0].id;
           insert t;
           
           List<Task> tQuery = [SELECT Id, WhatId, Status FROM Task WHERE Id = :t.Id];
                  String Prospect_Prefix = Schema.SObjectType.nu_dse__Prospect__c.getKeyPrefix();
                      if(((String) tQuery[0].WhatId).startsWith(Prospect_Prefix) && tQuery[0].Status != 'Completed'){
                          System.Debug('Remove from Five9');
                          List<nu_dse__Prospect__c> pQuery2 = [SELECT Id, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__Email_Address__c, Contact__c, Remove_from_Five9_Campaign__c, RecordTypeId FROM nu_dse__Prospect__c WHERE Id = :p.Id];
                          System.assertEquals(pQuery2[0].Remove_from_Five9_Campaign__c, true); // Validate Prospect is Removed from Five9
                      }
                      
           ProspectOpenTaskTrigger testTaskTrigger = new ProspectOpenTaskTrigger();
           
           Test.stopTest();
           }
    }
}