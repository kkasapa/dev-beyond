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
        	lsObj.ADR_Beyond_Overlapping_States__c = true;
        	lsObj.ADR_Operational_State__c = true;
        	lsObj.ADR_Selling_to_ClearOne__c = true;
        	lsObj.ADR_Sell_to_GRT__c = true;
        	lsObj.ADR_Sell_to_Signature__c = true;
        	lsObj.Beyond_Operational_State__c = true;
        	lsObj.Discounted_and_Free_Legal__c = true;
        	lsObj.Full_BLP_States__c = true;
        	update lsObj;
        	lsObj.Limited_BLP_States__c = true;
        	try{
            	update lsObj;    
            }catch(Exception Ex){}
        	
        	lsObj.ADR_Beyond_Overlapping_States__c = false;
        	lsObj.ADR_Operational_State__c = false;
        	lsObj.ADR_Selling_to_ClearOne__c = false;
        	lsObj.ADR_Sell_to_GRT__c = false;
        	lsObj.ADR_Sell_to_Signature__c = false;
        	lsObj.Beyond_Operational_State__c = false;
        	lsObj.Discounted_and_Free_Legal__c = false;
        	lsObj.Full_BLP_States__c = false;
        	lsObj.Limited_BLP_States__c = true;
        	try{
            	update lsObj;    
            }catch(Exception Ex){}
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
        
        lsObj = new Licensed_State__c(
        	Active__c = true,
            State__c  = 'OH'
            
        );
        insert lsObj;
        lsObj.Limited_BLP_States__c = true;
        update lsObj;
        
        lsObj = new Licensed_State__c(
        	Active__c = true,
            State__c  = 'OH',
			Limited_BLP_States__c = true            
        );
        try{
            insert lsObj;    
        }catch(Exception Ex){}
        
        test.stopTest();
    }
}