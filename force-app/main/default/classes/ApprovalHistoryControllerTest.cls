/**
* This is the test class for ApprovalHistoryController
* @Author: Avco Team
* @Created Date: 11/20/2019 
*/
@isTest
public class ApprovalHistoryControllerTest {
    static testMethod void validateApprovalHistory(){
   		nu_dse__Prospect__c prospectInstance = TestRecordCreator.createProspect();
		prospectInstance.Needs_Approval__c = true;
        insert prospectInstance;   
        
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(prospectInstance.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(userinfo.getUserId());
		
		ApexPages.StandardController sc = new ApexPages.StandardController(prospectInstance);
		ApprovalHistoryController obj = new ApprovalHistoryController(sc);
		
        list<ProcessInstanceWorkitem> lstOfpiw = [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:prospectInstance.Id LIMIT 1];
        
		Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
		pwr.setAction('Removed');
		pwr.setWorkItemId(lstOfpiw[0].id);
		Approval.ProcessResult result = Approval.process(pwr);

		obj.doSubmitForApproval();
    } 
}