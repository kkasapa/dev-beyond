@isTest
public with sharing class HealthTabPage_Test {
    
    @testSetup static void setupMethod() {
        
        Id recordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        Account accountInstance = TestRecordCreator.createAccount('HealthTabAccount', recordTypeId);
        
        insert accountInstance;
        
        recordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Creditor');
        Account accountCreditorInstance = TestRecordCreator.createCreditorAccount(recordTypeId);
        accountCreditorInstance.nu_dse__CFT_Payee_Id__c = '1234567'; 
        accountCreditorInstance.nu_dse__CFT_Payee_Address_Id__c = '11111'; 
        accountCreditorInstance.nu_dse__CFT_Synced__c = True; 
        
        insert accountCreditorInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('CFT');
        
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);
        
        insert programInstance;
        
        
        nu_dse__TradeLine__c tradeLineInstance = TestRecordCreator.createTradeLine(accountCreditorInstance.Id, programInstance.Id);
        
        insert tradeLineInstance;
        
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id, tradeLineInstance.Id, 1000, 1000, 10, 10);
        
        insert offerInstance;
        
    }
    
    @isTest
    public static void updateLanguageInProgramTest () {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id, Language__c FROM nu_dse__Program__c];
        
        Test.startTest();
        
        LanguageDetailsController langControllerInstance = new LanguageDetailsController();
        langControllerInstance.recordId = programInstanceList[0].Id;
        
        langControllerInstance.programInstance.Language__c = 'Spanish';
        langControllerInstance.updateProgram();
        
        Test.stopTest();
        
        System.assertEquals('Spanish',langControllerInstance.programInstance.Language__c);
        
    }
    
    @isTest
    public static void deleteStickyNotesTest() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Task task1 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task2 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task3 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task4 = TestRecordCreator.createTask(programInstanceList[0].Id);
        
        List<Task> taskList = new List<Task>();
        taskList.add(task1);
        taskList.add(task2);
        taskList.add(task3);
        taskList.add(task4);
        
        insert taskList;
        
        StickyNotesController stickyNotesctrlInstance = new StickyNotesController();
        
        Test.startTest();
         
        StickyNotesController.getNotes(programInstanceList[0].Id);
        
        StickyNotesController.deleteNote(taskList[3].Id);
        
        Test.stopTest();
        
        List<Task> taskList1 = [SELECT Id from Task];
        
        System.assertEquals(taskList.size()-1,taskList1.size());
             
    }
    
    @isTest
    public static void getPaymentsInfo() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id, nu_dse__Program_Length__c FROM nu_dse__Program__c LIMIT 1];
        List<nu_dse__Offer__c> offerInstanceList = [SELECT Id FROM nu_dse__Offer__c LIMIT 1];
        
        Id draftRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        Id settlementRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Completed', 'Deposit', draftRecordTypeId, offerInstanceList[0].Id);
        nu_dse__Payment__c paymentInstance2 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Cleared', 'Withdrawal', settlementRecordTypeId, offerInstanceList[0].Id);
        nu_dse__Payment__c paymentInstance3 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Completed', 'Deposit', draftRecordTypeId, offerInstanceList[0].Id);
        nu_dse__Payment__c paymentInstance4 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Pending', 'Deposit', draftRecordTypeId, offerInstanceList[0].Id);
        nu_dse__Payment__c paymentInstance5 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Failed', 'Deposit', draftRecordTypeId, offerInstanceList[0].Id);
        nu_dse__Payment__c paymentInstance6 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Completed', 'Deposit', draftRecordTypeId, offerInstanceList[0].Id);
        paymentInstance6.nu_dse__Dont_Consider__c = false;
        
        List<nu_dse__Payment__c> paymentInstanceList = new List<nu_dse__Payment__c>();
        
        paymentInstanceList.add(paymentInstance1);
        paymentInstanceList.add(paymentInstance2);
        paymentInstanceList.add(paymentInstance3);
        paymentInstanceList.add(paymentInstance4);
        paymentInstanceList.add(paymentInstance5);
        paymentInstanceList.add(paymentInstance6);
        
        insert paymentInstanceList;
        
        Test.startTest();
        
        PaymentInfoController.PaymentInfo infoInstance = PaymentInfoController.getPaymentsInfo(programInstanceList[0].Id);
        
        Test.stopTest();
        
        System.assertEquals(programInstanceList[0].nu_dse__Program_Length__c, infoInstance.programLength);
        
    }
    
    @isTest
    public static void getTaskList() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Task task1 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task2 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task3 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task4 = TestRecordCreator.createTask(programInstanceList[0].Id);
        
        List<Task> taskList = new List<Task>();
        taskList.add(task1);
        taskList.add(task2);
        taskList.add(task3);
        taskList.add(task4);
        
        for (Task tk : taskList) {
            
            //tk.CallType = 'Call';
        }
        
        insert taskList;
        
        Test.startTest();
        
        List<TaskViewController.TaskWraper> taskWrapperList = TaskViewController.getTaskList(programInstanceList[0].Id);
        
        Test.stopTest();
        
        System.assertEquals(0, taskWrapperList.size());
        
    }
    
    @isTest
    public static void getStatusComponent() {
        
       List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
       nu_dse__Bank_Account__c bankAccountInstance = TestRecordCreator.createBankAccount(programInstanceList[0].Id);
       
       insert bankAccountInstance;
       
       Test.startTest();
       
       StatusComponentController.StatusWraper statusWrapperInstance = StatusComponentController.getStatus(programInstanceList[0].Id);
       
       Test.stopTest();
       
       System.assertEquals(false, statusWrapperInstance.processorStatus.active);
       
    }
    
    @isTest
    public static void getPaymentsComponent() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Id draftRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Pending', 'Deposit', draftRecordTypeId, null );
        nu_dse__Payment__c paymentInstance2 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Failed', 'Deposit', draftRecordTypeId, null );
        nu_dse__Payment__c paymentInstance3 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Failed', 'Deposit', draftRecordTypeId, null );
        paymentInstance3.nu_dse__Schedule_Date__c = system.today().addDays(-1);
        nu_dse__Payment__c paymentInstance4 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Failed', 'Deposit', draftRecordTypeId, null );
        paymentInstance4.nu_dse__Schedule_Date__c = null;
        
        List<nu_dse__Payment__c> paymentInstanceList = new List<nu_dse__Payment__c>();
        
        paymentInstanceList.add(paymentInstance1);
        paymentInstanceList.add(paymentInstance2);
        paymentInstanceList.add(paymentInstance3);
        paymentInstanceList.add(paymentInstance4);
        
        
        insert paymentInstanceList;
        
        Test.startTest();
        
        List<PymentStatusComponentController.Payment> paymentStatusInstanceList = PymentStatusComponentController.getPayments(programInstanceList[0].Id);
        
        Test.stopTest();
        
        System.assertEquals(false,paymentStatusInstanceList[0].completed);
    }
    
    @isTest
    public static void getCreditorsComponent() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        List<Account> creditorAccountInstanceList = [SELECT Id FROM Account WHERE nu_dse__CFT_Synced__c = True];
        
        nu_dse__TradeLine__c tradeLineInstance = [SELECT Id, Name, nu_dse__Original_Creditor__c, Balance_Verified__c, nu_dse__Include_In_The_Program__c FROM nu_dse__TradeLine__c];
        
        tradeLineInstance.nu_dse__Original_Creditor__c = null;
        tradeLineInstance.nu_dse__New_Creditor__c = creditorAccountInstanceList[0].Id;
        tradeLineInstance.Balance_Verified__c = false;
        tradeLineInstance.nu_dse__Include_In_The_Program__c = true;
        tradeLineInstance.nu_dse__Program__c = programInstanceList[0].Id;
        
        System.debug('tradeLineInstance:'+tradeLineInstance);
        
        update tradeLineInstance;
        
        Test.startTest();
            
            List<CreditorComponentController.Creditor> creditorWrapperList = CreditorComponentController.getCreditors(programInstanceList[0].Id);
            
        Test.stopTest();
        
        System.assertEquals(false, creditorWrapperList[0].verified);
    }
    
    @isTest
    public static void getOfferComponent() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        List<nu_dse__Offer__c> offerInstanceList = [SELECT Id, Name, nu_dse__Status__c FROM nu_dse__Offer__c ];
        offerInstanceList[0].Sub_Status__c = 'Out For Authorization';
        
        update offerInstanceList;
        
        Test.startTest();
            
            List<OfferStatusComponentController.Offer> offerWrapperInstanceList = OfferStatusComponentController.getOffer(programInstanceList[0].Id);
            
        Test.stopTest();
        
        System.assertEquals(offerInstanceList[0].Id, offerWrapperInstanceList[0].recordId);
        
    } 
    
    @isTest
    public static void getCampaignTasksComponent() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Task task1 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task2 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task3 = TestRecordCreator.createTask(programInstanceList[0].Id);
        Task task4 = TestRecordCreator.createTask(programInstanceList[0].Id);
        
        List<Task> taskList = new List<Task>();
        taskList.add(task1);
        taskList.add(task2);
        taskList.add(task3);
        taskList.add(task4);
        
        for (Task tk : taskList) {
            
            tk.Five9__Five9SessionId__c = '123456789';
        }
        
        insert taskList;
        
        Test.startTest();
            
        List<CampaignCallsComponentController.CampaignTaskWrapper> campaignTaskWrapperList = CampaignCallsComponentController.getCampaignTasks(programInstanceList[0].Id);
            
        Test.stopTest();
        
        System.assertEquals(taskList.size(), campaignTaskWrapperList.size() );
        
    } 
    
   // @isTest
    public static void getSettlmentPaymentsTest() {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        List<nu_dse__Offer__c> offerInstanceList = [SELECT Id, Name, nu_dse__Status__c FROM nu_dse__Offer__c ]; 
        offerInstanceList[0].nu_dse__Status__c = 'Accepted';
        
        update offerInstanceList;
        
        Id settlementRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Pending', 'Withdrawal', settlementRecordTypeId, offerInstanceList[0].Id );
        nu_dse__Payment__c paymentInstance2 = TestRecordCreator.createPayment(programInstanceList[0].Id, 'Pending', 'Withdrawal', settlementRecordTypeId, offerInstanceList[0].Id );
       
        List<nu_dse__Payment__c> paymentInstanceList = new List<nu_dse__Payment__c>();
        
        paymentInstanceList.add(paymentInstance1);
        paymentInstanceList.add(paymentInstance2);
        
        
        insert paymentInstanceList;
        
        Test.startTest();
            
           List<ActiveSettlementsComponentController.SettlementPaymentWrapper> wrapperPaymentList = ActiveSettlementsComponentController.getSettlmentPayments(programInstanceList[0].Id);
            
        Test.stopTest();
        
        System.AssertEquals(1, wrapperPaymentList.size());
    }
    
}