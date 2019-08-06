@isTest
public class Batch_ABTestingProgram_Test {
    static testMethod void ABTestingProgram() {

        Id recId = [select id from recordType where sObjectType='Account' and developerName='Client'].id;  
        Account act = TestRecordCreator.createAccount('test', recId);
        insert act; 
        nu_dse__Processor__C p= TestRecordCreator.createProcessor('CFT');
        insert p; 
            
        nu_dse__Program__c  program = TestRecordCreator.createProgram(act.id, p.id);
        program.Language__c = 'German'; 
        program.nu_dse__Disposition__c = 'Call Completed';
        insert program;
        
        nu_dse__Data_Mapping__c ABTestingProspect = TestRecordCreator.ABTestingProgram();
        insert ABTestingProspect;
        system.debug('ABTestingProgramToProgram-->'+ABTestingProspect);
        
        List<nu_dse__Field_mapping__c> fieldMapping = TestRecordCreator.ABTestingFieldMap2(ABTestingProspect.Id);
        insert fieldMapping;
        
        Test.startTest();
            
            Database.executeBatch(new Batch_ABTestingProgram());
            
        Test.stopTest(); 
        
    }
}