public virtual class IntegrationUtilityClass {

    public static void createLog(String recordId, String classAndMethod, String uName){        
        nu_dse__Error_Log__c objErrorLog = new nu_dse__Error_Log__c();
        objErrorLog.nu_dse__Message__c = 'Unable to process the request as the server system did not respond properly';
        objErrorLog.nu_dse__Class_Method__c = classAndMethod;
        objErrorLog.nu_dse__Stack_Trace__c = 'An Exception occured with the below details :\n No details found';
        objErrorLog.nu_dse__User_Context__c = uName;
        objErrorLog.nu_dse__Error_Causing_Record_Id__c = recordId;
        
        insert objErrorLog;
    }
}