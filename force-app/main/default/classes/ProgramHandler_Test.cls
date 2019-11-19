@isTest 
public class ProgramHandler_Test {
    
    @testSetup
    public static void testData() {
        
        Velocify_API_Settings__c settings = new Velocify_API_Settings__c();
        settings.Username__c = 'TestUserName';
        settings.Password__c = '12345';
        settings.Endpoint__c = 'http://service.leads360.com/ClientService.asmx';
        settings.SOAP_Action_Lead_Action_Update__c = 'https://service.leads360.com/AddLeadAction';
        settings.SOAP_Action_Lead_Update__c = 'https://service.leads360.com/ModifyLeads';
        settings.SOAP_Action_Status_Update__c = 'https://service.leads360.com/ModifyLeadStatus';
        insert settings;

        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType 
                                           WHERE sObjectType = 'Account' AND isPersonType = true 
                                               AND DeveloperName = 'Client' LIMIT 1];
        
        Account acc = TestRecordCreator.createAccount('Account1', accRecTypeList[0].Id);
        insert acc; 
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('GCS');
        insert processor;

        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, processor.Id);
        insert program;

        List<nu_dse__Communication_Template__c> commTempList = new List<nu_dse__Communication_Template__c>{
            new nu_dse__Communication_Template__c(Name = 'Email Grad Package'),
            new nu_dse__Communication_Template__c(Name = 'Mail Grad Package')
        };
        insert commTempList;

        List<Group> grpList = new List<Group>{
            new Group(Name = 'Mail_Queue'),
            new Group(Name = 'Termination_Request_CS')
        };
        insert grpList;

        //custom settings for saving calc API
        Savings_Calculator_Microservice__c savingCalcSettings = new Savings_Calculator_Microservice__c();
        savingCalcSettings.Endpoint__c = 'https://beyondfinance.com/api/v1/savings';
        savingCalcSettings.InterestRate__c = 16.4;
        savingCalcSettings.Minimum_Payment__c = 2;
        insert savingCalcSettings;
    }
    
     // Test method to check created Group Task for inserted Cross Collateralized Programs
    Public static testmethod void createCCGroupTaskInsert_Test(){
        
        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Processor__c> processor = [SELECT Id FROM nu_dse__Processor__c];
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc[0].Id, processor[0].Id);
        program.Cross_Collateralized__c = true;
        program.Salesperson_ID__c = userInfo.getUserId();
        Test.startTest();
            // Inserted Program with Cross Collateralized = true
            insert program;
        Test.stopTest();
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, OwnerId, Subject_Pick_List__c, nu_dse__ActivityDate__c, 
                                                        nu_dse__Related_To__c, nu_dse__Status__c, nu_dse__Unique_Identifier__c 
                                                     FROM nu_dse__Group_Task__c];
        List<nu_dse__Program__c> programList = [SELECT Id, Salesperson_ID__c FROM nu_dse__Program__c WHERE Id = :program.Id];
        // Checking created Group Task values
        system.assertEquals(programList[0].Salesperson_ID__c, groupTaskList[0].OwnerId);
        system.assertEquals('Cross Collateralized', groupTaskList[0].Subject_Pick_List__c);
        system.assertEquals(system.today().addDays(14), groupTaskList[0].nu_dse__ActivityDate__c);
        system.assertEquals(programList[0].Id, groupTaskList[0].nu_dse__Related_To__c);
        // system.assertEquals('Not Started', groupTaskList[0].nu_dse__Status__c);
        system.assertEquals(programList[0].Id+'Cross Collateralized', groupTaskList[0].nu_dse__Unique_Identifier__c);
    }
    // Test method to check created Group Task for updated Cross Collateralized Programs
    Public static testmethod void createCCGroupTaskUpdate_Test(){
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        programList[0].Cross_Collateralized__c = true;
        programList[0].Salesperson_ID__c = userInfo.getUserId();
        Test.startTest();
            // Updated Program with Cross Collateralized = true
            update programList;
        Test.stopTest();
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, OwnerId, Subject_Pick_List__c, nu_dse__ActivityDate__c, 
                                                        nu_dse__Related_To__c, nu_dse__Status__c, nu_dse__Unique_Identifier__c 
                                                     FROM nu_dse__Group_Task__c];
        List<nu_dse__Program__c> updatedProgramList = [SELECT Id, Salesperson_ID__c FROM nu_dse__Program__c WHERE Id = :programList[0].Id];
        // Checking created Group Task values
        system.assertEquals(updatedProgramList[0].Salesperson_ID__c, groupTaskList[0].OwnerId);
        system.assertEquals('Cross Collateralized', groupTaskList[0].Subject_Pick_List__c);
        system.assertEquals(system.today().addDays(14), groupTaskList[0].nu_dse__ActivityDate__c);
        system.assertEquals(updatedProgramList[0].Id, groupTaskList[0].nu_dse__Related_To__c);
        // system.assertEquals('Not Started', groupTaskList[0].nu_dse__Status__c);
        system.assertEquals(updatedProgramList[0].Id+'Cross Collateralized', groupTaskList[0].nu_dse__Unique_Identifier__c);
    } 

    // Test method to check updated Program Campaign Desposition and Campaign updated based on NSF/Sett Auth checkboxes
    Public static testmethod void updateProgramCampaign_Test(){
        
        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Processor__c> processor = [SELECT Id FROM nu_dse__Processor__c];
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        for(integer i=0; i < 10; i++) {
            nu_dse__Program__c program = TestRecordCreator.createProgram(acc[0].Id, processor[0].Id);
            programList.add(program);
        }
        insert programList;

        programList[0].NSF_Start__c = true;
        programList[1].NSF_Stop__c = true;
        programList[2].NSF_2_Start__c = true;
        programList[3].NSF_2_Stop__c = true;
        programList[4].NSF_Final_Start__c = true;
        programList[5].NSF_Final_Stop__c = true;
        programList[6].NSF_In_Settlement_Start__c = true;
        programList[7].NSF_In_Settlement_Stop__c = true;
        programList[8].Sett_Auth_Start__c = true;
        programList[9].Sett_Auth_Stop__c = true;

        Test.startTest();
            // Updated Program NSF/Sett Auth checkboxes
            update programList;
        Test.stopTest();

        List<nu_dse__Program__c> updatedProgramList = [SELECT Campaign_Disposition__c, Campaign_Updated__c 
                                                FROM nu_dse__Program__c WHERE Id IN :programList];
        // Checking Program Campaign Disposition and Campaign Updated values
        system.assertEquals('STARTNSF1', updatedProgramList[0].Campaign_Disposition__c );
        system.assertEquals(true, updatedProgramList[0].Campaign_Updated__c);
        system.assertEquals('STOPNSF1', updatedProgramList[1].Campaign_Disposition__c);
        system.assertEquals('STARTNSF2', updatedProgramList[2].Campaign_Disposition__c);
        system.assertEquals('STOPNSF2', updatedProgramList[3].Campaign_Disposition__c);
    }
    // Test method to check Task creation and related payment updates for Terminated Programs
    Public static testmethod void collectTerminatedPrograms_Test(){

        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        
        Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc[0].id, programList[0].Id);
        insert tradeLine;
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(programList[0].Id, tradeLine.Id, 100, 10, 25, 10);
        insert offer;
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        nu_dse__Payment__c payment = TestRecordCreator.createPayment(programList[0].Id, 'Scheduled', 'Deposit', draftRecordTypeId, offer.Id);
        insert payment;
        programList[0].nu_dse__Program_Status__c = 'Terminated';
        programList[0].nu_dse__Program_Sub_Status__c = 'NSF 1';
        Test.startTest();
            // Updated Program Status to Terminated
            update programList;
        Test.stopTest();

        List<Task> taskList = [SELECT Id, ActivityDate, Subject, Unique_Identifier__c,
                                   nu_dse__Is_System_Task__c, WhatId 
                                FROM Task];

        Map<String, Holiday> holidayMap = Holidays.getHolidaysMap();
        Date activityDate = Holidays.getNextWorkingDay(holidayMap, system.today());
        // Chaecking created Tasks
        system.assertEquals(activityDate, taskList[0].ActivityDate);
        system.assertEquals('Termination Confirmation Email', taskList[0].Subject);
        system.assertEquals(programList[0].Id + 'Termination Confirmation Email', taskList[0].Unique_Identifier__c);
        system.assertEquals(true, taskList[0].nu_dse__Is_System_Task__c);
        system.assertEquals(programList[0].Id, taskList[0].WhatId);
        // Checking Payment Status updates
        List<nu_dse__Payment__c> paymentList = [SELECT Id, nu_dse__Transaction_Status__c FROM nu_dse__Payment__c];
        system.assertEquals('Cancelled', paymentList[0].nu_dse__Transaction_Status__c);
    }
    // Test method to check related Prospect status updates for Did not sell Programs
    Public static testmethod void updateProspectStatus_Test(){

        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
        insert prospect;
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        programList[0].nu_dse__Program_Status__c = 'Did Not Sell';
        programList[0].Prospect_ID__c = prospect.Id;

        Test.startTest();
            // Updated Program status to Did Not Sell
            update programList;
        Test.stopTest();
        // Checking Prospect status updates
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, nu_dse__Prospect_Status__c FROM nu_dse__Prospect__c];
        system.assertEquals('Did Not Sell', prospectList[0].nu_dse__Prospect_Status__c);
    }
    // Test method to check Created Task and groupTask for Graduated Programs based on Program Email Address availability
    Public static testmethod void createGraduatedActivity_Test(){
        
        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Processor__c> processor = [SELECT Id FROM nu_dse__Processor__c];
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        programList[0].nu_dse__Program_Status__c  = 'Graduated';       
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc[0].Id, processor[0].Id);
        insert program;
        program.nu_dse__Program_Status__c  = 'Graduated';
        program.Email_Address__c = 'test@tset.com';
        program.ownerId = userInfo.getUserId();
        programList.add(program);

        Test.startTest();
            // Update Program Status to Graduated
            update programList;
        Test.stopTest();

        Map<String, Id> queueMap = PaymentHandler.getQueueMap();
        Map<String, Holiday> holidayMap = Holidays.getHolidaysMap();
        Date activityDate = Holidays.getNextWorkingDay(holidayMap, system.today());
        List<nu_dse__Communication_Template__c> commuTempList = [SELECT Id FROM nu_dse__Communication_Template__c];
        List<Task> taskList = [SELECT Id, ActivityDate, Subject, Unique_Identifier__c,
                                   nu_dse__Is_System_Task__c, WhatId, nu_dse__Communication_Template__c 
                                FROM Task WHERE WhatId =: programList[1].Id];
        // Checking Created Task values
        system.assertEquals(activityDate, taskList[0].ActivityDate);
        system.assertEquals('Email Grad Package', taskList[0].Subject);
        system.assertEquals(programList[1].Id + 'Email Grad Package', taskList[0].Unique_Identifier__c);
        system.assertEquals(true, taskList[0].nu_dse__Is_System_Task__c);
        system.assertEquals(programList[1].Id, taskList[0].WhatId);
        system.assertEquals(commuTempList[0].Id, taskList[0].nu_dse__Communication_Template__c); 

        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, ownerId, nu_dse__subject__c, nu_dse__ActivityDate__c, 
                                                        nu_dse__Related_To__c, nu_dse__Status__c, nu_dse__Unique_Identifier__c 
                                                     FROM nu_dse__Group_Task__c];
        // Checking Created Group task values
        system.assertEquals(queueMap.get('Mail_Queue'), groupTaskList[0].OwnerId);
        system.assertEquals('Mail Grad Package', groupTaskList[0].nu_dse__subject__c);
        system.assertEquals(activityDate, groupTaskList[0].nu_dse__ActivityDate__c);
        system.assertEquals(programList[0].Id, groupTaskList[0].nu_dse__Related_To__c);
        system.assertEquals(programList[0].Id+'Mail Grad Package', groupTaskList[0].nu_dse__Unique_Identifier__c);                                             
    } 
    // Test method to check Created Group Task for Termination Pending Programs based on  Involuntary Termination
    Public static testmethod void createTermPendingGroupTask_Test(){
        
        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Processor__c> processor = [SELECT Id FROM nu_dse__Processor__c];
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        programList[0].nu_dse__Program_Status__c  = 'Termination Pending';        
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc[0].Id, processor[0].Id);
        insert program;
        program.nu_dse__Program_Status__c  = 'Termination Pending';
        program.Involuntary_Termination__c = true;
        programList.add(program);

        Test.startTest();
            // Updated Program Status to Termination Pending
            update programList;
        Test.stopTest();

        Map<String, Id> queueMap = PaymentHandler.getQueueMap();

        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, ownerId, nu_dse__subject__c, nu_dse__ActivityDate__c, 
                                                        nu_dse__Related_To__c, nu_dse__Status__c, nu_dse__Unique_Identifier__c 
                                                     FROM nu_dse__Group_Task__c];
        // Checking created Group Task values
        system.assertEquals(queueMap.get('Termination_Request_CS'), groupTaskList[0].OwnerId);
        system.assertEquals('Termination Request', groupTaskList[0].nu_dse__subject__c);
        system.assertEquals(system.today(), groupTaskList[0].nu_dse__ActivityDate__c);
        system.assertEquals(programList[0].Id, groupTaskList[0].nu_dse__Related_To__c);
        system.assertEquals(programList[0].Id+'Termination Request', groupTaskList[0].nu_dse__Unique_Identifier__c); 
        system.assertEquals('Termination Request - INVOL', groupTaskList[1].nu_dse__subject__c);
        system.assertEquals(programList[1].Id+'Termination Request - INVOL', groupTaskList[1].nu_dse__Unique_Identifier__c); 
    }
    // Test method to check modify leads in Velocify
    Public static testmethod void modifyLeads_Async_Test(){
        
        List<Account> acc = [SELECT Id FROM Account];
        List<nu_dse__Processor__c> processor = [SELECT Id FROM nu_dse__Processor__c];

        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c> ();
        nu_dse__Data_Mapping__c dataMappingInstance1 = TestRecordCreator.createDataMapping('VelocifyProgram', '', '');
        nu_dse__Data_Mapping__c dataMappingInstance2 = TestRecordCreator.createDataMapping('VelocifyLead', '', '');
        dataMappingList.add(dataMappingInstance1);
        dataMappingList.add(dataMappingInstance2);
        insert dataMappingList;

        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c> ();
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead1 = TestRecordCreator.createFieldMapping(dataMappingInstance1.Id, 'Id',
                                                                                                          '498', False, null);
        nu_dse__Field_mapping__c fieldMappingInstanceVelocifyLead2 = TestRecordCreator.createFieldMapping(dataMappingInstance2.Id, 'nu_dse__Last_Disposition__c',
                                                                                                          '499', False, null);                                                                                     
        fieldMappingList.add(fieldMappingInstanceVelocifyLead1);
        fieldMappingList.add(fieldMappingInstanceVelocifyLead2);
        insert fieldMappingList;

        nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
        prospectInstance.velocify_id__c = '1';
        prospectInstance.uuid__c = '187.50';
        prospectInstance.nu_dse__Last_Disposition__c = 'Waiting on EA';
        insert prospectInstance;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc[0].Id, processor[0].Id);
        program.Velocify_Id__c = '1';
        program.Prospect_Lookup__c = prospectInstance.Id;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new ProspectTrigger_Test());
            // Inserted Program with Velocify Id
            insert program;
        Test.stopTest();
    }
    
    
    Public static testmethod void testCreateLoanTrigger(){    
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        
        insert testProgram;
    
        testProgram.Loan_Interest_Status__c = 'Interested - Skybridge';
        testProgram.Eligible_for_Skybridge__c = true;
        
        update testProgram;
    }

    Public static testmethod void savingsCalculationAPI_Test(){
        
        Test.startTest();

            nu_dse__Program__c program = [SELECT Id, Name FROM nu_dse__Program__c LIMIT 1];
            program.Original_Enrolled_Program_Debt__c = 1500;
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            update program;

        Test.stopTest();

        nu_dse__Program__c updatedProgram = [SELECT Savings_Calculated_Savings_Original__c, Savings_Months_to_Payoff_Original__c,
                                                Savings_Payoff_Amount_Original__c
                                            FROM nu_dse__Program__c LIMIT 1];

        system.assertEquals(18, updatedProgram.Savings_Months_to_Payoff_Original__c);   
        system.assertEquals(1071.0, updatedProgram.Savings_Payoff_Amount_Original__c);  
        system.assertEquals(271.0, updatedProgram.Savings_Calculated_Savings_Original__c); 
    }   

    //without custom settings ref
    Public static testmethod void savingsCalculationAPICS_Test(){
        
        Test.startTest();
            Savings_Calculator_Microservice__c savingCalcSettings = [SELECT Id FROM Savings_Calculator_Microservice__c WHERE InterestRate__c = 16.4 LIMIT 1];
            savingCalcSettings.Endpoint__c = '';
            savingCalcSettings.InterestRate__c = null;
            savingCalcSettings.Minimum_Payment__c = null;
            update savingCalcSettings;

            nu_dse__Program__c program = [SELECT Id, Name FROM nu_dse__Program__c LIMIT 1];
            program.Original_Enrolled_Program_Debt__c = 1500;
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            update program;
        Test.stopTest();

        nu_dse__Program__c updatedProgram = [SELECT Savings_Calculated_Savings_Original__c, Savings_Months_to_Payoff_Original__c,
                                                Savings_Payoff_Amount_Original__c
                                            FROM nu_dse__Program__c LIMIT 1];

        system.assertEquals(18, updatedProgram.Savings_Months_to_Payoff_Original__c);   
        system.assertEquals(1071.0, updatedProgram.Savings_Payoff_Amount_Original__c);  
        system.assertEquals(271.0, updatedProgram.Savings_Calculated_Savings_Original__c); 
    }   

    Public static testmethod void savingsCalculationAPIFail_Test(){
        
        Test.startTest();

            nu_dse__Program__c program = [SELECT Id, Name FROM nu_dse__Program__c LIMIT 1];
            program.Original_Enrolled_Program_Debt__c = -500;
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            update program;

        Test.stopTest();

        nu_dse__Program__c updatedProgram = [SELECT Savings_Calculation_Error_Original__c
                                            FROM nu_dse__Program__c LIMIT 1];

        system.assertEquals('Balance must be greater than 0', updatedProgram.Savings_Calculation_Error_Original__c);   
    }   

    Public static testmethod void savingsCalculationAPIException_Test(){
        
        Test.startTest();

            Savings_Calculator_Microservice__c savingCalcSettings = [SELECT Id FROM Savings_Calculator_Microservice__c WHERE InterestRate__c = 16.4 LIMIT 1];
            savingCalcSettings.Endpoint__c = 'http://';
            savingCalcSettings.InterestRate__c = null;
            savingCalcSettings.Minimum_Payment__c = null;
            update savingCalcSettings;

            nu_dse__Program__c program = [SELECT Id, Name FROM nu_dse__Program__c LIMIT 1];
            program.Original_Enrolled_Program_Debt__c = 0;
            Test.setMock(HttpCalloutMock.class,new TradelineTrigger_Test());
            update program;

        Test.stopTest();

        nu_dse__Program__c updatedProgram = [SELECT Savings_Calculation_Error_Original__c
                                            FROM nu_dse__Program__c LIMIT 1];

        system.assertEquals('System.CalloutException Unauthorized endpoint, please check Setup->Security->Remote site settings.', 
                    updatedProgram.Savings_Calculation_Error_Original__c);   
    } 
    
    // Create New Lender Application Data for Interested Program Enrolled Clients
    // Uses Loan Interest Status = "Interested" to Run
    public void createLoan(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram){
        if (newProgram.Loan_Interest_Status__c == 'Skybridge - Interested'){
            if(newProgram.Loan_Interest_Status__c != oldProgram.Loan_Interest_Status__c){
                //if(!newProgram.Flow_Initiated__c){
                    System.debug('loan if statement');
                    futureFlowCall(newProgram.Id);
                //}
            }
        }
    }
    
    //@future(callout=true)
    public static void futureFlowCall(string ProgramId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('ProgramId', ProgramId);
        try {
            Flow.Interview.Create_Loan Create_Loan = new Flow.Interview.Create_Loan(params);
            Create_Loan.start();
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }
}