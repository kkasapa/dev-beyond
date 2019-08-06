public class Utility {
    
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        Id recordTypeId;
        
        if (recordTypeMap.containsKey(recordTypeName)) {
            
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
            System.debug('**recordTypeId'+recordTypeId);
        }
        
        return recordTypeId;
        
    }
    
    public static List<nu_dse__Field_Mapping__c> getFieldMapping(String dataMappingName) {
        
        List<nu_dse__Field_Mapping__c> fieldMappingList = new List<nu_dse__Field_Mapping__c>();
        
        if (String.isNotBlank(dataMappingName)) {
            
            List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id FROM nu_dse__Data_Mapping__c where Name = :dataMappingName  LIMIT 1];
            
            if (dataMappingList.size() > 0) {
                
                for (nu_dse__Field_Mapping__c fieldmap : [SELECT nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                          nu_dse__setDefaultValue__c, nu_dse__Default_Value__c, 
                                                          nu_dse__Is_Required__c 
                                                          FROM nu_dse__Field_mapping__c 
                                                          WHERE nu_dse__Data_Mapping__c = :dataMappingList[0].Id]) {
                    
                    fieldMappingList.add(fieldmap);
                }
            }
        }
      return fieldMappingList;
    }
    
    public static String getQueryFields(String objectName) {
        
         Set<String> fieldsSet = new Set<String>();
         
         String[] types = new String[]{objectName};
         Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
         Schema.DescribeSobjectResult result = results[0]; 
         
         Map<String,Schema.SObjectField> fieldMap =  result.fields.getMap();
         system.debug('fieldMap-->'+fieldMap);
         String fields = '';
         
         for (String k : fieldMap.keySet()) {
            
            String fieldName =  fieldMap.get(k).getDescribe().getName();
            
            if (fieldsSet.contains(fieldName) == False) {
                
                fields += fieldName + ',';
            }
         }
         system.debug('fields--->'+fields);
        
         if (String.isNotBlank(fields)) {
        
            fields = fields.removeEnd(',');
         }
         system.debug('fields--->'+fields);
         return fields;
    }
}