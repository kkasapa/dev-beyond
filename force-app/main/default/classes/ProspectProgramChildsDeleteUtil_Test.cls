@isTest
public class ProspectProgramChildsDeleteUtil_Test {

    @isTest static void testDeleteProspectChildObject() {
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Monthly_Service_Fee__c = 10;
        insert processor;
        
        nu_dse__Fee_Template__c feeTemp = TestRecordCreator.createFeeTemplate();
        insert feeTemp;
        
        Id feeItemRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Fee_Item__c','Settlement Fee');
        nu_dse__Fee_Item__c feeItem = TestRecordCreator.createfeeItem(feeItemRecordTypeId, feeTemp.Id);
        insert feeItem;
        
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect(processor.Id);
        insert prospect;
        
        nu_dse__Financial_profile__c financialProfile = TestRecordCreator.createFinancialProfile(prospect.Id);
        insert financialProfile;
        
        nu_dse__Bank_Account__c bankAccount = TestRecordCreator.createBankAccount(null);
        bankAccount.nu_dse__prospect__c = prospect.Id;
        insert bankAccount;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(null, null);
        tradeLine.nu_dse__prospect__c = prospect.Id;
        insert tradeLine;
        
        prospect.Eligibility_Check_Ran__c = True;
        update prospect;
       
        nu_dse__Quote__c quote = TestRecordCreator.createQuote(prospect.Id);
        quote.nu_dse__Fee_Template__c = feeTemp.Id;
        quote.nu_dse__Status__c = 'Accepted';
        insert quote;
        
        nu_dse__Group_Task__c groupTask = TestRecordCreator.createGroupTask(prospect.Id);
        groupTask.Prospect__c = prospect.Id;
        insert groupTask;
        
        Attachment attach = TestRecordCreator.createAttachment(prospect.Id);
        insert attach;
        
        Test.startTest();
            
            ProspectProgramChildsDeleteUtil.deleteProspectProgramChilds(prospect.Id);
            
        Test.stopTest();  
        List<nu_dse__Prospect__c> prospectList = [SELECT Id FROM nu_dse__Prospect__c WHERE Id =:prospect.Id ];
        System.assertEquals(True, prospectList.isEmpty());     
        
        List<nu_dse__TradeLine__c> tradeList = [SELECT Id FROM nu_dse__TradeLine__c WHERE Id =:tradeLine.Id ];
        System.assertEquals(True, tradeList.isEmpty());     
    }
    
    @isTest static void testDeleteProgramChildObject() {
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        processor.nu_dse__Monthly_Service_Fee__c = 10;
        insert processor;
        
        nu_dse__Fee_Template__c feeTemp = TestRecordCreator.createFeeTemplate();
        insert feeTemp;
        
        Id feeItemRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Fee_Item__c','Settlement Fee');
        nu_dse__Fee_Item__c feeItem = TestRecordCreator.createfeeItem(feeItemRecordTypeId, feeTemp.Id);
        insert feeItem;
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account','Client');
        
        Account accountInstance = TestRecordCreator.createAccount('Program', clientRecordTypeId);
        insert accountInstance;
        
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect(processor.Id);
        insert prospect;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(accountInstance.Id, processor.Id);
        program.Prospect_ID__c = prospect.Id;
        insert program;
        
        nu_dse__Financial_profile__c financialProfile = TestRecordCreator.createFinancialProfile(null);
        financialProfile.nu_dse__Program__c = program.Id;
        insert financialProfile;
        
        nu_dse__Bank_Account__c bankAccount = TestRecordCreator.createBankAccount(program.Id);
        insert bankAccount;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(accountInstance.Id, program.Id);
        insert tradeLine;
        
        nu_dse__Offer__c offer = TestRecordCreator.createoffer(program.Id, tradeLine.Id, 500, 500, 5, 5);
        offer.nu_dse__Program__c = program.Id;
        insert offer;
        
        system.debug('offer--->'+offer);
        
        nu_dse__Group_Task__c groupTask = TestRecordCreator.createGroupTask(program.Id);
        groupTask.Program__c = program.Id;
        insert groupTask;
        
        Attachment attach = TestRecordCreator.createAttachment(program.Id);
        insert attach;
        
        Test.startTest();
            
            ProspectProgramChildsDeleteUtil.deleteProspectProgramChilds(program.Id);
            
        Test.stopTest();  
        
        List<nu_dse__Prospect__c> prospectList = [SELECT Id FROM nu_dse__Prospect__c WHERE Id =:prospect.Id ];
        System.assertEquals(True, prospectList.isEmpty());     
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c WHERE Id =:program.Id ];
        System.assertEquals(True, programList.isEmpty());  
        
        List<nu_dse__Offer__c> offerList = [SELECT Id FROM nu_dse__Offer__c WHERE Id =:offer.Id ];
        System.assertEquals(True, offerList.isEmpty());     
        
    }
    
}