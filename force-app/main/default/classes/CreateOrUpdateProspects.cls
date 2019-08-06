@RestResource(urlMapping='/LeadService/CreateOrUpdateProspects/*')
global class CreateOrUpdateProspects {

     @HTTPPOST
    global static List<nu_dse__Prospect__c> doPost(list<nu_dse__Prospect__c> prospects){
        
        List<nu_dse__Prospect__c> updateDebts = new List<nu_dse__Prospect__c>();
        
     
        upsert prospects ; 
       
        return prospects;
    }
}