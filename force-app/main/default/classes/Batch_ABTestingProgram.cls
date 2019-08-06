public class Batch_ABTestingProgram implements Database.Batchable<sObject> {
    
    public String filterCriteria;
    public Decimal filterPercentage;
    public List<nu_dse__Data_Mapping__c> dataMappingList;
    public List<nu_dse__Field_mapping__c> fieldMappingList;
    
    public Batch_ABTestingProgram() {
    
        dataMappingList = [SELECT Id, Filter_Criteria__c, Filter_Percent__c,nu_dse__Source_sObject__c FROM nu_dse__Data_Mapping__c WHERE Name = 'ABTestingProgramToProgram' AND Filter_Percent__c != null Limit 1];
        if (dataMappingList != null && dataMappingList.isEmpty() == False && dataMappingList[0].Filter_Criteria__c != null) {
            
            filterCriteria = dataMappingList[0].Filter_Criteria__c;
            filterPercentage = dataMappingList[0].Filter_Percent__c;
            fieldMappingList = [Select Id, nu_dse__Default_Value__c, nu_dse__Target_Field__c, nu_dse__Source_Field__c, nu_dse__setDefaultValue__c FROM nu_dse__Field_mapping__c WHERE nu_dse__Data_Mapping__c =: dataMappingList[0].Id];
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = '';
        try {
        
            if (String.isBlank(filterCriteria) == False) {
                
                query += 'SELECT Id';
                
                if (fieldMappingList != null && fieldMappingList.isEmpty() == False) {
                
                    for(nu_dse__Field_mapping__c fieldMapping : fieldMappingList) {
                        
                        query += ', '+fieldMapping.nu_dse__Source_Field__c;
                    }
                }
                query += ' FROM nu_dse__Program__c WHERE '+filterCriteria;
            } 
        }catch (Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ABTestingProgram', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
            insert errorlog;
            
        }
        if (String.isBlank(query)) {
            
            query = 'SELECT Id FROM nu_dse__Program__c Limit 0';
        }
        system.debug('query--->'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope) {
        
        Decimal percentage;
        List<nu_dse__Program__c> updateProspect = new List<nu_dse__Program__c>();
        List<nu_dse__Error_Log__c> errorlogList = new List<nu_dse__Error_Log__c>();
        
        try {
        
            if (filterPercentage != null) {
            
                percentage =  ((scope.size()) * (filterPercentage/100));
                
                system.debug('SizeOfScope-->'+scope.size());
                system.debug('percentage--->'+percentage);
            }
            
            if ( percentage != null ) {
            
                Integer i = 1;
                
                for (nu_dse__Program__c prospect : scope) {
                    
                    if (i <= percentage) {
                        
                        Map<String, Schema.SObjectField> fieldMap =Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe().Fields.getMap();
                        
                        if (fieldMappingList != null && fieldMappingList.isEmpty() == False) {
                            
                            nu_dse__Program__c newProspect = new nu_dse__Program__c(Id = prospect.Id);
                            
                            for(nu_dse__Field_mapping__c fieldMapping : fieldMappingList) {
                                
                                if (fieldMapping.nu_dse__setDefaultValue__c == True && String.isBlank(fieldMapping.nu_dse__Default_Value__c) == False) {
                                
                                    system.debug('FieldMapping--->'+fieldMap.get(fieldMapping.nu_dse__Target_Field__c).getDescribe().getType());
                                    if (String.ValueOf(fieldMap.get(fieldMapping.nu_dse__Target_Field__c).getDescribe().getType()) == 'BOOLEAN') {
                                    
                                        newProspect.put(fieldMapping.nu_dse__Target_Field__c, Boolean.ValueOf(fieldMapping.nu_dse__Default_Value__c));
                                    } else if (String.ValueOf(fieldMap.get(fieldMapping.nu_dse__Target_Field__c).getDescribe().getType()) == 'STRING') {
                                    
                                        newProspect.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                                    }
                                } else {
                                    
                                     newProspect.put(fieldMapping.nu_dse__Target_Field__c, prospect.get(fieldMapping.nu_dse__Source_Field__c));
                                }
                            }
                            updateProspect.add(newProspect);
                        }
                    }
                    i++;
                }
            }
            system.debug('updateProspect--->'+updateProspect);
            if (updateProspect.isEmpty() == False) {
                
                Database.SaveResult [] updateResult = Database.update(updateProspect, false);
    
                for (Database.SaveResult r : updateResult) {
                    
                    if (r.isSuccess() == False) {
                        
                        nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ABTestingProspect', nu_dse__User_Context__c = UserInfo.getName());
                        errorlog.nu_dse__Message__c = '';
                        for (Database.Error e : r.getErrors()) { 
                            
                            errorlog.nu_dse__Message__c += e.getMessage();     
                        }
                        insert errorlog;
                    }
                }
            }
        } catch(Exception e) {
            
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ABTestingProgram', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
            insert errorlog;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}