@istest
public class PaymentHandler_Test {

    @testsetup
    public static void testData(){
        
        List<RecordType> accRecTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND isPersonType = true and DeveloperName = 'Client' LIMIT 1];
        
        Account acc = new Account(firstName = 'Test', lastname = 'IDR', Phone = '6784567890', personemail = 'test@idr.com', 
                                  recordTypeId = accRecTypeList[0].id);
        insert acc; 
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c> {
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 1, Last_Call_Recording__c = 'Test NSF Record'),
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 2, Last_Call_Recording__c = 'Test NSF Record'),
            new nu_dse__Program__c(nu_dse__Account__c = acc.Id, nu_dse__In_Settlement__c = false, Salesperson_ID__c = UserInfo.getUserId(), 
                                   nu_dse__Consecutive_NSF_Payments__c = 3, Last_Call_Recording__c = 'Test NSF Record')
        };
        insert programList; 
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>(); 
        
        for (integer i=0; i<10; i++){
            
            nu_dse__Payment__c payment1 = new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(i), nu_dse__Amount__c = 100.00 + i, 
                                                                 nu_dse__Monthly_Other_Fee__c = 10.00, nu_dse__Program__c = programList[0].id, 
                                                                 nu_dse__Transaction_Status__c = 'In Progress', NSF_Date__c = System.date.today().addDays(i)); 
            nu_dse__Payment__c payment2 = new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(i + 10), nu_dse__Amount__c = 200.00 + i, 
                                                                 nu_dse__Monthly_Other_Fee__c = 20.00, nu_dse__Program__c = programList[1].id, 
                                                                 nu_dse__Transaction_Status__c = 'In Progress', NSF_Date__c = System.date.today().addDays(i + 10));
            nu_dse__Payment__c payment3 = new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(i + 20), nu_dse__Amount__c = 300.00 + i, 
                                                                 nu_dse__Monthly_Other_Fee__c = 30.00, nu_dse__Program__c = programList[2].id, 
                                                                 nu_dse__Transaction_Status__c = 'In Progress', NSF_Date__c = System.date.today().addDays(i + 20));
            paymentList.add(payment1);
            paymentList.add(payment2);
            paymentList.add(payment3); 
        }  
        insert paymentList; 
        
        List<nu_dse__Communication_Template__c> commTempList = new List<nu_dse__Communication_Template__c>{
            new nu_dse__Communication_Template__c(Name = 'NSF SMS'),
            new nu_dse__Communication_Template__c(Name = 'NSF EMAIL'),
            new nu_dse__Communication_Template__c(Name = 'NSF SMS BEYOND FINANCE Second Attempt'),
            new nu_dse__Communication_Template__c(Name = 'NSF No Contact Email'),
            new nu_dse__Communication_Template__c(Name = 'Review Payment Authorization')
        };
        insert commTempList;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(acc.id, programList[0].Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(programList[0].Id, tradeLine.Id, 100, 10, 25, 10);
        insert offer;
        
        Group grp = new Group(Name = 'Payment_Authorization');
        insert grp;
    }
        
    public static testmethod void payment_Inserttest() {
        
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        List<nu_dse__Offer__c> offerList = [SELECT Id FROM nu_dse__Offer__c LIMIT 1];
        nu_dse__Program__c Program = [SELECT Id, nu_dse__In_Settlement__c FROM nu_dse__Program__c LIMIT 1];
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c> {
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(1), nu_dse__Amount__c = 100.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, nu_dse__Program__c = program.id, 
                                   nu_dse__Transaction_Status__c = 'Completed', nu_dse__Payment_Sequence_Number__c = 1),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(2), nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, nu_dse__Program__c = program.id, 
                                   nu_dse__Transaction_Status__c = 'Failed', nu_dse__Payment_Sequence_Number__c = 1),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(3), nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, nu_dse__Program__c = program.id, nu_dse__Dont_Consider__c = true,
                                   nu_dse__Transaction_Status__c = 'Failed', nu_dse__Payment_Sequence_Number__c = 2),
            new nu_dse__Payment__c(nu_dse__Schedule_Date__c = System.date.today().addDays(2), nu_dse__Amount__c = 101.00, 
                                   nu_dse__Monthly_Other_Fee__c = 10.00, nu_dse__Program__c = program.id, RecordTypeId = settlementRecordTypeId, 
                                   nu_dse__Transaction_Status__c = 'Failed', Verbal_Authorization_Received__c = true, nu_dse__Offer__c = offerList[0].Id)
        };
        insert paymentList;                                                         
        
    }
    
    public static testmethod void beforeUpdate_test() {
    
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c WHERE nu_dse__Dont_Consider__c = false];
        if(paymentsList.size()>0){
        
            List<nu_dse__Payment__c> payments = new List<nu_dse__Payment__c>{
                new nu_dse__Payment__c(Id = paymentsList[0].Id, nu_dse__Transaction_Status__c = 'Completed', nu_dse__Payment_Sequence_Number__c = 1),
                new nu_dse__Payment__c(Id = paymentsList[1].Id, nu_dse__Transaction_Status__c = 'Completed', nu_dse__Payment_Sequence_Number__c = 2),
                new nu_dse__Payment__c(Id = paymentsList[3].Id, nu_dse__Transaction_Status__c = 'Completed', nu_dse__Payment_Sequence_Number__c = 3),
                new nu_dse__Payment__c(Id = paymentsList[6].Id, nu_dse__Transaction_Status__c = 'Completed', nu_dse__Payment_Sequence_Number__c = 4)
            };
            update payments;
            
            List<nu_dse__Payment__c> updatedPaymentsList = [SELECT Id, Manager_Email__c FROM nu_dse__Payment__c WHERE Id = :payments[0].Id];
            
            List<User> userList = [SELECT Id, Beyond_Manager_Email__c FROM User WHERE Id = :UserInfo.getUserId()];
            
            System.assertEquals(userList[0].Beyond_Manager_Email__c, updatedPaymentsList[0].Manager_Email__c);
        }
    }
    
    public static testmethod void updateProgramNSFStartStop_Updatetest() {
    
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c WHERE nu_dse__Dont_Consider__c = false];
                                                 
        if(paymentsList.size()>0){
        
            List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>{
                new nu_dse__Payment__c(Id = paymentsList[0].Id, nu_dse__Transaction_Status__c = 'Failed'),
                new nu_dse__Payment__c(Id = paymentsList[1].Id, nu_dse__Transaction_Status__c = 'Failed'),
                new nu_dse__Payment__c(Id = paymentsList[2].Id, nu_dse__Transaction_Status__c = 'Failed'),
                new nu_dse__Payment__c(Id = paymentsList[3].Id, nu_dse__Transaction_Status__c = 'Failed', nu_dse__Dont_Consider__c = true),
                new nu_dse__Payment__c(Id = paymentsList[4].Id, nu_dse__Transaction_Status__c = 'Failed', nu_dse__Dont_Consider__c = true),
                new nu_dse__Payment__c(Id = paymentsList[5].Id, nu_dse__Transaction_Status__c = 'Failed', nu_dse__Dont_Consider__c = true)                         
            }; 
            
            Test.startTest();
            update paymentList;
            Test.stopTest();
            
            List<nu_dse__Program__c> programList = [SELECT Id, NSF_Start__c, NSF_Stop__c FROM nu_dse__Program__c WHERE Id = :paymentsList[0].nu_dse__Program__c];
            System.assertEquals(false, programList[0].NSF_Start__c);
            System.assertEquals(true, programList[0].NSF_Stop__c);
        }
    }
    
    public static testmethod void updateProgramNSFStartStop_UpdateFailtest() {
    
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c WHERE nu_dse__Dont_Consider__c = false];
                                                 
        if(paymentsList.size()>0){
        
            List<nu_dse__Communication_Template__c> commuTempList = [SELECT Id FROM nu_dse__Communication_Template__c];
            delete commuTempList;
            nu_dse__Payment__c paymenInst = new nu_dse__Payment__c(Id = paymentsList[0].Id, nu_dse__Transaction_Status__c = 'Failed');
            update paymenInst;
            
            List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Message__c FROM nu_dse__Error_Log__c 
                                                       WHERE nu_dse__Error_Causing_Record_Id__c = :paymentsList[0].Id];
            System.assert(errorLogList[0].nu_dse__Message__c.contains('Following Communication Templates were missing:'));                                           
        }
    }
    
    public static testmethod void createVerbalAuthGroupTask_Updatetest() {
    
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c WHERE nu_dse__Dont_Consider__c = false];
        if(paymentsList.size()>0) {
            Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
            List<nu_dse__Offer__c> offerList = [SELECT Id FROM nu_dse__Offer__c offer LIMIT 1];
            nu_dse__Payment__c paymenInst = new nu_dse__Payment__c(Id = paymentsList[0].Id, Verbal_Authorization_Received__c = true,
                                                                   RecordTypeId = settlementRecordTypeId, nu_dse__Offer__c = offerList[0].Id);
            update paymenInst;
            
            List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, nu_dse__Related_To__c, nu_dse__subject__c  FROM nu_dse__Group_Task__c
                                                         WHERE nu_dse__Related_To__c = :paymentsList[0].Id];
            System.assertEquals('Review Payment Authorization', groupTaskList[0].nu_dse__subject__c);
        }
    }
    
    /*public static testmethod void DarthMaulCancelPaymentReminders_Updatetest() {
    
        List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c WHERE nu_dse__Dont_Consider__c = false];
        if(paymentsList.size()>0) {
        
        Test.startTest();
            Task taskInst = new Task(whatId = paymentsList[0].Id, Subject = 'Payments Reminder SMS Task', ActivityDate = system.Today().addDays(1),
                                      Unique_Identifier__c = paymentsList[0].Id+'Payments Reminder SMS',nu_dse__Is_System_Task__c = true);
            insert taskInst;
            nu_dse__Payment__c paymenInst = new nu_dse__Payment__c(Id = paymentsList[0].Id, nu_dse__Transaction_Status__c = 'Cancelled');
            update paymenInst;
            Test.stopTest();
            List<Task> taskList = [SELECT Id, Status FROM Task WHERE WhatId = :paymentsList[0].Id];
            System.assert(taskList.isEmpty() == true);
        }
    } */
    
     public static testmethod void updateProgramNextDraftDate_Updatetest() {
     
         List<nu_dse__Payment__c> paymentsList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Dont_Consider__c 
                                                 FROM nu_dse__Payment__c LIMIT 2];
                                                 
         paymentsList[0].nu_dse__Transaction_Status__c = 'Scheduled';
         paymentsList[0].nu_dse__Schedule_Date__c = system.today().addDays(3);
         update paymentsList;
         
         List<nu_dse__Program__c> programList = [SELECT Next_Draft_Date__c FROM nu_dse__Program__c
                                                 WHERE Id = :paymentsList[0].nu_dse__Program__c];
         System.assertEquals(paymentsList[0].nu_dse__Schedule_Date__c, programList[0].Next_Draft_Date__c);
         
         paymentsList[0].nu_dse__Transaction_Status__c = 'Completed';
         paymentsList[0].nu_dse__Schedule_Date__c = system.today().addDays(3);
         update paymentsList;
         
         List<nu_dse__Program__c> completedProgramList = [SELECT Next_Draft_Date__c FROM nu_dse__Program__c
                                                 WHERE Id = :paymentsList[0].nu_dse__Program__c];
         System.assertEquals(null, completedProgramList[0].Next_Draft_Date__c);
     }

     /*static testMethod void taskActivityDateTest(){
        
        nu_dse__Payment__c paymentInst = [SELECT Id, nu_dse__Schedule_Date__c
                                          FROM nu_dse__Payment__c LIMIT 1];
        
        List<Task> taskList = new List<Task>();
        for(Integer i = 1; i <= 2; i ++){
            Task taskInst = new Task();
            taskInst.WhatId = paymentInst.Id;
            taskInst.ActivityDate = system.today();
            if(math.mod(i, 2) == 0){
                taskInst.Subject = 'SMS REMINDER';
                taskInst.Unique_Identifier__c = 'Payment Reminder - SMS 1';
            }
            else{
                taskInst.Subject = 'EMAIL REMINDER';
                taskInst.Unique_Identifier__c = 'Payment Reminder - Email 1';
            }
            taskList.add(taskInst);
        }
        insert taskList;
        
        Test.startTest();
            paymentInst.nu_dse__Schedule_Date__c = system.today().addDays(7);
            paymentInst.nu_dse__Transaction_Status__c = 'Pending'; 
            update paymentInst;
        Test.stopTest();
        
        List<Task> updatedTaskList = [SELECT Id, ActivityDate FROM Task 
                                      WHERE WhatId = :paymentInst.Id];
        System.assertEquals(system.today().addDays(5), updatedTaskList[0].ActivityDate);  
    }*/
}