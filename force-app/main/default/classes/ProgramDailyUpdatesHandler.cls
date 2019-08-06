public class ProgramDailyUpdatesHandler implements Queueable {
    
    public List<nu_dse__Program__c> updatedPrograms = new List<nu_dse__Program__c>(); 
    
    public  ProgramDailyUpdatesHandler( List<nu_dse__Program__c> programsList){
        
        this.updatedPrograms = programsList;
    }
    
    public void execute(QueueableContext context) {
        
        if(updatedPrograms.size()>0){
            
            update this.updatedPrograms; 
        }
        
    }


}