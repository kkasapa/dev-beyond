@isTest
public class Batch_ABTestingProspect_Test {
    static testMethod void ABTestingProspect() {
        
        nu_dse__Prospect__c  prospect = TestRecordCreator.createProspect();
        insert prospect;
        
        nu_dse__Data_Mapping__c ABTestingProspect = TestRecordCreator.ABTestingProspect();
        insert ABTestingProspect;
        system.debug('ABTestingProspectToProspect-->'+ABTestingProspect);
        
        List<nu_dse__Field_mapping__c> fieldMapping = TestRecordCreator.ABTestingFieldMap(ABTestingProspect.Id);
        insert fieldMapping;
        
        Test.startTest();
            
            Database.executeBatch(new Batch_ABTestingProspect());
            
        Test.stopTest(); 
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, Available_for_AB_Testing__c, nu_dse__First_Name__c, nu_dse__Last_name__c, nu_dse__CO_Last_Name__c FROM nu_dse__Prospect__c WHERE Id =:prospect.Id ];
        System.assertEquals(true, prospectList[0].Available_for_AB_Testing__c);   
        System.assertEquals('Test User', prospectList[0].nu_dse__First_Name__c);
        System.assertEquals(prospectList[0].nu_dse__CO_Last_Name__c, prospectList[0].nu_dse__Last_name__c);
    }
}