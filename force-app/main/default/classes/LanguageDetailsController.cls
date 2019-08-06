public class LanguageDetailsController {
    
    public nu_dse__Program__c programInstance {get; set;}
    public Id recordId {get;
        set{
            
            if(recordId == null) {
                
                recordId = value;
                queryProgram();
            }
        }
    }
    
    public LanguageDetailsController() {
        
        programInstance = new nu_dse__Program__c();
    }
    
    public void queryProgram() {
        
        if (recordId != null) {
            
            List<nu_dse__Program__c> programInstanceList = new List<nu_dse__Program__c>();
            programInstanceList = [SELECT Id, Prospect_ID__c, Discover_Included__c, Language__c,
                                    Enrolled_Date__c, Original_Program_Length__c, Wet_LOA_Completed__c 
                                    FROM nu_dse__Program__c WHERE Id = :recordId ];
            
            if (programInstanceList.size() > 0) {
                
                programInstance = programInstanceList[0];
            }
        }
    }
    
    public void updateProgram() {
        
        try {
            
            if (programInstance.Id != Null) {
                
                update programInstance;
            }
        } catch (Exception e) {
        
            System.debug('*** Exception: '+ e.getMessage());
        }
    
    }
}