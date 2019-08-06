global class UpdatePhonenumbers {
    
    @InvocableMethod(label='Update Phonenumbers')
    global static List<UpdatePhoneResponse> invoke(List<UpdatePhoneRequest> request ){
        
        List<Id> accountIdList = new List<Id>();
        Map<Id,nu_dse__Program__c> programIdMap = new Map<Id,nu_dse__Program__c>();
        List<nu_dse__Program__c> UpdatedPrograms = new List<nu_dse__Program__c>(); 
        LIst<nu_dse__Prospect__c> UpdatedProspects = new List<nu_dse__Prospect__c>(); 
        List<id> prospectList = new List<id>(); 
        for(UpdatePhoneRequest req: request){
            
            accountIdList.add(req.accountId);
        }
      
        
        for(nu_dse__Program__c p: [select id,Prospect_ID__c,nu_dse__Account__r.nu_dse__CO_Best_Phone__c,nu_dse__Account__r.nu_dse__CO_Cell_Phone__c,nu_dse__Account__r.nu_dse__CO_Home_Phone__c,nu_dse__Account__r.nu_dse__Home_Phone__c,nu_dse__Account__r.nu_dse__Work_Phone__c,nu_dse__Account__r.nu_dse__Cell_phone__c, nu_dse__Account__r.nu_dse__Best_Phone__c   from nu_dse__Program__c where nu_dse__Account__c in: accountIdList]){
            
            programIdMap.put(p.Id,p);
            
            nu_dse__Prospect__c Prospect = new nu_dse__Prospect__c(); 
   
            If(p.nu_dse__Account__c!=null && p.nu_dse__Account__r.nu_dse__Home_Phone__c !=null ){
           
                p.Home_Phone__c = p.nu_dse__Account__r.nu_dse__Home_Phone__c;
                
                Prospect.nu_dse__Home_Phone__c = p.nu_dse__Account__r.nu_dse__Home_Phone__c;
            }
            
            If(p.nu_dse__Account__c !=null && p.nu_dse__Account__r.nu_dse__Work_Phone__c!=null ){
                
                p.Work_Phone__c = p.nu_dse__Account__r.nu_dse__Work_Phone__c; 
                
                prospect.nu_dse__Work_Phone__c = p.nu_dse__Account__r.nu_dse__Work_Phone__c;
            }
         
            If(p.nu_dse__Account__c !=null && p.nu_dse__Account__r.nu_dse__Cell_phone__c !=null ){

                p.Cell_Phone__c= p.nu_dse__Account__r.nu_dse__Cell_phone__c;  
                
                prospect.nu_dse__Cell_Phone__c = p.nu_dse__Account__r.nu_dse__Cell_phone__c;
                
            }
            
            IF(p.nu_dse__Account__c!=null && p.nu_dse__Account__r.nu_dse__Best_Phone__c !=null){
                
                prospect.Best_Phone__c = p.nu_dse__Account__r.nu_dse__Best_Phone__c;
            }
            
            IF(p.nu_dse__Account__c!=null && p.nu_dse__Account__r.nu_dse__CO_Cell_Phone__c !=null){
                
                prospect.nu_dse__CO_Cell_Phone__c = p.nu_dse__Account__r.nu_dse__CO_Cell_Phone__c;
            }
            
            IF(p.nu_dse__Account__c!=null && p.nu_dse__Account__r.nu_dse__CO_Home_Phone__c !=null){
                
                prospect.nu_dse__CO_Home_Phone__c = p.nu_dse__Account__r.nu_dse__CO_Home_Phone__c;
            }
            
            IF(p.nu_dse__Account__c!=null && p.nu_dse__Account__r.nu_dse__CO_Best_Phone__c !=null){
                
                prospect.CO_Best_Phone__c = p.nu_dse__Account__r.nu_dse__CO_Best_Phone__c;
            }
            
            if(p.Prospect_ID__c  != null){
                
               Prospect.Id = p.Prospect_ID__c ;
                
               UpdatedProspects.add(prospect); 

            }
   
            
           UpdatedPrograms.add(p);  
            
          
        }
        
        Database.SaveResult[] updatedProgramsResults = Database.Update(updatedPrograms,false); 
        
        Database.SaveResult[] updatedProspectsResults = Database.Update(UpdatedProspects,false); 
      
        List<UpdatePhoneResponse> response = new List<UpdatePhoneResponse>(); 
        
        UpdatePhoneResponse res = new UpdatePhoneResponse();
        
        for(Database.SaveResult sr : updatedProspectsResults){
            
           
            
            if (sr.isSuccess()){
                
                res.prospectIdList = sr.getId(); 
            } 
         
        }
        
        for(Database.SaveResult sr : updatedProgramsResults){
            
          
            
            if (sr.isSuccess()){
                
                res.programIdList = sr.getId(); 
            } 
            
            
        }
        
         response.add(res);
        return response;
    }
        

    global class UpdatePhoneRequest{
       @InvocableVariable(required=true)
       global String accountId;
       
        
    }
    
    global class UpdatePhoneResponse{
        
       @InvocableVariable
       global Id prospectIdList;
        
        @InvocableVariable
       global Id programIdList;
       
    }
}