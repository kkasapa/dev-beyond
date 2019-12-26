public class AWSTriggerHandler extends IntegrationUtilityClass {
    public AWS_Document__c awsRecord;
    public String userName;
    

    @future(callout=true)
    public static void splitPdf(String recordId, String uName){        
      
        
        //MultipleCalloutController mCC = new MultipleCalloutController();
        //mCC.startRequestInParallel();
        
      //System.enqueJob(new FirstRequest(recordId,uName));
       // FirstRequest.firstLevelRequest( recordId,uName);
       //SecondRequest.secondLevelRequest( recordId,uName);
        
    }
    
    
    
}