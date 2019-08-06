@isTest
public class UpdatePhonenumbers_Test {
    
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
        List<account> updatedAccounts = new List<account>();
        Map<id,Account> accountsMap = new Map<id,Account>();
        List<id> prospectIds = new List<id>(); 
        map<id,id> prospectToAccountMap = new map<id,id>(); 
        
        integer i = 0; 
        for(Account a: [Select nu_dse__Work_Phone__c,nu_dse__Cell_phone__c from Account  ]){
            
            a.nu_dse__Cell_phone__c = '999-888-777'+string.valueOf(i);
            a.nu_dse__Home_Phone__c = '727-098-789'+string.valueOf(i);
            a.nu_dse__Best_Phone__c = '666-123-432'+string.valueOf(i);
            a.nu_dse__CO_Cell_Phone__c='897-345-7890';
            a.nu_dse__CO_Cell_Phone__c ='876-987-9876';
            a.nu_dse__CO_Best_Phone__c = '727-145-1456';
            a.nu_dse__CO_Home_Phone__c ='727-345-6789';
            updatedAccounts.add(a);
            
            accountsMap.put(a.id,a);
            
            i +=1;
        }
        
        update updatedAccounts; 
        
       
        for(nu_dse__Program__c prog: [select id,Prospect_ID__c,Cell_Phone__c,nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c in :accountsMap.keySet()]){
            
            System.assertEquals(prog.Cell_Phone__c , accountsMap.get(prog.nu_dse__Account__c).nu_dse__Cell_phone__c);
            
            prospectIds.add(prog.Prospect_ID__c);
            prospectToAccountMap.put(prog.Prospect_ID__c,prog.nu_dse__Account__c);
        }
        
        for(nu_dse__Prospect__c pros:[select id, nu_dse__Cell_Phone__c from nu_dse__Prospect__c where Id  in :prospectIds]){
            
           System.assertEquals(pros.nu_dse__Cell_Phone__c , accountsMap.get(prospectToAccountMap.get(pros.Id)).nu_dse__Cell_phone__c);

        }
    }
    
    
}