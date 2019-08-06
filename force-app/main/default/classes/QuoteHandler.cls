public class QuoteHandler {

    public static void handle(map<id,nu_dse__Quote__c>oldQuote, map<id,nu_dse__Quote__c> newQuote){
        
        List<nu_dse__Quote__c> acceptedQuotes = new List<nu_dse__Quote__c>(); 
        List<nu_dse__Quote__c> rejectedQuotes = new List<nu_dse__Quote__c>();
        List<id> prospectIds = new List<id>(); 
        
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            
            for(id qid: newQuote.keySet()){
                
                if(trigger.isupdate){
                    
                if(  (oldQuote.get(qId).nu_dse__Status__c != newQuote.get(qID).nu_dse__Status__c) && (newQuote.get(qID).nu_dse__Status__c =='Accepted')  ){
                    
                    acceptedQuotes.add(newQuote.get(qID));
                }else if( (oldQuote.get(qId).nu_dse__Status__c != newQuote.get(qID).nu_dse__Status__c) && (newQuote.get(qID).nu_dse__Status__c =='Rejected') ){
                    
                    rejectedQuotes.add(newQuote.get(qId));
                }
                }else if(trigger.isInsert){
                    
                    if(newQuote.get(qID).nu_dse__Status__c =='Accepted'){
                        
                        acceptedQuotes.add(newQuote.get(qID));
                    }else if( (newQuote.get(qID).nu_dse__Status__c =='Rejected') ){
                    
                    rejectedQuotes.add(newQuote.get(qId));
                }
                }
                
            }
        }
        
        if(trigger.isBefore){ 
            
            if(trigger.isInsert){
            
             for(nu_dse__Quote__c quote: (List<nu_dse__Quote__c>) trigger.new){
                
                System.Debug(quote.nu_dse__Prospect__c);
                prospectIds.add(quote.nu_dse__prospect__c);
                
             }
            
           }
            
        }
       
        if(acceptedQuotes.size()>0){
            
            AcceptQuotesForProspect(acceptedQuotes);
        }
       
        
        if(rejectedQuotes.size()>0){
            
            
            // what needs to happen????
        }
       /* 
        if(prospectIds.size()>0){
          
             Map<id,Boolean> prospectFp = isFinancialProfilePopulated(prospectIds);
            
            for(nu_dse__quote__c q : (List<nu_dse__Quote__c>) trigger.new){
                
                if(prospectFp.containsKey(q.nu_dse__Prospect__c) && !prospectFp.get(q.nu_dse__Prospect__c) ){
                    
                    q.addError('Please fill out financial profile and run eligibility check !!');
                }
            }
        }
        */
    }
    
    /*
     * Take all these accepted quotes and update Prospect Extra Amount. 
     */
    
     public static void AcceptQuotesForProspect(List<nu_dse__Quote__c> quotes){
        
        //List<nu_dse__Quote__c> quotes = [Select id,nu_dse__Prospect__c,Extra_Amount__c from nu_dse__quote__c where nu_dse__Status__c ='Accepted'  and id in :acceptedQuotes];
        
        LIst<nu_dse__prospect__c> updatedProspects = new List<nu_dse__Prospect__c>();
        
        for(nu_dse__Quote__c q: quotes){
            
            nu_dse__prospect__c p = new nu_dse__prospect__c(id=q.nu_dse__Prospect__c);
            
            p.Extra_Amount__c = q.Extra_Amount__c; 
            
            updatedProspects.add(p);
        }
        
        try{
            
            update updatedProspects;
            
        }catch(exception e){
            
            System.debug('Update failed');
            
        }
        
    }
    
  /*  
    public static void isFinancialProfilePopulated(List<id> quoteIds ){
        
        List<nu_dse__Quote__c> quotes = new List<nu_dse__Quote__c>(); 
        
        for(nu_dse__Quote__c q : [select id, nu_dse__Prospect__c from nu_dse__quote__c where id in: quoteIds ] ){
            
           quotes.add(q);
            
        }
        
        
    }
    */
    
    
    public static  Map<id,Boolean> isFinancialProfilePopulated(List<id> prospectIds){
        
        List<nu_dse__Prospect__c> prospects = new List<nu_dse__Prospect__c>(); 
        
        Map<id,Boolean> prospectContainsFP = new Map<id,boolean>(); 
        
        
        for(nu_dse__Prospect__c p: [select id,(select id from nu_dse__Financial_Profiles__r),Eligibility_Check_Ran__c from nu_dse__Prospect__c where id in: prospectIds]){
            
            if( p.nu_dse__Financial_Profiles__r.size() == 0 ){
                
                prospectContainsFP.put(p.id,false);
                
            }else if( p.nu_dse__Financial_Profiles__r.size() > 0 && !p.Eligibility_Check_Ran__c ){
                
               /* prospectContainsFP.put(p.id,false);*/
                
            }else if( p.nu_dse__Financial_Profiles__r.size() >0 ){
                
                prospectContainsFP.put(p.id,true);
                
            }
        }
        
        return  prospectContainsFP;
    }
    
    
    
 }