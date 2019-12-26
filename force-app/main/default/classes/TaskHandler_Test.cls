@istest
public class TaskHandler_Test {

    @testsetup
    public static void testDataSetup(){ //initialize data for test cases
    
        nu_dse__prospect__c prospect = TestRecordCreator.createProspect();
        prospect.nu_dse__Affiliate__c = 'AMOne';
        prospect.nu_dse__Cell_Phone__c = '999999999';
        insert prospect;
        
        List<nu_dse__Communication_Template__c> commTempList = new List<nu_dse__Communication_Template__c>{
            new nu_dse__Communication_Template__c(Name = 'Payment Reminder - SMS', nu_dse__SMS_Body__c = 'Test SMS', nu_dse__From__c = '999999999',
                                                  nu_dse__Action_Type__c = 'SMS')
        };
        insert commTempList;
        
        nu_dse__Data_Mapping__c dataMappingInst = TestRecordCreator.createDataMapping('TasktoProspect', '', '');
        insert dataMappingInst;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c> ();
        nu_dse__Field_mapping__c DNISAffiliateMapping1 = TestRecordCreator.createFieldMapping(dataMappingInst.Id, '9786311259',
                                                                                              'Lendingtree WT', False, 'a1c46000000rl6v');
        nu_dse__Field_mapping__c DNISAffiliateMapping2 = TestRecordCreator.createFieldMapping(dataMappingInst.Id, '9786310181',
                                                                                              'AMOne WT', False, 'a1c46000000rl6v');                                                                                     
        fieldMappingList.add(DNISAffiliateMapping1);
        fieldMappingList.add(DNISAffiliateMapping2);
        insert fieldMappingList;
        
        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType 
                                           WHERE sObjectType = 'Account' AND isPersonType = true AND DeveloperName = 'Client' LIMIT 1];
        
        Account testAcc = TestRecordCreator.createAccount('Test', accRecTypeList[0].Id);
        testAcc.PersonMobilePhone = '99999999';
        insert testAcc;
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('TestCFT');
        insert processor;
        nu_dse__Fee_Template__c feeTemp = TestRecordCreator.createFeeTemplate();
        insert feeTemp;
        nu_dse__Program__c program =  TestRecordCreator.createProgram(testAcc.Id, processor.Id);
        program.nu_dse__Fee_Template__c = feeTemp.Id;
        program.nu_dse__Program_Status__c = 'Active';
        insert program;
    }
    
    public static testmethod void updateTaskUTMValueInsert_Test() { // test for Update in UTM Value based on Task 
        
        List<nu_dse__prospect__c> prosList = [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c LIMIT 1];
        Task newTask = new Task(whatId = prosList[0].Id, Subject = 'test Sub', Five9__Five9SessionId__c = 'a1c46000000rl6v');
        
        Test.startTest();
        insert newTask;
        Test.stopTest();
        
        List<Task> updatedTaskList = [SELECT Id, UTM_Value__c FROM Task LIMIT 1];
        system.assertEquals(updatedTaskList[0].UTM_Value__c, prosList[0].nu_dse__Affiliate__c);
    }
   
    public static testmethod void callSendSMSInsert_Test() { // test for sending SMS notification
        
        List<nu_dse__Communication_Template__c> comuTempList = [SELECT Id FROM nu_dse__Communication_Template__c LIMIT 1];
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Task newTask = new Task(whatId = programList[0].Id, Subject = 'test Sub', ActivityDate = system.today(), 
                                nu_dse__Communication_Template__c = comuTempList[0].Id, Is_Instant_SMS__c = true);
        Test.startTest();
        insert newTask;
        Test.stopTest();
    }
    
    public static testmethod void updateProspectDNIS_Test() { //test for Prospect Affiliate based on Tasks DNIS
        
        List<nu_dse__prospect__c> prosList = [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c LIMIT 1];
        Task newTask = new Task(whatId = prosList[0].Id, Subject = 'test Sub', Five9__Five9DNIS__c = '9786311259');
        
        Test.startTest();
        insert newTask;
        Test.stopTest();
        
        List<nu_dse__prospect__c> updatedProsList = [SELECT Id, Five9_Source_DNIS__c, nu_dse__Affiliate__c,Add_to_f9list_id__c 
                                                    FROM nu_dse__prospect__c LIMIT 1];
        system.assertEquals(newTask.Five9__Five9DNIS__c, updatedProsList[0].Five9_Source_DNIS__c);
        system.assertEquals('Lendingtree WT', updatedProsList[0].nu_dse__Affiliate__c);
        // system.assertEquals('a1c46000000rl6v', updatedProsList[0].Add_to_f9list_id__c );
    }
    
    public static testmethod void updateProspects_Test() { // test for Updates in Prospect based on Task field updates
        
        List<nu_dse__prospect__c> prosList = [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c LIMIT 1];
        List<Task> newTaskList = new List<Task> {
            new Task(whatId = prosList[0].Id, Subject = 'test Sub1', CallDisposition = 'Term Lost - Secured'),
            new Task(whatId = prosList[0].Id, Subject = 'test Sub2', CallDisposition = '16 DO NOT CALL'),
            new Task(whatId = prosList[0].Id, Subject = 'test Sub3', CallDisposition = '01 Undecided'),
            new Task(whatId = prosList[0].Id, Subject = 'test Sub4', CallDisposition = '08 Not Interested', Five9__Five9SessionId__c = 'a1c46000000rl6v')
        };
        
        Test.startTest();
        insert newTaskList;
        Test.stopTest();
        
        List<nu_dse__prospect__c> updatedProsList = [SELECT Id, Remove_from_Five9_Campaign__c, CustomStop1__c, FIve9_Owner_ID__c, 
                                                            Has_Been_Assigned__c, Not_Interested__c, F9LastDisposition__c, Stop_SMS__c 
                                                     FROM nu_dse__prospect__c LIMIT 1];
        List<Task> updatedTaskList = [SELECT Id, ownerId, CallDisposition FROM Task LIMIT 4];
        
        system.assertEquals(true, updatedProsList[0].Remove_from_Five9_Campaign__c);
        system.assertEquals(true, updatedProsList[0].Stop_SMS__c);
        system.assertEquals(true, updatedProsList[0].CustomStop1__c);
        system.assertEquals(updatedTaskList[3].ownerId, updatedProsList[0].FIve9_Owner_ID__c);
        system.assertEquals(true, updatedProsList[0].Has_Been_Assigned__c);
        system.assertEquals(true, updatedProsList[0].Not_Interested__c);
        system.assertEquals(updatedTaskList[3].CallDisposition, updatedProsList[0].F9LastDisposition__c);
    }
    
    public static testmethod void updatePrograms_Test() { // test for updates i Program based on Tasks fields
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        List<Task> newTaskList = new List<Task> {
            new Task(whatId = programList[0].Id, Subject = 'test Sub1', CallDisposition = '14 Welcome Call'),
            new Task(whatId = programList[0].Id, Subject = 'test Sub2', CallDisposition = '12 Offer Authorization'),
            new Task(whatId = programList[0].Id, Subject = 'test Sub3', CallDisposition = '10 NSF Makeup')
        };
        
        Test.startTest();
        insert newTaskList;
        Test.stopTest();
        
        List<nu_dse__Program__c> updatedProgramList = [SELECT Id, Last_Payment_Auth_Call_Recording__c, Last_Call_Recording__c, Welcome_Call_Complete__c 
                                                       FROM nu_dse__Program__c LIMIT 1];
        List<Task> updatedTaskList = [SELECT Id, S3_Recording_Link__c FROM Task LIMIT 3];
                                                       
        system.assertEquals(true, updatedProgramList[0].Welcome_Call_Complete__c);
        system.assertEquals(updatedTaskList[2].S3_Recording_Link__c, updatedProgramList[0].Last_Payment_Auth_Call_Recording__c);
        system.assertEquals(updatedTaskList[1].S3_Recording_Link__c, updatedProgramList[0].Last_Call_Recording__c);                                              
    }
    
    public static testmethod void updateTaskUTMValue_Test() { //test for task UTM value update 
        
        List<nu_dse__prospect__c> prosList = [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c LIMIT 1];
        Task newTask = new Task(whatId = prosList[0].Id, Subject = 'test Sub', ActivityDate = system.today());
        insert newTask;
        
        newTask.Five9__Five9SessionId__c = 'test';
        
        Test.startTest();
        update newTask;
        Test.stopTest();
        
        List<Task> updatedTaskList = [SELECT Id, UTM_Value__c FROM Task LIMIT 1];
        system.assertEquals(updatedTaskList[0].UTM_Value__c, prosList[0].nu_dse__Affiliate__c);
    } 
    
    public static testmethod void sendSMSUpdate_Test() { // test for sending SMS notification
        
        List<nu_dse__Communication_Template__c> comuTempList = [SELECT Id FROM nu_dse__Communication_Template__c LIMIT 1];
        List<nu_dse__prospect__c> prosList = [SELECT Id, nu_dse__Affiliate__c FROM nu_dse__prospect__c LIMIT 1];
        
        Task newTask = new Task(whatId = prosList[0].Id, Subject = 'test Sub', ActivityDate = system.today());
        insert newTask;
        
        newTask.nu_dse__Communication_Template__c = comuTempList[0].Id;
        newTask.Is_Instant_SMS__c = true;
        newTask.Status = 'Completed';
        
        Test.startTest();
        update newTask;
        Test.stopTest();
    }
}