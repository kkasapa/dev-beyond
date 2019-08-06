@isTest
public class TradelineEligibilityCheck_Test{
    static testMethod void runTest(){
    Test.startTest();
       List<RecordType> recType = [SELECT id FROM RecordType WHERE SObjectType = 'nu_dse__Prospect__c' and DeveloperName='Debt_Settlement' LIMIT 1]; 
           nu_dse__Prospect__c p = new nu_dse__Prospect__c();
           p.nu_dse__First_Name__c ='John'; 
           p.nu_dse__Last_Name__c ='Doe'; 
           p.nu_dse__Email_Address__c = 'jdoe@testemail.com';
           if(recType.size() > 0){
               p.RecordTypeId = recType[0].Id;
           }
           System.debug('Insert Prospect');

        insert p;
        
            Boolean excludedUserCheck = [Select Exclude_from_Prospect_Triggers__c From User Where Id = :UserInfo.getUserId()][0].Exclude_from_Prospect_Triggers__c;       
                if(excludedUserCheck == false){
                                    
                nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
                trd.nu_dse__prospect__c = p.id;
                trd.nu_dse__Original_Debt__c = 2.0;
                trd.nu_dse__Include_In_The_Program__c = true;
                trd.nu_dse__Original_Account_Number__c = '2343546123';
                insert trd;
                
                //Created on 20th Jun 2017
                nu_dse__TradeLine__c trd1 = new nu_dse__TradeLine__c();
                trd1.nu_dse__prospect__c = p.id;
                trd1.nu_dse__Original_Debt__c = 75000;
                trd1.nu_dse__Include_In_The_Program__c = true;
                trd1.nu_dse__Original_Account_Number__c = '2343546123';
                insert trd1;
        
                List<nu_dse__Prospect__c> pTest = [SELECT Id, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__Email_Address__c, Contact__c, Remove_from_Five9_Campaign__c, RecordTypeId, ApprovalSubmitted__c, nu_dse__Prospect_Status__c FROM nu_dse__Prospect__c WHERE Id = :p.Id];
                
                System.assertNotEquals(pTest[0].ApprovalSubmitted__c, true);  
                if(pTest[0].ApprovalSubmitted__c == false){
                    pTest[0].nu_dse__Prospect_Status__c = 'Check Eligibility';
                }
                update pTest[0];
                
                System.assertEquals(pTest[0].ApprovalSubmitted__c, false);  
                }
        Test.stopTest();
    }
    
    static testMethod void runTest1(){
    
        Test.startTest();
        
        List<RecordType> recType = [SELECT id FROM RecordType WHERE SObjectType = 'nu_dse__Prospect__c' and DeveloperName='Debt_Settlement' LIMIT 1]; 
        /*if(recType.size() > 0){
        
            nu_dse__Prospect__c p = new nu_dse__Prospect__c();
            p.nu_dse__First_Name__c ='John'; 
            p.nu_dse__Last_Name__c ='Doe'; 
            p.nu_dse__Email_Address__c = 'jdoe@testemail.com';
            p.Tradeline_Enrollment_Approval_Required__c = True;
            p.RecordTypeId = recType[0].Id;            
            insert p;
        
            Boolean excludedUserCheck = [Select Exclude_from_Prospect_Triggers__c From User Where Id = :UserInfo.getUserId()][0].Exclude_from_Prospect_Triggers__c;       
            if(excludedUserCheck == false){
                        
                nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
                trd.nu_dse__prospect__c = p.id;
                trd.nu_dse__Original_Debt__c = 750.0;
                trd.nu_dse__Include_In_The_Program__c = true;
                trd.nu_dse__Original_Account_Number__c = '2343546123';
                insert trd;
                
                nu_dse__TradeLine__c trd1 = new nu_dse__TradeLine__c();
                trd1.nu_dse__prospect__c = p.id;
                trd1.nu_dse__Original_Debt__c = 75000;
                trd1.nu_dse__Include_In_The_Program__c = true;
                trd1.nu_dse__Original_Account_Number__c = '2343546123';
                insert trd1;
                
                List<nu_dse__Prospect__c> pTest = [SELECT Id, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__Email_Address__c, Contact__c, Remove_from_Five9_Campaign__c, RecordTypeId, ApprovalSubmitted__c, nu_dse__Prospect_Status__c FROM nu_dse__Prospect__c WHERE Id = :p.Id];
                
                System.assertNotEquals(pTest[0].ApprovalSubmitted__c, true);  
                if(pTest[0].ApprovalSubmitted__c == false){
                    
                    pTest[0].nu_dse__Prospect_Status__c = 'Check Eligibility';
                }
                update pTest[0];
                
                System.assertEquals(pTest[0].ApprovalSubmitted__c, false);  
            }
        }*/
        try {
            if(recType.size() > 0){
            
                nu_dse__Prospect__c p = new nu_dse__Prospect__c();
                p.nu_dse__First_Name__c ='John'; 
                p.nu_dse__Last_Name__c ='Doe'; 
                p.nu_dse__Email_Address__c = 'jdoe@testemail.com';
                p.RecordTypeId = recType[0].Id;            
                insert p;
                
                
                Boolean excludedUserCheck = [Select Exclude_from_Prospect_Triggers__c From User Where Id = :UserInfo.getUserId()][0].Exclude_from_Prospect_Triggers__c;       
                if(excludedUserCheck == false){
                            
                    nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
                    trd.nu_dse__prospect__c = p.id;
                    trd.nu_dse__Original_Debt__c = 750.0;
                    trd.nu_dse__Include_In_The_Program__c = true;
                    trd.nu_dse__Original_Account_Number__c = '2343546123';
                    
                    p.nu_dse__Prospect_Status__c = 'Check Eligibility';
                    update p;
                    
                }
            }   
        }catch(Exception e){
        
        }
        
        Test.stopTest();
    }
}