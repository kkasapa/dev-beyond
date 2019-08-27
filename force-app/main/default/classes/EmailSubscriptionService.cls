/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Service class for unsubscribing the  marketting/notifications emails 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-08-20
* @modified       2019-08-26
* @Layer          Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class EmailSubscriptionService {

    // this method process the request from API and collectd ids/emails of client to unsubscribe them from emails
    public static void unsubscribe(RestRequest apiRequest) {
      
        Set<Id> clientProspectIds = new Set<Id>(); // set of Ids of Prospect who is to be unsubscribed from emails
        Set<Id> clientAccountIds = new Set<Id>(); // set of Ids of Person Account(Enrolled client) who is to be unsubscribed from emails
        Set<String> clientEmails = new Set<String>(); // set of emails of client(both prospect & enrolled) who is to be unsubscribed from emails
        
        try{
            List<EmailSubscriptionService.CommunicationNotificatioWrap> requestList = (List<EmailSubscriptionService.CommunicationNotificatioWrap>)JSON.deserialize(apiRequest.requestBody.toString(), List<EmailSubscriptionService.CommunicationNotificatioWrap>.class);
            for(CommunicationNotificatioWrap reqWrap: requestList) { 
                if(String.isNotBlank(reqWrap.clientId) == true) {
                    if(getIdType(reqWrap.clientId) == 'nu_dse__Prospect__c') {
                        clientProspectIds.add(reqWrap.clientId);
                    } else if(getIdType(reqWrap.clientId) == 'Account') {
                        clientAccountIds.add(reqWrap.clientId);
                    } else if(getIdType(reqWrap.clientId) == 'nu_dse__Payment__c') {
                        // unsubscribe logic
                    } 
                } else if(String.isNotBlank(reqWrap.clientEmail) == true) {

                } else {
                    //throw *customException*;
                }
            }
            if (clientProspectIds != null && clientProspectIds.isEmpty() == false) {
                unsubscribeProspectsfromEmail(clientProspectIds);
            }
            if (clientAccountIds != null && clientAccountIds.isEmpty() == false) {
                unsubscribePersonAccountfromEmail(clientAccountIds);
            }        
        } catch(Exception e) {

        } 
    }

    public static void unsubscribeProspectsfromEmail(Set<Id> prospectIds) {
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM nu_dse__Prospect__c WHERE Id IN :prospectIds];
        for (nu_dse__Prospect__c prospect: prospectList) {
            prospect.Unsubscribed_from_Emails__c = true;
        }
        update prospectList;
    }

    public static void unsubscribeProspectsfromEmail(Set<String> clientEmails) {
        List<nu_dse__Prospect__c> prospectList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM nu_dse__Prospect__c WHERE nu_dse__Email_Address__c IN :clientEmails];
        for (nu_dse__Prospect__c prospect: prospectList) {
            prospect.Unsubscribed_from_Emails__c = true;
        }
        update prospectList;
    }

    public static void unsubscribePersonAccountfromEmail(Set<Id> personAccountIds) {
        List<Account> personAccountList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM Account WHERE Id IN :personAccountIds];
        for (Account personAccount: personAccountList) {
            personAccount.Unsubscribed_from_Emails__c = true;
        }
        update personAccountList;
    }

    public static void unsubscribePersonAccountfromEmail(Set<String> clientEmails) {
        List<Account> personAccountList = [SELECT Id, Name, Unsubscribed_from_Emails__c
                                                    FROM Account WHERE PersonEmail IN :clientEmails];
        for (Account personAccount: personAccountList) {
            personAccount.Unsubscribed_from_Emails__c = true;
        }
        update personAccountList;
    }

    public static String getIdType(Id recId) {
        return recId.getSobjectType().getDescribe().getName();
    }

    public Boolean validateEmail(String emailString) {

        Pattern emailPattern = Pattern.compile('/([a-z]|[0-9]|[_.]){3,}[@]{1}[a-z]{2,}[.][a-z]{2,3}/g'); //pattern for email validation regular expression
        Matcher emailStringMatcher = emailPattern.matcher(emailString); // matches the emailstring with pattern
        return emailStringMatcher.matches() == true; //return true if valid email
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

    public class CommunicationNotificatioWrap {
        public Id clientId;
        public String clientEmail;
    }
}