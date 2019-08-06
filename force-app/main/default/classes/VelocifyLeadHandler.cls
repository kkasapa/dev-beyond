public class VelocifyLeadHandler {

    // Method to query leads to update values in Velocify Portal
    @future(callout=true)
    public static void modifyLeads_Async(Set<Id> velocifyProspectIds){
        
        String query = 'SELECT ' + Utility.getQueryFields('nu_dse__Prospect__c') + 
                        ' FROM nu_dse__Prospect__c WHERE Id IN :velocifyProspectIds';
        List<nu_dse__prospect__c> velocifyProspectList = Database.query(query);
        ServiceLeads360 lead360 = new ServiceLeads360(); 
        lead360.modifyLeads(velocifyProspectList);
    }

    // Method to create wrapper for leads status update in Velocify Portal based on 'VelocifyLeadStatusMapping' data mapping
    @future(callout=true)
    public static void modifyLeadStatus(String leadListJson) {
        
        List<nu_dse__Prospect__c> leadList = (List<nu_dse__Prospect__c>)JSON.deserialize(leadListJson, List<nu_dse__Prospect__c>.class);

        Map<String, String> fieldMap = new Map<String, String>(); 
        for(nu_dse__Field_mapping__c fieldMapping : [SELECT Id, nu_dse__Data_Mapping__c, Notes__c, nu_dse__Source_Field__c, nu_dse__Target_Field__c 
                                                     FROM nu_dse__Field_mapping__c 
                                                     WHERE nu_dse__Data_Mapping__r.Name='VelocifyLeadStatusMapping']){
            fieldMap.put(fieldMapping.nu_dse__Source_Field__c.toUpperCase(), fieldMapping.nu_dse__Target_Field__c);
        }
        List<ServiceLeads360.ModifyLeadApiRequestWrapper> modifyLeadStatusRequestWrapperList = new List<ServiceLeads360.ModifyLeadApiRequestWrapper>();
        
        // create ModifyLeadApiRequestWrapper wrapper with lead Id, Velicfy Id and velocify action Id
        for (nu_dse__Prospect__c lead : leadList) {
            if (fieldMap.containsKey(lead.nu_dse__Last_Disposition__c.toUppercase()) == True) {
                ServiceLeads360.ModifyLeadApiRequestWrapper modifyLeadApiRequestInst = new ServiceLeads360.ModifyLeadApiRequestWrapper();
                modifyLeadApiRequestInst.leadId = lead.velocify_id__c;
                modifyLeadApiRequestInst.leadStatusId = fieldMap.get(lead.nu_dse__Last_Disposition__c.toUppercase());
                modifyLeadApiRequestInst.leadSFId = lead.Id;
                modifyLeadStatusRequestWrapperList.add(modifyLeadApiRequestInst);
            }
        }
        // Invoked velocify lead status update callout method with list of ModifyLeadApiRequestWrapper
        if (modifyLeadStatusRequestWrapperList.isEmpty() == False) {
            ServiceLeads360 lead360 = new ServiceLeads360(); 
            lead360.modifyLeadStatus(modifyLeadStatusRequestWrapperList);
        }
    }

    // Method to create wrapper for leads action added in Velocify portal based on 'VelocifyActionMap' data mapping
    @future(callout=true)
    public static void addLeadActions(String leadListJson){
        
        List<nu_dse__Prospect__c> leadList = (List<nu_dse__Prospect__c>)JSON.deserialize(leadListJson, List<nu_dse__Prospect__c>.class);

        Map<String,nu_dse__Field_mapping__c> fieldMap = new Map<String,nu_dse__Field_mapping__c>(); 
        for(nu_dse__Field_mapping__c fieldMapping : [SELECT Id, nu_dse__Data_Mapping__c, Notes__c, nu_dse__Source_Field__c, nu_dse__Target_Field__c 
                                                     FROM nu_dse__Field_mapping__c 
                                                     WHERE nu_dse__Data_Mapping__r.Name='VelocifyActionMap']){
            fieldMap.put(fieldMapping.nu_dse__Source_Field__c.toUpperCase(), fieldMapping);
        }
        // Create ModifyLeadApiRequestWrapper with lead Id, velocify Id, Velocify action Id and action note
        List<ServiceLeads360.ModifyLeadApiRequestWrapper> modifyLeadActionsRequestWrapperList = new List<ServiceLeads360.ModifyLeadApiRequestWrapper>();
        for(nu_dse__Prospect__c lead : leadList) {
            if (fieldMap.containsKey(lead.nu_dse__Last_Disposition__c.toUppercase()) == True 
                && fieldMap.get(lead.nu_dse__Last_Disposition__c.toUppercase()).nu_dse__Target_Field__c != null) {
                
                ServiceLeads360.ModifyLeadApiRequestWrapper modifyLeadApiRequestInst = new ServiceLeads360.ModifyLeadApiRequestWrapper();
                modifyLeadApiRequestInst.leadId = lead.velocify_id__c;
                modifyLeadApiRequestInst.actionId = fieldMap.get(lead.nu_dse__Last_Disposition__c.toUppercase()).nu_dse__Target_Field__c;
                modifyLeadApiRequestInst.actionNote = fieldMap.get(lead.nu_dse__Last_Disposition__c.toUppercase()).Notes__c;
                modifyLeadApiRequestInst.leadSFId = lead.Id;
                modifyLeadActionsRequestWrapperList.add(modifyLeadApiRequestInst);
            }
        }
        // Invoked  velocify add action callout method with list of ModifyLeadApiRequestWrapper
        if (modifyLeadActionsRequestWrapperList.isEmpty() == False) {
            ServiceLeads360 lead360 = new ServiceLeads360(); 
            lead360.addLeadAction(modifyLeadActionsRequestWrapperList);
        }
    }
}