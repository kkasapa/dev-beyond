global class Schedule_Batch_Holidays implements Schedulable {
    global void execute(SchedulableContext SC) {
        Map<String, Object> maptest = new Map<String, Object>();
        Date dt = Holidays.calculateNthWorkingDay(system.today(), 3);
        maptest.put('Business_Days__c',dt);
        UpdateMetadataUtil.createUpdateMetadata('Business_Days.Business_Days','Business Days',maptest);
    }
}