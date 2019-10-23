public class SearchController {
    
    
    @AuraEnabled
    
    public static List<String> searchforWords(String SearchWord){
        
        List<list<Sobject>> results = [FIND :SearchWord in ALL FIELDS RETURNING nu_dse__TradeLine__c(Name), nu_dse__Program__c(Name)];
        
        List<String> words = new List<String>();
        
       
        
        for(list<Sobject> sobjs :results){
           
            for(Sobject sobj: sobjs){
                
                words.add(sobj.Id);
               
                
            }
        }
        return words;
        
    }
    
   
    
    }