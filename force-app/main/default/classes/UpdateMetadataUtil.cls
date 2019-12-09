/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Class for Updating Metadata - Implements Metadata.DeployCallback. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Avco Team - Karthik Kasapa <kkasapa@beyondfinance.com>
* @created        Nov 2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class UpdateMetadataUtil implements Metadata.DeployCallback {
    
    //Implement handleResult method
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);
        } else {
            System.debug(' fail : '+ result);
        }
    }
    
    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        
        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }
        
        //Add the Custom Metadata in the DeployContainer using addMetadata method
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        UpdateMetadataUtil callback = new UpdateMetadataUtil();
        if(!Test.isRunningTest())
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}