global class Schedule_ProgramEstimatedBalanceUpdate implements Schedulable {
   
    global Integer batchSize;
    public Set<Id> filteredProgramIdSet;

    public Schedule_ProgramEstimatedBalanceUpdate() {
    }
    public Schedule_ProgramEstimatedBalanceUpdate(Set<Id> programIdSet) {
        
        if(programIdSet != null && programIdSet.isEmpty() == false) {
            filteredProgramIdSet = new Set<Id>();
            filteredProgramIdSet.addAll(programIdSet);
        }
    }
    public void execute(SchedulableContext sc) {
        
        if(batchSize == null) {
            batchSize = 200;
        }

        if(filteredProgramIdSet != null) {
            Batch_ProgramEstimatedBalanceUpdate programEstdBalUpdateBatch = new Batch_ProgramEstimatedBalanceUpdate(filteredProgramIdSet); 
            database.executebatch(programEstdBalUpdateBatch, batchSize);
        } else {
            Batch_ProgramEstimatedBalanceUpdate programEstdBalUpdateBatch = new Batch_ProgramEstimatedBalanceUpdate(); 
            database.executebatch(programEstdBalUpdateBatch, batchSize);
        }
        
    }
}