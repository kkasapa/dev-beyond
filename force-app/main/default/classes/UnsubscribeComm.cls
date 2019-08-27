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
@RestResource(urlMapping='/unsubscribe/')
global with sharing class UnsubscribeComm{

    @HttpPost
    global static void unsubscribe(){
        RestRequest req = RestContext.request;

        List<EmailSubscriptionService.UnsubscriptionResponse> unsubscriptionResponse = EmailSubscriptionService.unsubscribe(req);
        //String unSubscribeStatus = EmailSubscriptionService.unsubscribe(req);
        
        RestResponse res = Restcontext.response;
        res.StatusCode = EmailSubscriptionService.API_StatusCode;
        res.responseBody = Blob.valueOf(JSON.serialize(unsubscriptionResponse));
   }
}