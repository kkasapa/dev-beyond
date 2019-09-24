@RestResource(urlMapping='/AWSdocument/*')
global with sharing class AWSdocumentRestResource {
	@HttpPost
	global static string createAWSdocument() {
		String jsonString = RestContext.request.requestBody.toString();
       	system.debug('**jsonString**'+jsonString); 
		Map<String, Object> docObj = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		AWS_Document__c awsObj = new AWS_Document__c();        	
        	awsObj.File_Link__c 	= (string)docObj.get('aws_documentLink');
        	awsObj.Category__c 		= (string)docObj.get('category');
        	awsObj.Program__c 		= (string)docObj.get('clientsProgramId');	
        	awsObj.Content_Type__c 	= (string)docObj.get('contentType');
        	awsObj.File_Name__c 	= (string)docObj.get('documentName');
        	awsObj.Folder__c 		= (string)docObj.get('folder');
        	awsObj.Size__c 			= (integer)docObj.get('size');
        	awsObj.Bucket__c 		= (string)docObj.get('bucket'); 			
		insert awsObj;
			
		return awsObj.Id;
	}
    
    /*
		{
            "aws_documentLink": "Program/P-35170/P-35170-TotalAmountPaid.jpg",
            "category": "Other",
            "clientsProgramId": "a0L22000000VmzhEAC",
            "contentType": "",
            "documentName": "TotalAmountPaid.jpg",
            "folder": "Program/P-35170",
            "size": 100,
            "bucket": "new"
        }
	*/
}