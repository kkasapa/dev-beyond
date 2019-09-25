public with sharing class SSNDuplicateFinderService {

    public static Map<String, List<SObject>> checkAndTagDuplicate(Set<String> SSN_nos) {
        
        Map<String, List<SObject>> SSNDuplicateRecMap = new Map<String, List<SObject>>();
        String clientSSN = '';

        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {

            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__SSN__c,
                                                    nu_dse__Prospect_Status__c, nu_dse__DOB__c, nu_dse__SSN_ENC__c 
                                                FROM nu_dse__Prospect__c
                                                WHERE nu_dse__SSN__c IN :SSN_nos]){
                
                system.debug('prospect.nu_dse__SSN_ENC__c::'+prospect.nu_dse__SSN_ENC__c);
                system.debug('prospect.nu_dse__SSN_ENC__c::'+prospect.nu_dse__SSN__c);
                system.debug(prospect.nu_dse__SSN__c == prospect.nu_dse__SSN_ENC__c);

                clientSSN = '';
                if (String.isNotBlank(prospect.nu_dse__SSN_ENC__c) == true) {
                    clientSSN = prospect.nu_dse__SSN_ENC__c;
                } else if(String.isNotBlank(prospect.nu_dse__SSN__c) == true) {
                    clientSSN = prospect.nu_dse__SSN__c;
                }
                if(SSNDuplicateRecMap.containskey(clientSSN) == false) {
                    SSNDuplicateRecMap.put(clientSSN, new List<SObject>{prospect}); // if ssn has first duplicate
                } else {
                    SSNDuplicateRecMap.get(clientSSN).add(prospect);  // if ssn has more than one duplicate
                }
            }

            for(nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, 
                                                nu_dse__Account__r.nu_dse__SSN__c, nu_dse__Account__r.PersonBirthdate, 
                                                nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__SSN_ENC__c 
                                             FROM nu_dse__Program__c 
                                             WHERE nu_dse__Account__r.nu_dse__SSN__c IN :SSN_nos]) {
                
                clientSSN = '';
                if (String.isNotBlank(program.nu_dse__Account__r.nu_dse__SSN__c) == true) {
                    clientSSN = program.nu_dse__Account__r.nu_dse__SSN__c;
                } else if(String.isNotBlank(program.nu_dse__Account__r.nu_dse__SSN_ENC__c) == true) {
                    clientSSN = program.nu_dse__Account__r.nu_dse__SSN_ENC__c;
                }
                if(SSNDuplicateRecMap.containskey(clientSSN) == false) {
                    SSNDuplicateRecMap.put(clientSSN, new List<SObject>{program}); // if ssn has first duplicate
                } else {
                    SSNDuplicateRecMap.get(clientSSN).add(program); // if ssn has more than one duplicate
                }
            }

        }
        return SSNDuplicateRecMap; 
    }

    //similar logic for co-client as we did in client
    public static Map<String, List<SObject>> coClientcheckAndTagDuplicate(Set<String> SSN_nos) {
        
        Map<String, List<SObject>> SSNDuplicateRecMap = new Map<String, List<SObject>>();
        String co_clientSSN = '';

        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {
            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__Co_Full_Name__c, nu_dse__Co_SSN__c,
                                                    nu_dse__Prospect_Status__c, nu_dse__CO_DOB__c, nu_dse__CO_SSN_ENC__c 
                                                FROM nu_dse__Prospect__c
                                                WHERE nu_dse__Co_SSN__c IN :SSN_nos]){
                
                co_clientSSN = '';
                if (String.isNotBlank(prospect.nu_dse__CO_SSN_ENC__c) == true) {
                    co_clientSSN = prospect.nu_dse__CO_SSN_ENC__c;
                } else if(String.isNotBlank(prospect.nu_dse__Co_SSN__c) == true) {
                    co_clientSSN = prospect.nu_dse__Co_SSN__c;
                }
                if(SSNDuplicateRecMap.containskey(co_clientSSN) == false) {
                    SSNDuplicateRecMap.put(co_clientSSN, new List<SObject>{prospect});
                } else {
                    SSNDuplicateRecMap.get(co_clientSSN).add(prospect);
                }
            }

            for(nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, nu_dse__Account__r.nu_dse__Co_Last_Name__c, 
                                        nu_dse__Account__r.nu_dse__Co_SSN__c, nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c,
                                        nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__CO_SSN_ENC__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__r.nu_dse__Co_SSN__c IN :SSN_nos]) {
                
                co_clientSSN = '';

                if (String.isNotBlank(program.nu_dse__Account__r.nu_dse__Co_SSN__c) == true) {
                    co_clientSSN = program.nu_dse__Account__r.nu_dse__Co_SSN__c;
                } else if(String.isNotBlank(program.nu_dse__Account__r.nu_dse__CO_SSN_ENC__c) == true) {
                    co_clientSSN = program.nu_dse__Account__r.nu_dse__CO_SSN_ENC__c;
                }
                if(SSNDuplicateRecMap.containskey(co_clientSSN) == false) {
                    SSNDuplicateRecMap.put(co_clientSSN, new List<SObject>{program});
                } else {
                    SSNDuplicateRecMap.get(co_clientSSN).add(program);
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