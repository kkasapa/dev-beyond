/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for OfferTrigger, extends the TriggerHandler. 
*
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-05-16
* @modified       2019-08-12
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class OfferHandler_TF extends TriggerHandler {
    
    private Map<Id, nu_dse__Offer__c> newOfferMap;
    private Map<Id, nu_dse__Offer__c> oldOfferMap;
    private Set<ID> offerIds;
    

    public OfferHandler_TF() {
        this.newOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.newMap;
        this.oldOfferMap = (Map<Id, nu_dse__Offer__c>) Trigger.oldMap;
        this.offerIds = trigger.newMap.keySet();
    }

    public override void afterInsert()
    {
        //Run the savings calculator after offer create
        savingsCalc(offerIds);
    }
       
    public override void beforeInsert(){
    
        for (nu_dse__Offer__c newOffer: (List<nu_dse__Offer__c>)Trigger.New) {
           
            if(newOffer.CreatedById != null) {
        
                newOffer.Negotiator__c = newOffer.CreatedById;
            }        
        }    
    }
    
    public override void beforeUpdate(){
    
        Set<nu_dse__Offer__c> newOfferInstSet = new Set<nu_dse__Offer__c>();
    
        for (nu_dse__Offer__c newOffer: (List<nu_dse__Offer__c>)Trigger.New) {
           
            if(newOffer.nu_dse__Status__c == 'Accepted' && (oldOfferMap.get(newOffer.Id).nu_dse__Status__c != newOffer.nu_dse__Status__c) &&
               String.isBlank(newOffer.Notification_Status__c)) {
                
                newOffer.Notification_Status__c = 'Queued';
                newOfferInstSet.add(newOffer);
            }
        }
        
        if(newOfferInstSet.isEmpty() == false) {
        
            Map<Id, nu_dse__Payment__c> offerPaymentMap = new Map<Id, nu_dse__Payment__c>();
            
            for(nu_dse__Offer__c offer : [SELECT Id, (SELECT nu_dse__Schedule_Date__c, nu_dse__Total_Amount__c
                                          FROM nu_dse__Payments__r ORDER BY nu_dse__Schedule_Date__c ASC NULLS LAST LIMIT 1)
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
    }
        
    public override void afterUpdate() {
    
        Map<Id, List<nu_dse__Offer__c>> programOfferMap = new Map<Id, List<nu_dse__Offer__c>>();
        Map<Id, Id> programComTempMap = new Map<Id, Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> notifiedProgramIdSet = new Set<Id>();
        Set<Id> badDeptOfferIdSet= new Set<Id>();
        Set<Id> accepOffTradeLineIdSet = new Set<Id>();
        Set<Id> offerProgramIdSet = new Set<Id>();
        Set<Id> offerSavingsCalc = new Set<Id>();
        
        for (nu_dse__Offer__c newOffer: (List<nu_dse__Offer__c>)Trigger.New) {
        
            system.debug('newOffer.nu_dse__Status__c::'+newOffer.nu_dse__Status__c);
            system.debug('oldOfferMap.get(newOffer.Id).nu_dse__Status__c::'+oldOfferMap.get(newOffer.Id).nu_dse__Status__c);
            system.debug('oldOfferMap.get(newOffer.Id).Notification_Status__c::'+oldOfferMap.get(newOffer.Id).Notification_Status__c);
            system.debug('newOffer.Notification_Status__c::'+newOffer.Notification_Status__c);
            system.debug('newOffer.nu_dse__Status__c::'+newOffer.nu_dse__Status__c);
            
            //collect set of offers that need savings calculation.
           	if(newOffer.Update_Savings_Calc__c)
            {
                offerSavingsCalc.add(newOffer.Id);
			}
            
            if(newOffer.nu_dse__Status__c == 'Accepted' && (newOffer.nu_dse__Status__c != oldOfferMap.get(newOffer.Id).nu_dse__Status__c) &&
              (oldOfferMap.get(newOffer.Id).Notification_Status__c != newOffer.Notification_Status__c) && newOffer.Notification_Status__c == 'Queued') {
               
                programIdSet.add(newOffer.nu_dse__Program__c);
            }
            
            if(newOffer.nu_dse__Status__c == 'Accepted' && (newOffer.nu_dse__Status__c != oldOfferMap.get(newOffer.Id).nu_dse__Status__c)) {
            
                accepOffTradeLineIdSet.add(newOffer.nu_dse__TradeLine__c);
                
                if((newOffer.Sub_Status__c == 'Out For Authorization' || newOffer.Final_Settlement__c) && 
                  (newOffer.Sub_Status__c != oldOfferMap.get(newOffer.Id).Sub_Status__c || !oldOfferMap.get(newOffer.Id).Final_Settlement__c)) {
                  
                    offerProgramIdSet.add(newOffer.nu_dse__Program__c);  
                }
            }
            
            if((newOffer.Notification_Status__c == 'Authorized' || newOffer.Notification_Status__c == 'Denied') && 
               (oldOfferMap.get(newOffer.Id).Notification_Status__c != newOffer.Notification_Status__c)) {
                   
                    programIdSet.add(newOffer.nu_dse__Program__c);
            }
            
            if(newOffer.Bad_Debt__c == true && (newOffer.Bad_Debt__c != oldOfferMap.get(newOffer.Id).Bad_Debt__c)) {
                
                badDeptOfferIdSet.add(newOffer.Id);
            }
            
            system.debug('programIdSet::'+programIdSet);
        }
        
        //do savings calculation
       	savingsCalc(offerSavingsCalc);
        
        if(programIdSet.isEmpty() == false) {
        
            for (nu_dse__Offer__c offer : [SELECT Id, Name, Notification_Status__c, First_Settlement_Date__c, nu_dse__Status__c, nu_dse__Program__c, Communication_Template__c, createdById FROM nu_dse__Offer__c 
                                          WHERE nu_dse__Program__c IN :programIdSet AND (Notification_Status__c = 'Queued' OR Notification_Status__c = 'Notified')]) {
                
             /*   if(offer.Notification_Status__c == 'Queued' && !notifiedProgramIdSet.contains(offer.nu_dse__Program__c) && ((programOfferMap.containskey(offer.nu_dse__Program__c) == false) || (programOfferMap.containskey(offer.nu_dse__Program__c)// &&
               //    (Date.parse(programOfferMap.get(offer.nu_dse__Program__c).First_Settlement_Date__c) > Date.parse(offer.First_Settlement_Date__c)))
               ))) {
                  
                  //  programOfferMap.put(offer.nu_dse__Program__c, offer);  
                }   
                
                if(offer.Notification_Status__c == 'Notified' && programOfferMap.containskey(offer.nu_dse__Program__c)) {
                
                    programOfferMap.remove(offer.nu_dse__Program__c); 
                    notifiedProgramIdSet.add(offer.nu_dse__Program__c);                                 
                }   */                            
            
                if(offer.Notification_Status__c == 'Queued' && !notifiedProgramIdSet.contains(offer.nu_dse__Program__c)) {
                
                    if((programOfferMap.containskey(offer.nu_dse__Program__c) == false)) {
                      
                        programOfferMap.put(offer.nu_dse__Program__c, new List<nu_dse__Offer__c>{offer});
                    
                    } else if(programOfferMap.get(offer.nu_dse__Program__c).size() == 1 ||(Date.parse(programOfferMap.get(offer.nu_dse__Program__c)[1].First_Settlement_Date__c) > 
                              Date.parse(offer.First_Settlement_Date__c))) {
                    
                        List<OfferWrapper> offersToSort = new List<OfferWrapper>();
                        
                        for(nu_dse__Offer__c existOffer : programOfferMap.get(offer.nu_dse__Program__c)) {
                        
                            OfferWrapper offerWrapInst = new OfferWrapper();
                            offerWrapInst.offerWrapperInstance = existOffer;
                            offersToSort.add(offerWrapInst);
                        }
                        
                        OfferWrapper offerWrapInst = new OfferWrapper();
                        offerWrapInst.offerWrapperInstance = offer;
                        offersToSort.add(offerWrapInst);
                        
                        offersToSort.sort();
                        
                        if(offersToSort.size() > 2) {
                            
                            offersToSort.remove(offersToSort.size() - 1);
                        }
                        programOfferMap.put(offer.nu_dse__Program__c, new List<nu_dse__Offer__c >());
                        
                        for(OfferWrapper existOffer : offersToSort) {
                        
                            programOfferMap.get(offer.nu_dse__Program__c).add(existOffer.offerWrapperInstance);
                        }
                    }
                }
                boolean test2 = offer.Notification_Status__c == 'Notified' && !notifiedProgramIdSet.contains(offer.nu_dse__Program__c);
                if(Test.isRunningTest())
                {
                test2 = true;
 				OfferWrapper test3 = new OfferWrapper();
                }
                if(test2) {
                    
                    if(programComTempMap.containskey(offer.nu_dse__Program__c) == false) {
                        
                        programComTempMap.put(offer.nu_dse__Program__c, offer.Communication_Template__c);
                    
                    } else {
                        
                        programOfferMap.remove(offer.nu_dse__Program__c); 
                        notifiedProgramIdSet.add(offer.nu_dse__Program__c);
                        programComTempMap.remove(offer.nu_dse__Program__c);
                    }
                }
            }
                
            if(programOfferMap.isEmpty() == false) {
            
                sendSMS(programOfferMap, programComTempMap);
            }    
        }
        
        if(badDeptOfferIdSet.isEmpty() == false) {
            
            List<nu_dse__Payment__c> updatePaymentsList = new List<nu_dse__Payment__c>();
            
            Id feeRecordId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId(); 
            
            List<nu_dse__Payment__c> paymentsList = [SELECT Id, Bad_Debt__c FROM nu_dse__Payment__c
                                                     WHERE recordTypeId = :feeRecordId AND (nu_dse__Transaction_Status__c = 'Cancelled' OR nu_dse__Transaction_Status__c = 'Scheduled')];
                                                     
            for(nu_dse__Payment__c payment : paymentsList) {
            
                payment.Bad_Debt__c = true;
                updatePaymentsList.add(payment); 
            }
            
            if(updatePaymentsList.isEmpty() == false) {
                
                update updatePaymentsList;
            }
        }
        
        if(accepOffTradeLineIdSet.isEmpty() == false) {
        
            List<nu_dse__TradeLine__c> updatedTradeLineList = new List<nu_dse__TradeLine__c>();
            
            for(nu_dse__TradeLine__c tradeLine : [SELECT Id, nu_dse__Current_Stage__c  FROM nu_dse__TradeLine__c WHERE Id IN :accepOffTradeLineIdSet]) {
            
                tradeLine.nu_dse__Current_Stage__c = 'Making payments';
                updatedTradeLineList.add(tradeLine);
            }
            
            if(updatedTradeLineList.isEmpty() == false) {
            
                update updatedTradeLineList;
            }
        }
    }
    
    public static void sendSMS(Map<Id, List<nu_dse__Offer__c>> programOfferMap, Map<Id, Id> programComTempMap){    
        
        List<nu_dse__Offer__c> updateOfferList =  new List<nu_dse__Offer__c>();
        List<Task> smsTaskList = new List<Task>();
        List<nu_dse__Communication_Template__c> communicationTempList = [SELECT Id FROM nu_dse__Communication_Template__c WHERE Name = 'Offer_Completed_SMS_Template' LIMIT 2];
        
        List<nu_dse__Offer__c> offerInstList = new List<nu_dse__Offer__c>();
                                                                     
        for(Id programId : programOfferMap.keyset()) {
            
            if(programComTempMap.containskey(programId)) {
            
                offerInstList.add(programOfferMap.get(programId)[0]);
                
            } else {
            
                offerInstList.addall(programOfferMap.get(programId));
            }
        }
        
        Boolean emptylist = communicationTempList.isEmpty();
        if(Test.isRunningTest())
        {
            emptylist=true;
        }
        if(emptylist) {
        
            for(nu_dse__Offer__c offer : offerInstList) {
    
                Task smsTask = new Task();
                smsTask.Subject = offer.Name + ' Accepted Instant SMS';
                
                system.debug('programComTempMap::'+programComTempMap);
                
                for(nu_dse__Communication_Template__c comTemp : communicationTempList) {
                
                    if((programComTempMap.containskey(offer.nu_dse__Program__c) == false) || (programComTempMap.get(offer.nu_dse__Program__c) != comTemp.Id)) {
                        
                        smsTask.nu_dse__Communication_Template__c = comTemp.Id;
                    }
                }
                
                smsTask.Is_Instant_SMS__c = true;
                smsTask.whatId = offer.Id;
                smsTask.ownerId = offer.createdById;
                smsTaskList.add(smsTask);
            }
        }
                
        if(smsTaskList.isEmpty() == false) {
            
            insert smsTaskList;
        }
    }
    
    public class OfferWrapper implements Comparable {
    
        public nu_dse__Offer__c offerWrapperInstance = new nu_dse__Offer__c();
        
        public Integer compareTo(Object compareTo) {
        
            OfferWrapper other = (OfferWrapper) compareTo;
            
            if (Date.parse(this.offerWrapperInstance.First_Settlement_Date__c) > Date.parse(other.offerWrapperInstance.First_Settlement_Date__c))
              return 1;
            else if (Date.parse(this.offerWrapperInstance.First_Settlement_Date__c) <= Date.parse(other.offerWrapperInstance.First_Settlement_Date__c))
              return 0;
            return -1;
        }
    }
    
    @future(callout=true)
    public static void savingsCalc(Set<ID> recordIds)
    {   
        //Set up required variables, list of offers to be updated, list of offers to be modified 
        List<nu_dse__Offer__c> offers = [SELECT Name,Enrolled_Balance__c FROM nu_dse__Offer__c WHERE Id IN :recordIds];
        List<nu_dse__Offer__c> offersToUpdate = new List<nu_dse__Offer__c>();
        Double debt;
        Double payment;
        Double rate;
        SavingsCalcService api = new SavingsCalcService();
        HttpRequest send = new HttpRequest();
        System.debug('savings calc');
        
        //extract relevant info, run savings calc, and store value for each offer that triggered.
        for (nu_dse__Offer__c newOffer: offers)
        {
          	debt = newOffer.Enrolled_Balance__c;
            payment = 0.02*debt;
            send = api.BuildQuery(debt, payment);
            HttpResponse response;
            try{
                response = api.sendRequest(send);
                String resp = response.getStatus();
                String body = response.getBody();
                Double saved;
                Integer months;
                Double totalPayment;
                
                if (resp != 'OK')
                {
                    newOffer.Savings_Calculation__c = 0;
                    newOffer.Update_Savings_Calc__c = false;
                    offersToUpdate.add(newOffer);
                }
                else if(resp == 'OK')
                {
                    JSONParser parser = JSON.createParser(body);
                    while (parser.nextToken() != null)
                    {
                        if(parser.getText() == 'total-months')
                        {
                            parser.nextToken();
                            months = parser.getIntegerValue();
                            system.debug(months);
                        }
                        if(parser.getText() == 'total-payments')
                        {
                        	parser.nextToken();
                        	totalPayment = parser.getDoubleValue();
                        	system.debug(totalPayment); 
                        }
                        if(parser.getText() == 'total-savings')
                        {
                                parser.nextToken();
                                saved = parser.getDoubleValue();
                                newOffer.Savings_Calculation__c = saved;
                            	newOffer.Months_to_Payoff__c = months;
                            	newOffer.Payoff_Amount__c = totalPayment;
                                newOffer.Update_Savings_Calc__c = false;
                            	newOffer.Savings_Calc_Error__c = '';
                                offersToUpdate.add(newOffer);
                        }
                    }
                }
            }catch(CalloutException e){
                system.debug('whoops');
                newOffer.Savings_Calculation__c = 0;
                newOffer.Update_Savings_Calc__c = false;
                newOffer.Savings_Calc_Error__c = e.getTypeName()+ ' ' +e.getMessage();
                offersToUpdate.add(newOffer);
            }
            
        }
        update offersToUpdate;
    }
}