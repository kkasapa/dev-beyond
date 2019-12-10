public class Schedule_ProgramEstimatedBalanceUpdate implements Schedulable {
   
    public Integer batchSize;
    Set<Id> filteredProgramIdSet;
    Integer programNumStartIndex, programNumEndIndex;

    public Schedule_ProgramEstimatedBalanceUpdate() {

    }
    
    public Schedule_ProgramEstimatedBalanceUpdate(Integer startIndex, Integer endIndex) {

        if(startIndex != null && endIndex != null && startIndex < endIndex) {

            programNumStartIndex = startIndex;
            programNumEndIndex = endIndex;

        } else {
             throw new CustomException('Incorrect program Number StartIndex and EndIndex value');
        }
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
        } else if(programNumStartIndex != null && programNumEndIndex != null){
            Batch_ProgramEstimatedBalanceUpdate programEstdBalUpdateBatch = new Batch_ProgramEstimatedBalanceUpdate(programNumStartIndex, programNumEndIndex); 
            database.executebatch(programEstdBalUpdateBatch, batchSize);
        }
    }
}