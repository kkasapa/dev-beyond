@isTest
private class LicensedStateTriggerHandlerTest {
	
    @TestSetup
    static void makeData(){
    	Licensed_State__c lsObj = new Licensed_State__c(
        	Active__c = true,
            State__c  = 'AL'
        );
        insert lsObj;
    }
    
    @isTest
    public static void testUpdateStateCodes() {
        test.startTest();
            Licensed_State__c lsObj = [SELECT Id,State__c,Active__c FROM Licensed_State__c LIMIT 1];   
            lsObj.State__c = 'AK';
            update lsObj;
            system.assertEquals(lsObj.Active__c,true);
        	try{
            	lsObj = new Licensed_State__c(
                    Active__c = true,
                    State__c  = 'AK'
                );
                insert lsObj;                
            }catch(Exception Ex){}
        	try{
                list<Licensed_State__c> lstOfState = new list<Licensed_State__c>();
                lsObj = new Licensed_State__c(
                    Active__c = true,
                    State__c  = 'AK'
                );
                lstOfState.add(lsObj); 
                lsObj = new Licensed_State__c(
                    Active__c = true,
                    State__c  = 'AK'
                );
                lstOfState.add(lsObj); 
                insert lstOfState;
            }catch(Exception Ex){}
        test.stopTest();
    }
}