/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API for getting Duplicate SSN within SF system
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-09-05
* @modified       2019-09-06
* @Layer          REST API 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/v1/ssn/getSSNDuplicates/')
global with sharing class SSNDuplicateManagement{

    @HttpPost
    global static void getSSNduplicates(){

        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        if(req != null) {
            try{
                SSNDuplicateFinderService.SSNDuplicateManagmentRequest request = (SSNDuplicateFinderService.SSNDuplicateManagmentRequest)JSON.deserialize(req.requestBody.toString(), SSNDuplicateFinderService.SSNDuplicateManagmentRequest.class);
                res.addHeader('Content-Type', 'application/json');
                if (request.clientType == SSNDuplicateFinderService.ClientType.CLIENT) {
                    res.responseBody = Blob.valueOf(JSON.serialize(SSNDuplicateFinderService.checkAndTagDuplicate(request.socialSecutityNumbers)));
                } else if(request.clientType == SSNDuplicateFinderService.ClientType.CO_CLIENT) {
                    res.responseBody = Blob.valueOf(JSON.serialize(SSNDuplicateFinderService.coClientcheckAndTagDuplicate(request.socialSecutityNumbers)));
                } 
                res.StatusCode = 200;
            } catch(Exception e) {
                SSNDuplicateFinderService.SSNDuplicateManagementResponse response = new SSNDuplicateFinderService.SSNDuplicateManagementResponse();
                res.StatusCode = 500;
                response.errorCode = e.getTypeName();
                response.message = e.getMessage();
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            }
        }
   }
}