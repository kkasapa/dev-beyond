@istest
public class UpdateProspectPhone_Test2 {

     
    @testsetup
    public static void testData(){
        
        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>(); 
       
        nu_dse__Prospect__c prospect = new nu_dse__Prospect__c(); 
        prospect.nu_dse__First_Name__c = 'Test'; 
        prospect.nu_dse__Last_name__c = 'LastName'; 
        prospect.nu_dse__Work_Phone__c = '727-123-12345'; 
        prospect.nu_dse__Cell_Phone__c = '789-123-9876';  
        prospect.nu_dse__Home_Phone__c = '727-789-9876';
        //prospectList.add(prospect);
       
        
        insert prospect; 
        
        Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();


        LIst<account> accountList = new LIst<account>(); 
        LIst<nu_dse__Program__c> programs = new List<nu_dse__Program__c>();
            
            Account a = new Account(); 
            a.FirstName = prospect.nu_dse__First_Name__c;
            a.LastName = prospect.nu_dse__Last_name__c; 
            a.nu_dse__Work_Phone__c = prospect.nu_dse__Work_Phone__c; 
            a.nu_dse__Cell_phone__c = prospect.nu_dse__Cell_Phone__c;
            a.nu_dse__Cell_phone__c = '999-888-7779';
            a.nu_dse__Home_Phone__c = '727-098-7890';
            a.nu_dse__Best_Phone__c = '666-123-4321';
            a.nu_dse__CO_Cell_Phone__c='897-345-7890';
            a.nu_dse__CO_Cell_Phone__c ='876-987-9876';
            a.nu_dse__CO_Best_Phone__c = '727-145-1456';
            a.nu_dse__CO_Home_Phone__c ='727-345-6789';
            
            // using GCS Id for extenal field, there is not other external Field available. 
            a.nu_dse__External_GCS_ID__c = prospect.Id; 
            a.RecordTypeId = clientRecordTypeId; 
           
            insert a; 
        
            nu_dse__Program__c  program = new nu_dse__Program__c();
            program.nu_dse__Account__c = a.id; 
            program.Prospect_ID__c = prospect.id;
           
        
        insert program; 
    }

    public testmethod static void testcase1(){
        
        List<Account> accountlist = new List<Account>(); 
        List<UpdatePhonenumbers.UpdatePhoneRequest> request = new List<UpdatePhonenumbers.UpdatePhoneRequest>();
        
        for(Account a: [select id from Account]){
            
            accountlist.add(a); 
        }
        UpdatePhonenumbers.UpdatePhoneRequest r = new UpdatePhonenumbers.UpdatePhoneRequest(); 

        r.accountId = accountLIst[0].id;
        
        request.add(r);

        UpdatePhonenumbers.invoke(request);
    }
}