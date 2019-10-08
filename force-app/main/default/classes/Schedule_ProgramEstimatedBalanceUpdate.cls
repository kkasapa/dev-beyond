public class Schedule_ProgramEstimatedBalanceUpdate implements Schedulable {
   
    public Schedule_ProgramEstimatedBalanceUpdate() {
    }
    
    public void execute(SchedulableContext sc) {
    
        Batch_ProgramEstimatedBalanceUpdate programEstdBalUpdateBatch = new Batch_ProgramEstimatedBalanceUpdate(); 
        database.executebatch(programEstdBalUpdateBatch);
    }
}