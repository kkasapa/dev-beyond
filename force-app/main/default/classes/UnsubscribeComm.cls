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
    global static String unsubscribe(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String reqBody = req.requestBody.toString();
        EmailSubscriptionService.unsubscribe(req);
        return 'Request Received';
   }
}