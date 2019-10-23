@isTest
private class TestBLPMicroServiceAPI {
    
    @testSetup static void setup() {
    	Id clientRTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();	   
        Account actObj = new Account(
        	RecordTypeID = clientRTypeId,FirstName = '', LastName = 'Test',PersonBirthdate = system.today().addYears(-30),PersonHomePhone = '9874563210',
          	PersonMobilePhone = '9874563210',PersonOtherPhone = '9874563210',nu_dse__Co_Date_of_Birth__c = system.today().addYears(-30)   	
        );
        insert actObj;
        nu_dse__Program__c pgmObj = new nu_dse__Program__c(
        	nu_dse__Account__c = actObj.Id
        );
        insert pgmObj;
    }
    private static testMethod void addClientAPI() {
    	nu_dse__Program__c pgmObj = [SELECT Id FROM nu_dse__Program__c LIMIT 1]; 
        try{
        	BLPMicroServiceAPI.addClientAPI(pgmObj.Id);    
        }catch(Exception Ex){}        
    }
}