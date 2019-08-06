//test

public class ApprovalsBatch implements Database.Batchable<sObject>
{

    public List<ProcessInstance> allApprovals;
    public boolean releaselist = false; //completion flag
    public String selectedValue;
    public Id userId;
    public Set<Id> queueIdSet;
	
    public ApprovalsBatch (String selValue, Id usrId, Set<Id> IdSet)
    {
        selectedValue = selValue;
        userId = usrId;
        queueIdSet = IdSet;
    }
    
    public Database.QueryLocator start (Database.BatchableContext ctx)
    {
        return Database.getQueryLocator([SELECT Id,Status,LastActor.Name, CompletedDate, ElapsedTimeInDays, ElapsedTimeInHours, 
                                            ElapsedTimeInMinutes,LastActorId, ProcessDefinitionId,ProcessDefinition.Name, TargetObjectId, 
                                            TargetObject.Name,CreatedDate, SubmittedById, SubmittedBy.Name,
                                            (SELECT Id, ActorId, ProcessInstanceId, OriginalActorId, OriginalActor.Name, Actor.Name,
                                             ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes FROM Workitems ORDER By CreatedDate DESC)
                                            FROM ProcessInstance 
                                            WHERE TargetObject.Type = :selectedValue
                                            /*WHERE (TargetObject.Type = 'nu_dse__Offer__c' OR TargetObject.Type = 'nu_dse__Prospect__c') 
                                            AND Status != 'Approved' AND Status != 'Rejected'*/
                                            ORDER By CreatedDate DESC LIMIT 10000]);
    }
    public void execute(Database.BatchableContext ctx, List<sObject> scope)
    {
        List<ProcessInstance> approvals = (List<ProcessInstance>) scope;
        allApprovals.addAll(approvals);

    }
    public void finish (Database.BatchableContext ctx)
    {
        releaselist = true;
    }
    public List<ProcessInstance> getList ()
    {
        if (releaselist)
        {
            return allApprovals;
        }
            return null; 
    }
}