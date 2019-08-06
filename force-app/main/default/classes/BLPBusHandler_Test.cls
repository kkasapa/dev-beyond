@istest
public class BLPBusHandler_Test {
    
    @testsetup
    public static void testData(){
        BLP_Bus__e blp = new BLP_Bus__e(action__c='create', program_id__c='test');
        EventBus.publish(blp);
    }

    public static testmethod void publish_Inserttest() {
        BLP_Bus__e blplist = new BLP_Bus__e(action__c='create', program_id__c='test');
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(blplist);
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess());
    }
}