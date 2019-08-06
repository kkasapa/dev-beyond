@istest	
public class QuoteHandler_Test {

    @testsetup
    public static void data(){
        
        Account a = new Account(); 
        
        a.firstName = 'Test'; 

        a.lastname = 'IDR'; 
        
        a.Phone = '6784567890'; 
        
        a.personemail = 'test@idr.com'; 
        
        a.recordTypeId = [select id from RecordType where sObjectType='Account' and isPersonType=true and DeveloperName='Client' limit 1].id;
        
        insert a; 
        
        
        nu_dse__Prospect__c prospect = new nu_dse__Prospect__c(); 
        
        prospect.nu_dse__First_Name__c = 'Test'; 
        
        prospect.nu_dse__Last_Name__c = 'TestLastname'; 
        
        prospect.Eligibility_Check_Ran__c = true; 
            
        Prospect.nu_dse__Initial_Debit_Date__c = System.date.today();
        
        Prospect.nu_dse__Payment_Frequency__c = 'Monthly';
        
        Prospect.nu_dse__Recurring_Payment_Day__c = System.date.today().Day();
            
        
        
        
        insert prospect; 
        
        nu_dse__Financial_Profile__c fp = new nu_dse__Financial_Profile__c(); 
        
        fp.nu_dse__Additional_Income__c = 10000; 
        
        fp.nu_dse__Hardship_Description__c = 'Testing';
        
        fp.nu_dse__Prospect__c = prospect.id;
        
        insert fp; 
        
        nu_dse__Fee_Template__c FeeTemplate = new nu_dse__Fee_Template__c(); 
        
        feeTemplate.Name = 'Test';
        feeTemplate.nu_dse__Settlement_Pct__c = 50; 
        
        insert FeeTemplate; 
        
        nu_dse__Fee_Item__c feeitem = new nu_dse__Fee_Item__c(); 
        
        feeitem.Name = 'settlement'; 
        
        feeitem.RecordTypeId = [select id from recordType where sObjectType='nu_dse__Fee_Item__c' and developername ='Settlement_Fee'].id;
        
        feeitem.nu_dse__Frequency__c = 'Monthly'; 
        
        feeitem.nu_dse__Percent__c = 25; 
        
        feeItem.nu_dse__Fee_Template__c = feeTemplate.id; 
        
        insert feeItem; 
        
        nu_dse__Processor__c processor = new nu_dse__Processor__c(); 
        
        processor.name = 'CFT'; 
        
        insert processor; 
        
        nu_dse__quote__c quote = new Nu_dse__Quote__c(); 
        
        quote.Extra_Amount__c = 215.00; 
        
        quote.nu_dse__Fee_Template__c = feeTemplate.Id; 
        
        quote.nu_dse__Payment_Frequency__c = 'Monthly';
        
        quote.nu_dse__Processor__c = processor.id; 
        
        quote.nu_dse__Program_Length__c = 24; 
        
        quote.nu_dse__Prospect__c = prospect.id; 
            
        insert quote; 
        
       
    }
    
    public static testmethod void test1(){

       List<nu_dse__quote__c> updatedQuotes = new List<nu_dse__quote__c>();

       List<id> prospectId = new list<id>(0);
        
        for(nu_dse__quote__c q : [select id,nu_dse__Status__c,nu_dse__Prospect__c  from nu_dse__quote__c ]){
            
            
            q.nu_dse__Status__c = 'Accepted';
            
           updatedQuotes.add(q);
            
            prospectId.add(q.nu_dse__Prospect__c);
            
        }
        
        update updatedQuotes; 
        
        for(nu_dse__Prospect__c p : [select id,Extra_Amount__c from nu_dse__Prospect__c where id in: prospectId]){
            
            System.assert(p.Extra_Amount__c != null);
        }
    }
    
      public static testmethod void test2(){

       List<nu_dse__quote__c> updatedQuotes = new List<nu_dse__quote__c>();

       List<id> prospectId = new list<id>(0);
        
        for(nu_dse__quote__c q : [select id,nu_dse__Status__c,nu_dse__Prospect__c  from nu_dse__quote__c ]){
            
            
            q.nu_dse__Status__c = 'Rejected';
            
           updatedQuotes.add(q);
            
            prospectId.add(q.nu_dse__Prospect__c);
            
        }
        
        update updatedQuotes; 
        
        
    }
    
    public static testmethod void test3(){
        
       nu_dse__Fee_Template__c feeTemplate = [select id from nu_dse__Fee_Template__c where name = 'Test' limit 1];
        
       nu_dse__Processor__c processor = [select id from nu_dse__Processor__c where name='CFT' limit 1];
       
       nu_dse__Prospect__c  prospect = [select id from nu_dse__Prospect__c limit 1];
         nu_dse__quote__c quote= new Nu_dse__Quote__c(); 
        
        quote.Extra_Amount__c = 215.00; 
        
        if(feeTemplate !=null)
        quote.nu_dse__Fee_Template__c = feeTemplate.Id; 
        
        quote.nu_dse__Payment_Frequency__c = 'Monthly';
        
        if(processor !=null) quote.nu_dse__Processor__c = processor.id; 
        
        quote.nu_dse__Program_Length__c = 24; 
        
        if(prospect !=null) quote.nu_dse__Prospect__c = prospect.id; 
            
        quote.nu_dse__Status__c = 'Accepted'; 
        
        insert quote; 
        
         nu_dse__quote__c quote2= new Nu_dse__Quote__c(); 
        
        quote2.Extra_Amount__c = 215.00; 
        
        if(feeTemplate !=null)
        quote2.nu_dse__Fee_Template__c = feeTemplate.Id; 
        
        quote2.nu_dse__Payment_Frequency__c = 'Monthly';
        
        if(processor !=null) quote2.nu_dse__Processor__c = processor.id; 
        
        quote2.nu_dse__Program_Length__c = 24; 
        
        if(prospect !=null) quote2.nu_dse__Prospect__c = prospect.id; 
            
        quote2.nu_dse__Status__c = 'Accepted'; 
        
        insert quote2; 
    }
}