public class OfferHandler {

    public static void handle(List<nu_dse__Offer__c> newOffers, Map<id,nu_dse__Offer__c> oldOffers){
        
        
        Set<nu_dse__Offer__c> offerInstSet = new Set<nu_dse__Offer__c>();
        Set<nu_dse__Offer__c> newOfferInstSet = new Set<nu_dse__Offer__c>();
        Map<Id, nu_dse__Offer__c> programOfferMap = new Map<Id, nu_dse__Offer__c>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> notifiedProgramIdSet = new Set<Id>();
        
        for(nu_dse__Offer__c offer : newOffers) {

            if(offer.nu_dse__Status__c == 'Reserved' && (oldOffers.get(offer.Id).nu_dse__Status__c != offer.nu_dse__Status__c) &&
               String.isBlank(offer.Notification_Status__c)) {
                
                offer.Notification_Status__c = 'Queued';
                newOfferInstSet.add(offer);
            }
            
            if(offer.nu_dse__Status__c == 'Reserved' && (oldOffers.get(offer.Id).Notification_Status__c != offer.Notification_Status__c)
               && offer.Notification_Status__c == 'Queued' && Trigger.isAfter) {
               
                if((programOfferMap.containskey(offer.nu_dse__Program__c) == false) || (programOfferMap.containskey(offer.nu_dse__Program__c) &&
                   Date.valueof(programOfferMap.get(offer.nu_dse__Program__c).First_Settlement_Date__c) > Date.valueof(offer.First_Settlement_Date__c))) {
                  
                    programOfferMap.put(offer.nu_dse__Program__c, offer);
                    programIdSet.add(offer.nu_dse__Program__c);
                }
            }
            
            if((offer.Notification_Status__c == 'Authorized' || offer.Notification_Status__c == 'Denied') && 
               (oldOffers.get(offer.Id).Notification_Status__c != offer.Notification_Status__c) && Trigger.isAfter) {
               
                programIdSet.add(offer.nu_dse__Program__c);
            }
        }
        
        if(newOfferInstSet.isEmpty() == false) {
        
            Map<Id, nu_dse__Payment__c> offerPaymentMap = new Map<Id, nu_dse__Payment__c>();
            
            for(nu_dse__Offer__c offer : [SELECT Id, (SELECT nu_dse__Schedule_Date__c, nu_dse__Total_Amount__c
                                          FROM nu_dse__Payments__r ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 1)
                                          FROM nu_dse__Offer__c WHERE Id IN :newOfferInstSet]) {
                
                if(offer.nu_dse__Payments__r != null && offer.nu_dse__Payments__r.isEmpty() == false) {                          
                    
                    offerPaymentMap.put(offer.Id, offer.nu_dse__Payments__r[0]);
                }
            }
            
            for(nu_dse__Offer__c offer : newOfferInstSet) {
                
                if(offerPaymentMap.containskey(offer.Id)) {
                 
                    offer.First_Settlement_Date__c = offerPaymentMap.get(offer.Id).nu_dse__Schedule_Date__c.format(); 
                    offer.First_Payment_Amount__c = offerPaymentMap.get(offer.Id).nu_dse__Total_Amount__c;
                }
            }
        }
        
        if(programIdSet.isEmpty() == false) {
        
            for (nu_dse__Offer__c offer : [SELECT Id, Name, Notification_Status__c, First_Settlement_Date__c, nu_dse__Status__c, nu_dse__Program__c, createdById FROM nu_dse__Offer__c 
                                          WHERE nu_dse__Program__c IN :programIdSet AND (Notification_Status__c = 'Queued' OR Notification_Status__c = 'Notified')]) {
                
                if(offer.Notification_Status__c == 'Queued' && !notifiedProgramIdSet.contains(offer.nu_dse__Program__c) && ((programOfferMap.containskey(offer.nu_dse__Program__c) == false) || (programOfferMap.containskey(offer.nu_dse__Program__c) &&
                   (Date.parse(programOfferMap.get(offer.nu_dse__Program__c).First_Settlement_Date__c) > Date.parse(offer.First_Settlement_Date__c))))) {
                  
                    programOfferMap.put(offer.nu_dse__Program__c, offer);  
                }   
                
                if(offer.Notification_Status__c == 'Notified' && programOfferMap.containskey(offer.nu_dse__Program__c)) {
                
                    programOfferMap.remove(offer.nu_dse__Program__c); 
                    notifiedProgramIdSet.add(offer.nu_dse__Program__c);                                 
                }                               
            }
            
            if(programOfferMap.isEmpty() == false) {
                    
                sendSMS(programOfferMap.values());
            }    
        }
    }
    
    public static void sendSMS(List<nu_dse__Offer__c> offerInstList){    
        
        List<nu_dse__Offer__c> updateOfferList =  new List<nu_dse__Offer__c>();
        List<Task> smsTaskList = new List<Task>();
        List<nu_dse__Communication_Template__c> communicationTemp = [SELECT Id FROM nu_dse__Communication_Template__c 
                                                                     WHERE Name = 'Offer_Completed_SMS_Template' LIMIT 1];
        
        for(nu_dse__Offer__c offer : offerInstList) {

            Task smsTask = new Task();
            smsTask.Subject = offer.Name + ' Accepted Instant SMS';
            smsTask.nu_dse__Communication_Template__c = communicationTemp[0].Id;
            smsTask.Is_Instant_SMS__c = true;
            smsTask.whatId = offer.Id;
            smsTask.ownerId = offer.createdById;
            smsTaskList.add(smsTask);
        }
                
        if(smsTaskList.isEmpty() == false) {
            
            insert smsTaskList;
        }
       /* List<Task> smsTaskList = new List<Task>();
        
        for(nu_dse__Offer__c offer : [SELECT nu_dse__Number_of_Payments__c, nu_dse__Offer_Amount__c, nu_dse__Program__r.nu_dse__Account__c, nu_dse__Program__r.nu_dse__Account__r.Name,
                                      nu_dse__TradeLine__r.nu_dse__New_Creditor__r.Name, nu_dse__TradeLine__r.nu_dse__Original_Creditor__r.Name, 
                                      nu_dse__TradeLine__r.nu_dse__New_Account_Number__c, nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c,
                                      nu_dse__TradeLine__r.nu_dse__Current_Balance__c, nu_dse__Payment_Re_Occuring_Day__c, nu_dse__Program__r.nu_dse__Account__r.Phone, 
                                      (SELECT nu_dse__Schedule_Date__c, nu_dse__Total_Amount__c FROM nu_dse__Payments__r ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 1)
                                      FROM nu_dse__Offer__c WHERE Id IN :offerIdSet]) {
            
            String messageBody = ''; 
                                      
            if(String.isNotBlank(offer.nu_dse__Program__r.nu_dse__Account__r.Name)) {
            
                messageBody = '(' + system.today().format()+ ') ' + offer.nu_dse__Program__r.nu_dse__Account__r.Name + ', Beyond negotiated a settlement:'+'\n';
                
            }
            
            if (String.isNotBlank(offer.nu_dse__TradeLine__r.nu_dse__Original_Creditor__r.Name)) {
                
                messageBody = messageBody + 'Acct: '+ offer.nu_dse__TradeLine__r.nu_dse__Original_Creditor__r.Name + ' x ';
                
                if(String.isNotBlank(offer.nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c)) {
                
                    messageBody = messageBody + offer.nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c.substring(offer.nu_dse__TradeLine__r.nu_dse__Original_Account_Number__c.length() - 4);
                }
                messageBody = messageBody + '\n';
            
            } else if(String.isNotBlank(offer.nu_dse__TradeLine__r.nu_dse__New_Creditor__r.Name)) {
            
                messageBody = messageBody + 'Acct: '+ offer.nu_dse__TradeLine__r.nu_dse__New_Creditor__r.Name + ' x ';
                
                if(String.isNotBlank(offer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c)) {
                
                    messageBody = messageBody + offer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c.substring(offer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c.length() - 4);
                }
                messageBody = messageBody + '\n';
            }
        
            if(offer.nu_dse__TradeLine__r.nu_dse__Current_Balance__c != null) {
                
                messageBody = messageBody + 'Current Bal: $' + offer.nu_dse__TradeLine__r.nu_dse__Current_Balance__c.format() +'\n';
            
            } else {
            
                messageBody = messageBody + 'Current Bal: $0'+ '\n';
            }
            
            if(offer.nu_dse__Offer_Amount__c != null) {
            
                messageBody = messageBody + 'Settlement: $' + offer.nu_dse__Offer_Amount__c.format()+'\n';
            
            } else {
            
                messageBody = messageBody + 'Settlement: $0'+ '\n';
            }
            
            system.debug('Payment_Re_Occuring_Day:::::'+offer.nu_dse__Payment_Re_Occuring_Day__c);
            
            if(offer.nu_dse__Number_of_Payments__c != null && offer.nu_dse__Payments__r.isEmpty() == false && offer.nu_dse__Payments__r[0].nu_dse__Schedule_Date__c != null 
               && offer.nu_dse__Payments__r[0].nu_dse__Total_Amount__c != null  && offer.nu_dse__Payment_Re_Occuring_Day__c != null) { 
            
                messageBody = messageBody + offer.nu_dse__Number_of_Payments__c + ' payments of $'+ offer.nu_dse__Payments__r[0].nu_dse__Total_Amount__c.format() + ' due on ';
                messageBody = messageBody + offer.nu_dse__Payment_Re_Occuring_Day__c.intValue() + 'th monthly starting ' + offer.nu_dse__Payments__r[0].nu_dse__Schedule_Date__c.format() + '\n';
            }
            
            messageBody = messageBody + '>>REPLY WITH LAST 4 DIGITS OF YOUR SSN to accept terms above & authorize CFT to make payments in accordance with schedule';
            
            if(offer.nu_dse__Program__r.nu_dse__Account__r.Phone != null && String.isNotBlank(messageBody)) {
                
                system.debug('messageBody:::'+messageBody);
                nu_dse.TwilioMessage message = nu_dse.TwilioCommunications.sendSMS(offer.nu_dse__Program__r.nu_dse__Account__r.Phone, messageBody);
                
                if (message.getErrorMessage() == null) {
                    
                    system.debug('message:::'+message);
                    Task smsTask = new Task(Subject = 'Send message to ' + offer.nu_dse__Program__r.nu_dse__Account__r.Phone, Description = messageBody, WhatId = offer.nu_dse__Program__r.nu_dse__Account__c);
                    smsTaskList.add(smsTask);
                }
            }
        }
        
        if(smsTaskList.isEmpty() == false) {
        
            insert smsTaskList;
        } */
    }
}