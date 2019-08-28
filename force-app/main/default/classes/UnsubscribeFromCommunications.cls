/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API class for email unsubscription
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-08-26
* @modified       2019-08-26
* @Layer          REST API 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/v1/email/unsubscribe/')
global with sharing class UnsubscribeFromCommunications{

    @HttpPost
    global static void unsubscribe(){
        RestRequest req = RestContext.request;

        List<CommunicationSubscriptionService.UnsubscriptionResponse> unsubscriptionResponse = CommunicationSubscriptionService.unsubscribe(req);        
        RestResponse res = Restcontext.response;
        res.StatusCode = CommunicationSubscriptionService.API_StatusCode;
        res.responseBody = Blob.valueOf(JSON.serialize(unsubscriptionResponse));
   }
}