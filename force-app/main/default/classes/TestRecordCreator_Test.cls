@istest
public class TestRecordCreator_Test {

    public testmethod static void createAccountTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
    }
     public testmethod static void createCreditorAccountTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Creditor'].id;
         Account act = TestRecordCreator.createCreditorAccount(recId);
        
        insert act; 
    }

 	public testmethod static void createProspectTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Creditor'].id;
         Account act = TestRecordCreator.createCreditorAccount(recId);
        
        insert act; 
     
     nu_dse__prospect__c p = TestRecordCreator.createProspect();
    }    
    
    public testmethod static void createProgramtest(){
         
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
        
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
        
    }
    
     public testmethod static void createTaskTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
         
         Task t = TestRecordCreator.createTask(act.id);
         insert t; 
    }
    
    public testmethod static void createTradeLineTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
        Account act = TestRecordCreator.createAccount('Test',recId);
        insert act; 
         
         
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
        
        nu_dse__Tradeline__c t = TestRecordCreator.createTradeLine(act.id, program.Id);
        insert t;
    }
    
    
    public testmethod static void createOfferTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
        
          
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
        
        nu_dse__Tradeline__c t = TestRecordCreator.createTradeLine(act.id, program.Id);
        insert t;
        
       nu_dse__Offer__c offer =  TestRecordCreator.createoffer(program.Id, t.id, 100, 25, 10, 10);
        
        insert offer; 
    }
    
    
     public testmethod static void createPaymentTest(){
        
       Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
        
          
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
        
        nu_dse__Tradeline__c t = TestRecordCreator.createTradeLine(act.id, program.Id);
        insert t;
         
           nu_dse__Offer__c offer =  TestRecordCreator.createoffer(program.Id, t.id, 100, 25, 10, 10);
        
        insert offer; 
        
         id draftid = [select id from RecordType where sObjectType='nu_dse__Payment__c' and developername='Draft'].id;
         
        nu_dse__Payment__c payment= TestRecordCreator.createPayment(program.Id, 'Pending', 'Deposit', draftid, offer.id);
         
         insert payment; 
    }
    
    
    public testmethod static void getRecordTypeIdTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
        
        Id paymentrecId =TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
    }
    
      public testmethod static void createBankAccountTest(){
        
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
         Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
          
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
        
        
        nu_dse__Bank_Account__c bank =TestRecordCreator.createBankAccount(program.Id);
          bank.Holder_Zip__c = '12345';
          insert bank; 
    }
    
    public testmethod static void ABTestingTest(){
        
       nu_dse__Data_Mapping__c DM1= TestRecordCreator.ABTestingProspect(); 
        insert DM1; 
       nu_dse__Data_Mapping__c DM2 = TestRecordCreator.ABTestingProgram();
        insert DM2;
        
          List<nu_dse__Field_mapping__c> fm1= TestRecordCreator.ABTestingFieldMap(DM1.id);
           insert fm1; 
        
          List<nu_dse__Field_mapping__c> fm2=TestRecordCreator.ABTestingFieldMap2(DM2.id);
          insert fm2; 
        
    }
    
    public testmethod static void createLoanApptest(){
          
        Id recid = [select id from RecordType where sObjectType='Account' and Developername='Client'].id;
        Account act = TestRecordCreator.createAccount('Test',recId);
        
        insert act; 
        
        nu_dse__Processor__c p = TestRecordCreator.createProcessor('CFT');
        insert p;
        nu_dse__Program__c program = TestRecordCreator.createProgram(act.Id, p.id);
        insert program; 
          
        loan_application__c loan = TestRecordCreator.createLoanApplication(program.id);
        insert loan;
    }
}