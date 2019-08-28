/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Service class for unsubscribing the  marketting/notifications emails 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-08-20
* @modified       2019-08-27
* @Layer          Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

//define a limit for requests, Limit of 10 clients
// consider for Phone SMS unsubscription
public without sharing class CommunicationSubscriptionService {

    public static Integer API_StatusCode; // status code to be set to the API response

    public CommunicationSubscriptionService() {
        API_StatusCode = 200;
    }
    // this method process the request from API and collectd ids/emails of client to unsubscribe them from emails
    public static List<UnsubscriptionResponse> unsubscribe(RestRequest apiRequest) {
      
        Set<Id> clientProspectIds = new Set<Id>(); // set of Ids of Prospect who is to be unsubscribed from emails
        Set<Id> clientAccountIds = new Set<Id>(); // set of Ids of Person Account(Enrolled client) who is to be unsubscribed from emails
        Set<String> clientEmails = new Set<String>(); // set of emails of client(both prospect & enrolled) who is to be unsubscribed from emails
        List<UnsubscriptionResponse> apiresponse = new List<UnsubscriptionResponse>();
        try{
            List<CommunicationSubscriptionService.CommunicationNotificatioWrap> requestList = (List<CommunicationSubscriptionService.CommunicationNotificatioWrap>)JSON.deserialize(apiRequest.requestBody.toString(), List<CommunicationSubscriptionService.CommunicationNotificatioWrap>.class);
            if (requestList.size() > 10) {
                
            } else {

            }
            for(CommunicationNotificatioWrap reqWrap: requestList) { 
                if(String.isNotBlank(reqWrap.clientId) == true) {
                    if(getIdType(reqWrap.clientId) == 'nu_dse__Prospect__c') { // checking the type of record id sent
                        clientProspectIds.add(reqWrap.clientId);
                    } else if(getIdType(reqWrap.clientId) == 'Account') {
                        clientAccountIds.add(reqWrap.clientId);
                    } else if(getIdType(reqWrap.clientId) == 'nu_dse__Payment__c') {
                        // unsubscribe logic
                    } else {
                        API_StatusCode = 500; // if id is not of any specified type, we are throwing an exception as response 
                        throw  new CustomException('Invalid clientId: '+reqWrap.clientId);
                    }
                } else if(String.isNotBlank(reqWrap.clientEmail) == true 
                            && isValidateEmail(reqWrap.clientEmail) == true) { // if the json node contains email instead of id 
                        clientEmails.add(reqWrap.clientEmail); // adding emails to set for processing
                } else {
                    //throw *customException*;
                    API_StatusCode = 500; // throw exception if id, email is invalid
                    throw  new CustomException('clientId or clientEmail required');
                }
            }
            if (clientProspectIds != null && clientProspectIds.isEmpty() == false) {
                apiresponse.addAll(unsubscribeProspectsfromEmail(clientProspectIds)); // based on the clientId, 
            }
            if (clientAccountIds != null && clientAccountIds.isEmpty() == false) {
                apiresponse.addAll(unsubscribePersonAccountfromEmail(clientAccountIds));
            }     
            if (clientEmails != null && clientEmails.isEmpty() == false) {
                apiresponse.addAll(unsubscribeProspectsfromEmail(clientEmails));
            }   
        } catch(Exception e) {
            //return e.getMessage();
            API_StatusCode = 500;
            UnsubscriptionResponse response = new UnsubscriptionResponse();
            response.message = e.getMessage();
            apiresponse.add(response);
            return apiresponse;
        } 
        return apiresponse;
    }

    public static List<UnsubscriptionResponse> unsubscribeProspectsfromEmail(Set<Id> prospectIds) {
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM nu_dse__Prospect__c WHERE Id IN :prospectIds];
        for (nu_dse__Prospect__c prospect: prospectList) { // updating the controlling field in Prospect
            prospect.Unsubscribed_from_Emails__c = true;
        }
        return generateResponseFromSaveResult(Database.update(prospectList, false));
    }

    public static List<UnsubscriptionResponse> unsubscribeProspectsfromEmail(Set<String> clientEmails) {
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM nu_dse__Prospect__c WHERE nu_dse__Email_Address__c IN :clientEmails];
        for (nu_dse__Prospect__c prospect: prospectList) {
            prospect.Unsubscribed_from_Emails__c = true;
        }
        return generateResponseFromSaveResult(Database.update(prospectList, false));
    }

    public static List<UnsubscriptionResponse> unsubscribePersonAccountfromEmail(Set<Id> personAccountIds) {
        List<Account> personAccountList = [SELECT Id, Unsubscribed_from_Emails__c
                                                    FROM Account WHERE Id IN :personAccountIds];
        for (Account personAccount: personAccountList) {
            personAccount.Unsubscribed_from_Emails__c = true;
        }
        return generateResponseFromSaveResult(Database.update(personAccountList, false));
    }

    public static List<UnsubscriptionResponse> unsubscribePersonAccountfromEmail(Set<String> clientEmails) {
        List<Account> personAccountList = [SELECT Id, Unsubscribed_from_Emails__c
                                                    FROM Account WHERE PersonEmail IN :clientEmails];
        for (Account personAccount: personAccountList) {
            personAccount.Unsubscribed_from_Emails__c = true;
        }
        return generateResponseFromSaveResult(Database.update(personAccountList, false));
    }

    public static String getIdType(Id recId) {
        return recId.getSobjectType().getDescribe().getName();
    }

    public static Boolean isValidateEmail(String emailString) {

        Pattern emailPattern = Pattern.compile('([a-z]|[0-9]|[_.]){3,}[@]{1}[a-z]{2,}[.][a-z]{2,3}'); //pattern for email validation regular expression
        Matcher emailStringMatcher = emailPattern.matcher(emailString); // matches the emailstring with pattern
        return emailStringMatcher.matches(); //return true if valid email
    }

    public void unsubscribeEmailTasks(Set<Id> whatIds) {

        List<Task> emailCommTasks = [SELECT Id, Subject, WhatId, Status, nu_dse__Communication_Sent__c, nu_dse__Communication_Template__c
                                FROM Task WHERE WhatId IN :whatIds 
                                AND nu_dse__Communication_Template__c != null 
                                AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'Email Alert'];
        for(Task commTasks: emailCommTasks) {
            commTasks.Status = 'Completed';
        }
        update emailCommTasks;
    }

    public static List<UnsubscriptionResponse> generateResponseFromSaveResult(Database.SaveResult[] saveResults){
        
        List<UnsubscriptionResponse> saveResultResponseList = new List<UnsubscriptionResponse>(); //response to be sent 
        for (Database.SaveResult prospectUpdateResult: saveResults) { // getting the saveserult and generating the response
            UnsubscriptionResponse saveResultResponse = new UnsubscriptionResponse();
            if(prospectUpdateResult.isSuccess() == true) {
                saveResultResponse.clientId = prospectUpdateResult.getId();
                saveResultResponse.message = 'Client unsubscribed Successfully';
            } else {
                API_StatusCode = 500;
                saveResultResponse.clientId = prospectUpdateResult.getId();
                saveResultResponse.message = 'Unable to Unsubscribe the client: '+prospectUpdateResult.getErrors();
            }
            saveResultResponseList.add(saveResultResponse);
        }
        return saveResultResponseList;
    }

    public class CommunicationNotificatioWrap {
        public Id clientId;
        public String clientEmail;
    }

    public class UnsubscriptionResponse{
        Id clientId;
        String clientEmail;
        String message;
    }

}