public with sharing class SSNDuplicateFinderService {
    public SSNDuplicateFinderService() {

    }

    public static Map<String, List<nu_dse__Prospect__c>> checkAndTagDuplicate(Set<String> SSN_nos) {
        
        Map<String, List<SObject>> SSNDublicateRecMap = new Map<String, List<SObject>>();
        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {

            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__SSN__c FROM nu_dse__Prospect__c
                                                WHERE nu_dse__SSN__c IN :SSN_nos]){
                
                if(SSNDublicateRecMap.containskey(prospect.nu_dse__SSN__c) == false) {
                    SSNDublicateRecMap.put(prospect.nu_dse__SSN__c, new List<SObject>{prospect});
                } else {
                    SSNDublicateRecMap.get(prospect.nu_dse__SSN__c).add(prospect);
                }
            }

            for(nu_dse__Program__c program : [SELECT Id, Name, nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, 
                                        nu_dse__Account__r.nu_dse__SSN__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__r.nu_dse__SSN__c IN :SSN_nos]) {
            
                if(SSNDublicateRecMap.containskey(program.nu_dse__Account__r.nu_dse__SSN__c) == false) {
                    SSNDublicateRecMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, new List<SObject>{program});
                } else {
                    SSNDublicateRecMap.get(program.nu_dse__Account__r.nu_dse__SSN__c).add(program);
                }
            }

        }
        return SSNDublicateRecMap; 
    }
    /*
    public static Map<String, String> checkAndTagDuplicate_Clone(Set<String> SSN_nos, Set<Id> ssnProspectIds) {
        
        Map<String, String> SSNDuplicateRefNameMap = new Map<String, String>();

        if(SSN_nos != null 
            && SSN_nos.isEmpty() == false) {

            for(nu_dse__Prospect__c prospect : [SELECT Id, Name, nu_dse__First_Name__c, nu_dse__Last_Name__c, nu_dse__SSN__c FROM nu_dse__Prospect__c
                                                WHERE nu_dse__SSN__c IN :SSN_nos AND Id NOT IN :ssnProspectIds]){
                
                if(SSNDuplicateRefNameMap.containskey(prospect.nu_dse__SSN__c) == false) {
                    SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, prospect.Name+': '+ 
                        prospect.nu_dse__First_Name__c + ' ' +prospect.nu_dse__Last_Name__c);
                } else {
                    SSNDuplicateRefNameMap.put(prospect.nu_dse__SSN__c, SSNDuplicateRefNameMap.get(prospect.nu_dse__SSN__c) + 
                        ', ' + prospect.Name +': '+ prospect.nu_dse__First_Name__c + ' ' + 
                        prospect.nu_dse__Last_Name__c);
                }
            }

            for(nu_dse__Program__c program: [SELECT Id, Name, nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, 
                                        nu_dse__Account__r.nu_dse__SSN__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__r.nu_dse__SSN__c IN :SSN_nos]) {

                if(SSNDuplicateRefNameMap.containskey(program.nu_dse__Account__r.nu_dse__SSN__c) == false) {
                    SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, program.Name+': '+ 
                        program.nu_dse__Account__r.FirstName + ' ' +program.nu_dse__Account__r.LastName);
                } else {
                    SSNDuplicateRefNameMap.put(program.nu_dse__Account__r.nu_dse__SSN__c, SSNDuplicateRefNameMap.get(program.nu_dse__Account__r.nu_dse__SSN__c) + 
                        ', ' + program.Name +': '+ program.nu_dse__Account__r.FirstName + ' ' + 
                        program.nu_dse__Account__r.LastName);
                }                               
            }
        }
        return SSNDuplicateRefNameMap; 
    } */
}