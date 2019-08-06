public class Schedule_PopulateNoOfDaysOverdue implements schedulable {

    public Integer batchSize = 200;
    
    public void execute(System.SchedulableContext SC) {
    
        Database.executeBatch(new Batch_PopulateNoOfDaysOverdue(), batchSize);
    }
}