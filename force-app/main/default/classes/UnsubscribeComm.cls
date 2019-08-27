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

        String unSubscribeStatus = EmailSubscriptionService.unsubscribe(req);

        RestResponse res = Restcontext.response;

        if(unSubscribeStatus == 'Successfully unsubscribed') {
            res.StatusCode = 200;
            res.responseBody = Blob.valueOf('Success:'+unSubscribeStatus);
        } else {
            res.StatusCode = 500;
            res.responseBody = Blob.valueOf('Error:'+unSubscribeStatus);
        }
   }
}