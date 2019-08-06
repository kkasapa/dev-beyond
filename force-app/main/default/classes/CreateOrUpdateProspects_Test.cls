@isTest
public class CreateOrUpdateProspects_Test {

    public static testmethod void testpost(){
        
        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>(); 
        
        nu_dse__Prospect__c p = new Nu_dse__Prospect__c(); 
        p.nu_dse__First_Name__c = 'Test';
        p.nu_dse__Last_name__c = 'last';
        p.nu_dse__Program_Length__c = 24;         
        prospectList.add(p);
        
        CreateOrUPdateProspects.doPost(prospectList);
        
    }
}