/**
* This is the extension class for ApprovalHistoryPage
* @Author: Avco Team
* @Created Date: 11/15/2019 
*/
public class ApprovalHistoryController {     
    public list<approvalHistroy> approvalHistroies{get;set;}
    public nu_dse__Prospect__c currentRecord{get;set;}
    public ProcessInstanceWorkitem piwobj{get;set;}
    public boolean isRecallShow{get;set;}
    
    public ApprovalHistoryController(ApexPages.StandardController controller){
        approvalHistroies = new list<approvalHistroy>();   
        currentRecord = new nu_dse__Prospect__c();
        this.currentRecord = (nu_dse__Prospect__c)controller.getRecord();
        set<Id> pDefIds = new set<Id>();
        
        list<ProcessInstanceWorkitem> lstOfpiw = [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:currentRecord.Id LIMIT 1];
        if(!lstOfpiw.isEmpty()){
            piwobj = lstOfpiw[0];
        }else
            piwobj = new ProcessInstanceWorkitem();
        list<ProcessInstance> lstOfPis = [SELECT Id,LastActorId,ProcessDefinition.Name,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId,lastmodifiedDate,
                                          (SELECT Id,SystemModstamp, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, StepStatus, Comments, ProcessNode.Name, CreatedDate FROM StepsAndWorkitems WHERE StepStatus = 'Pending' order by SystemModstamp desc LIMIT 1),
                                          (SELECT Id,createdDate, StepStatus,ProcessInstance.createdDate,ActorId,Actor.Name,Actor.Type,Comments,OriginalActorId,OriginalActor.Name,OriginalActor.Type,SystemModstamp FROM Steps order by createdDate desc) 
                                          FROM ProcessInstance WHERE TargetObjectId =:currentRecord.Id order by SystemModstamp desc];
        for(ProcessInstance piObj : lstOfPis){
            pDefIds.add(piObj.ProcessDefinitionId);    
        }
        map<Id,ProcessNode> mapOfStepNode = new Map<Id,ProcessNode>();
        for(ProcessNode pNode  : [SELECT Id,Name,ProcessDefinitionId FROM ProcessNode WHERE ProcessDefinitionId = :pDefIds] ){
            mapOfStepNode.put(pNode.ProcessDefinitionId,pNode);
        }
        for(ProcessInstance piObj : lstOfPis){
            system.debug('**ProcessDefinitionId**'+piObj.ProcessDefinitionId);
            approvalHistroy ahisObj = new approvalHistroy();
            ahisObj.overall_status      = (piObj.Status == 'Removed' ? 'Recalled' : piObj.Status);
            if(piObj.Status == 'Removed'){
                ahisObj.action              = 'Approval Request Recalled';	
            }else
                ahisObj.action              = 'Step:'+mapOfStepNode.get(piObj.ProcessDefinitionId).Name +(piObj.Status == 'Pending' ? '(Pending for first approval)': '');
            approvalHistroies.add(ahisObj);
            if(piObj.Status == 'Pending'){
                isRecallShow = true;
                for (ProcessInstanceHistory pih : piObj.StepsAndWorkItems) {
                    ahisObj = new approvalHistroy();
                    ahisObj.Status      		= 'Pending';
                    ahisObj.assigned_To         = pih.OriginalActorId;
                    ahisObj.assigned_To_name 	= pih.OriginalActor.Name;
                    ahisObj.actualApprover_name = pih.Actor.Name;
                    ahisObj.actualApprover      = pih.ActorId;
                    ahisObj.comments            = pih.Comments;
                    ahisObj.Dt                  = pih.SystemModstamp.format();
                    if(ahisObj.actualApprover.startsWith('005'))
                        ahisObj.isactualApproverisQ = false;
                    else
                        ahisObj.isactualApproverisQ = true;
                    
                    if(ahisObj.assigned_To.startsWith('005'))
                        ahisObj.isAssignedisQ = false;
                    else
                        ahisObj.isAssignedisQ = true;
                    approvalHistroies.add(ahisObj);    
                }                        
            }
            if(!piObj.Steps.isEmpty()){
                for(ProcessInstanceStep stpObj : piObj.Steps){
                    if(stpObj.StepStatus == 'Started'){
                        ahisObj = new approvalHistroy();
                        ahisObj.action              = 'Approval Request Submitted';
                        approvalHistroies.add(ahisObj);    
                    } 
                    
                    ahisObj = new approvalHistroy();
                    ahisObj.status              = (stpObj.StepStatus == 'Started' ? 'Submitted': (stpObj.StepStatus == 'Removed' ? 'Recalled' : stpObj.StepStatus));
                    ahisObj.actualApprover_name = stpObj.Actor.Name;
                    ahisObj.actualApprover      = stpObj.ActorId;
                    ahisObj.assigned_To_name    = stpObj.OriginalActor.Name;
                    ahisObj.assigned_To         = stpObj.OriginalActorId;
                    if(ahisObj.actualApprover.startsWith('005'))
                        ahisObj.isactualApproverisQ = false;
                    else
                        ahisObj.isactualApproverisQ = true;
                    
                    if(ahisObj.assigned_To.startsWith('005'))
                        ahisObj.isAssignedisQ = false;
                    else
                        ahisObj.isAssignedisQ = true;
                    ahisObj.comments            = stpObj.Comments;
                    ahisObj.Dt                  = stpObj.createdDate.format();
                    system.debug('**Step Status**'+stpObj.StepStatus); 
                    approvalHistroies.add(ahisObj);
                }       
            }    
        }   
    }
    
    public void doSubmitForApproval(){
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(currentRecord.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(userinfo.getUserId()); 
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    public class approvalHistroy{
        public string action{get;set;}
        public string Dt{get;set;}
        public string status{get;set;}
        public string assigned_To{get;set;}
        public string assigned_To_name{get;set;}
        public string assigned_To_type{get;set;}
        public boolean isAssignedisQ{get;set;}
        public string actualApprover{get;set;}
        public string actualApprover_name{get;set;}
        public string actualApprover_type{get;set;}
        public boolean isactualApproverisQ{get;set;}
        public string comments{get;set;}
        public string overall_status{get;set;}
    }
}