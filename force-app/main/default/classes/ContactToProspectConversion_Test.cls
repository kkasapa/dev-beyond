@isTest 
private class ContactToProspectConversion_Test{
    // Depricate...SF-581
    /*static testMethod void validate() {
      Test.startTest();
       List<RecordType> crecType = [SELECT id FROM RecordType WHERE SObjectType = 'Contact' and DeveloperName='Pardot' LIMIT 1];
       List<RecordType> recType = [SELECT id FROM RecordType WHERE SObjectType = 'nu_dse__Prospect__c' and DeveloperName='Debt_Settlement' LIMIT 1];
       
       if(crecType.size() > 0){
           Contact c = new Contact();
           c.FirstName ='John'; 
           c.LastName ='Doe'; 
           c.Email = 'jdoe@testemail.com';
           c.RecordTypeId = crecType[0].Id;
           c.Prospect_Source__c = 'Digital';
           c.Phone = '9548675309';
           c.OtherPhone = '9545555555';
           c.MobilePhone = '9546666666';
           System.debug('Insert Contact');
           
           insert c;
           
           // Retrieve the Prospect.
           List<nu_dse__Prospect__c> p = [SELECT Id, nu_dse__First_Name__c,Best_Phone__c, nu_dse__Last_Name__c, nu_dse__Email_Address__c, Contact__c, nu_dse__Prospect_Source__c, nu_dse__Home_Phone__c, nu_dse__Work_Phone__c, nu_dse__Cell_Phone__c, RecordTypeId FROM nu_dse__Prospect__c WHERE Contact__c =:c.Id];
           System.debug('Prospect Found' + p[0].Id);
           
                      
           System.assertEquals(p[0].Contact__c, c.Id); // Validate Contact Population on Prospect
           System.assertEquals(c.RecordTypeId, crecType[0].Id); // Validate Contact Record Type
           System.assertEquals(p[0].RecordTypeId, recType[0].Id); // Validate Prospect Record Type
           System.assertEquals(p[0].nu_dse__First_Name__c, c.FirstName);
           System.assertEquals(p[0].nu_dse__Last_Name__c, c.LastName);
           System.assertEquals(p[0].nu_dse__Email_Address__c, c.Email);              
           System.assertEquals(p[0].nu_dse__Prospect_Source__c, c.Prospect_Source__c); // Validate Prospect Record Type
           System.assertEquals(p[0].Best_Phone__c, c.Phone);
           System.assertEquals(p[0].nu_dse__Work_Phone__c, c.OtherPhone);
           System.assertEquals(p[0].nu_dse__Cell_Phone__c, c.phone);                    
           
           ContactToProspectConversion contactToConvert = new ContactToProspectConversion();
           }
    Test.stopTest();
    }*/
  
}