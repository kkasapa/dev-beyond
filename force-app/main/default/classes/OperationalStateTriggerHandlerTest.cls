@isTest
private class OperationalStateTriggerHandlerTest {
	
    @TestSetup
    static void makeData(){
    	Operational_State__c lsObj = new Operational_State__c(
        	State__c  = 'AL'
        );
        insert lsObj;
    }
    
    @isTest
    public static void testUpdateStateCodes() {
        test.startTest();
            Operational_State__c lsObj = [SELECT Id,State__c FROM Operational_State__c LIMIT 1];   
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
        	lsObj.Limited_BLP_States__c = true;
        	lsObj.CFT__c = true;
        	update lsObj;
        	lsObj.ClearOne_GCS__c = true;
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
        	lsObj.ClearOne_GCS__c = true;
        	try{
            	update lsObj;    
            }catch(Exception Ex){}
            //system.assertEquals(lsObj.Active__c,true);
        	try{
            	lsObj = new Operational_State__c(
                    State__c  = 'AK'
                );
                insert lsObj;                
            }catch(Exception Ex){}
        	try{
                list<Operational_State__c> lstOfState = new list<Operational_State__c>();
                lsObj = new Operational_State__c(
                    State__c  = 'AK'
                );
                lstOfState.add(lsObj); 
                lsObj = new Operational_State__c(
                    State__c  = 'AK'
                );
                lstOfState.add(lsObj); 
                insert lstOfState;
            }catch(Exception Ex){}
        
        lsObj = new Operational_State__c(
        	State__c  = 'OH'
            
        );
        insert lsObj;
        lsObj.ClearOne_GCS__c = true;
        update lsObj;
        
        lsObj = new Operational_State__c(
        	State__c  = 'OH',
			ClearOne_GCS__c = true            
        );
        try{
            insert lsObj;    
        }catch(Exception Ex){}
        lsObj = [SELECT Id,State__c FROM Operational_State__c LIMIT 1];  
        delete lsObj;
        test.stopTest();
    }
	
}