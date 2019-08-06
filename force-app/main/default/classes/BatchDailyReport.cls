global class BatchDailyReport implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    global String fileContent;
    global List<String> lstFileContent = new List<String>();
    
    global List<nu_dse__program__c> start(Database.BatchableContext BC) {
    /*    fileContent = 'ProgramId,Disposition\n';
        
        String query = 'Select id,name,nu_dse__Disposition__c,Campaign_Updated__c,Campaign_Disposition__c '
            +' from nu_dse__Program__c where Campaign_Updated__c = true'; 
        
        return DataBase.query(query);
    */
    return null;
    }

    global void execute(Database.BatchableContext BC, List<nu_dse__program__c> scopeList) {
    /*    
        if(scopeList != null && !scopeList.isEmpty()){
            for(nu_dse__program__c a: scopeList){
               string recordString = '"'+a.id+'","'+a.Campaign_Disposition__c +'"\n';
               fileContent = fileContent+recordString;
               a.Campaign_Updated__c = false;
            }
            
            update scopeList;
        }
    */
    }  

    global void finish(Database.BatchableContext BC) { 
    /*
        system.debug('--fileContent--'+fileContent);
        uploadFileToProgram();
    */
    }
    
    global void uploadFileToProgram(){
        /*Handle exception case: Query doesn't return anything
        try
        {
            string programid = [select id,name from nu_dse__program__c  where Prospect_Name__c = 'DailyProgramReport'].id;
            list<attachment> atts = [select id from attachment where parentid = :programid];
            if(atts.size() > 0)
            delete atts;
            Blob uploadContent = Blob.valueOf(fileContent);//generateCSVFile(); // Returns blob content of CSV file.
            String uploadFilename = 'Program_Campaign'+'.csv';
            Attachment a = new Attachment(parentid=programid, Name = uploadFilename  , Body = uploadContent);
            insert a;
        }

        catch(System.QueryException e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        */
    }
}