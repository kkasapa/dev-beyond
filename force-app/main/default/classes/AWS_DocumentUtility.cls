/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* This class contains reusable functionality. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shravan 
* @modifiedBy     
* @maintainedBy   Shravan
* @version        1.0
* @created        2019-12-19
* @modified       2019-12-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AWS_DocumentUtility {    
    public static AWS_Document__c getAws(String recordId){
        AWS_Document__c  awsRecord = [SELECT id, Name,File_Link__c,Category__c,Program__c,Content_Type__c,
                                      File_Name__c,Folder__c,Size__c,Bucket__c,Program__r.Name,Program__r.nu_dse__Account__r.Name 
                                      FROM AWS_Document__c 
                                      WHERE id =: recordId];
        return awsRecord;
    }
    public static List<AWS_PDF_Split__c> getAwsSplitList(){
        List<AWS_PDF_Split__c> awsCList = [SELECT id, Name,SearchTitle__c, OutputFileName__c 
                                           FROM AWS_PDF_Split__c];
        return awsCList;
    }
    
    public static void createLog(String recordId, String classAndMethod, String uName){        
        nu_dse__Error_Log__c objErrorLog = new nu_dse__Error_Log__c();
        objErrorLog.nu_dse__Message__c = 'Unable to process the request as the server system did not respond properly';
        objErrorLog.nu_dse__Class_Method__c = classAndMethod;
        objErrorLog.nu_dse__Stack_Trace__c = 'An Exception occured with the below details :\n No details found';
        objErrorLog.nu_dse__User_Context__c = uName;
        objErrorLog.nu_dse__Error_Causing_Record_Id__c = recordId;
        
        insert objErrorLog;
    }
    
    public static AWS_Document__c getSingleResponse(Map<String, Object> ResponseObj, AWS_Document__c awsRecord){
        AWS_Document__c AWS = New AWS_Document__c();
        AWS.File_Link__c = (string)ResponseObj.get('outputFileUrl');
        Aws.File_Name__c= (string)ResponseObj.get('outputFileName');
        AWS.Program__c= awsRecord.Program__c;
        Aws.Folder__c = (string)ResponseObj.get('folder');            
        AWS.Bucket__c=awsRecord.Bucket__c;
        AWS.Category__c = awsRecord.Category__c;
        AWS.Content_Type__c= awsRecord.Content_Type__c;
        AWS.Size__c = awsRecord.Size__c;
        AWS.createdFromAWS__c = true;
        return AWS;
    }
    
    public static List<AWS_Document__c> getBulkResponse(List<AWSSchemaClass.ResponseClass> responseList, AWS_Document__c awsRecord){
        List<AWS_Document__c> aswFList = new List<AWS_Document__c>();  
        for(Integer i=0;i<responseList.size();i++){
            AWS_Document__c AWS = New AWS_Document__c();
            AWS.File_Link__c = responseList[i].outputFileName;
            Aws.File_Name__c= responseList[i].outputFileUrl;
            AWS.Program__c= awsRecord.Program__c;
            Aws.Folder__c = awsRecord.Folder__c;            
            AWS.Bucket__c=awsRecord.Bucket__c;
            AWS.Category__c = awsRecord.Category__c;
            AWS.Content_Type__c= awsRecord.Content_Type__c;
            AWS.Size__c = awsRecord.Size__c;
            AWS.createdFromAWS__c = true;
            aswFList.add(AWS);
        }        
        return aswFList;
    }    
}