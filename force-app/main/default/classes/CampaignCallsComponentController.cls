/* Date : 12-12-2017
 * Description : To render the all settlement Payments whose Offer.Status is Accepted
 */

global class CampaignCallsComponentController {
    
    @RemoteAction
    global static List<CampaignTaskWrapper> getCampaignTasks(Id recordId) {
    
        List<CampaignTaskWrapper> campaignTaskList = new List<CampaignTaskWrapper>();
        
        if(recordId != null) {
        
            for(Task taskInstance : [SELECT Id, Subject, ActivityDate, Five9__Five9Agent__c,
                                        CallDisposition, CallType,Five9__Five9Campaign__c,Five9__Five9HandleTime__c
                                        FROM Task
                                        WHERE WhatId = :recordId
                                        AND Five9__Five9SessionId__c != null
                                        ORDER BY ActivityDate ASC LIMIT 50]) {
                
                campaignTaskList.add(new CampaignTaskWrapper(taskInstance));
            }
        }
        
        return campaignTaskList;
    }
    
    global class CampaignTaskWrapper {
        
        public String subject;
        public Id recordId;
        public String five9Agent;
        public String activitydateString;
        public String callDisposition;
        public String callType;
        public string HandleTime; 
        public string Campaign;
        
        public CampaignTaskWrapper(Task taskInstance) {
            
            this.recordId = taskInstance.Id;
            this.subject = taskInstance.Subject;
            this.five9Agent = taskInstance.Five9__Five9Agent__c;
            this.callDisposition = taskInstance.CallDisposition;
            this.callType = taskInstance.CallType;
            this.HandleTime = taskInstance.Five9__Five9HandleTime__c;
            this.Campaign = taskInstance.Five9__Five9Campaign__c;
            
            this.activitydateString = toDateString(taskInstance.ActivityDate, 'MM/dd/yyyy');
        }
    }
    
    global static String toDateString(Date scheduleDate, String dateFormat) {
        
        if(scheduleDate != null) {
            
            DateTime dt = DateTime.newInstance(scheduleDate.year(), scheduleDate.month(), scheduleDate.day());
            return dt.format(dateFormat);
        }
        return '';
    }
}