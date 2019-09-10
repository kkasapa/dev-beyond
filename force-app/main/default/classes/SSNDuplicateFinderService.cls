public with sharing class SSNDuplicateFinderService {

    public static Map<String, List<SObject>> checkAndTagDuplicate(Set<String> SSN_nos) {
        
        Map<String, List<SObject>> SSNDuplicateRecMap = new Map<String, List<SObject>>();
        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {

            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__SSN__c,
                                                    nu_dse__Prospect_Status__c, nu_dse__DOB__c 
                                                FROM nu_dse__Prospect__c
                                                WHERE nu_dse__SSN__c IN :SSN_nos]){
                
                if(SSNDuplicateRecMap.containskey(prospect.nu_dse__SSN__c) == false) {
                    SSNDuplicateRecMap.put(prospect.nu_dse__SSN__c, new List<SObject>{prospect}); // if ssn has first duplicate
                } else {
                    SSNDuplicateRecMap.get(prospect.nu_dse__SSN__c).add(prospect);  // if ssn has more than one duplicate
                }
            }

            for(nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, 
                                        nu_dse__Account__r.nu_dse__SSN__c, nu_dse__Account__r.PersonBirthdate, nu_dse__Program_Status__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__r.nu_dse__SSN__c IN :SSN_nos]) {
            
                if(SSNDuplicateRecMap.containskey(program.nu_dse__Account__r.nu_dse__SSN__c) == false) {
                    SSNDuplicateRecMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, new List<SObject>{program}); // if ssn has first duplicate
                } else {
                    SSNDuplicateRecMap.get(program.nu_dse__Account__r.nu_dse__SSN__c).add(program); // if ssn has more than one duplicate
                }
            }

        }
        return SSNDuplicateRecMap; 
    }

    //similar logic for co-client as we did in client
    public static Map<String, List<SObject>> coClientcheckAndTagDuplicate(Set<String> SSN_nos) {
        
        Map<String, List<SObject>> SSNDuplicateRecMap = new Map<String, List<SObject>>();
        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {
            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__Co_Full_Name__c, nu_dse__Co_SSN__c,
                                                    nu_dse__Prospect_Status__c, nu_dse__CO_DOB__c 
                                                FROM nu_dse__Prospect__c
                                                WHERE nu_dse__Co_SSN__c IN :SSN_nos]){
                
                if(SSNDuplicateRecMap.containskey(prospect.nu_dse__Co_SSN__c) == false) {
                    SSNDuplicateRecMap.put(prospect.nu_dse__Co_SSN__c, new List<SObject>{prospect});
                } else {
                    SSNDuplicateRecMap.get(prospect.nu_dse__Co_SSN__c).add(prospect);
                }
            }

            for(nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, nu_dse__Account__r.nu_dse__Co_Last_Name__c, 
                                        nu_dse__Account__r.nu_dse__Co_SSN__c, nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c, nu_dse__Program_Status__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__r.nu_dse__Co_SSN__c IN :SSN_nos]) {
            
                if(SSNDuplicateRecMap.containskey(program.nu_dse__Account__r.nu_dse__Co_SSN__c) == false) {
                    SSNDuplicateRecMap.put(program.nu_dse__Account__r.nu_dse__Co_SSN__c, new List<SObject>{program});
                } else {
                    SSNDuplicateRecMap.get(program.nu_dse__Account__r.nu_dse__Co_SSN__c).add(program);
                }
            }
        }
        return SSNDuplicateRecMap;
    }
   
    public class SSNDuplicateManagmentRequest{    
        public ClientType clientType;
        public Set<String> socialSecutityNumbers;
    }
    public Enum ClientType {CLIENT, CO_CLIENT}
    
    public class SSNDuplicateManagementResponse{
        public String errorCode;
        public String message;
    }
}