@isTest
public class ApprovalsController_Test {

    @testSetup static void setup() {
        
        /*profile userProfile = new profile();
        userProfile.Name = 'System Administrator';
        userProfile.UserType= 'Salesforce';
        insert userProfile;*/
        
        
        Profile profileInstance = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User managerUserInstance = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingManager', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileInstance.Id, PostalCode = '54896', country='United States',IsActive =true,
                MobilePhone = '8529637415',
                timezonesidkey='America/Los_Angeles', username='testmanagerapprovals@noemail.com');
        insert managerUserInstance;
                
        User UserInstance = new User(alias = 'testuser', email='testUser@noemail.com',
                emailencodingkey='UTF-8', lastname='TTestUser', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileInstance.Id, PostalCode = '54896', country='United States',IsActive =true,
                MobilePhone = '8529637415', ManagerId = managerUserInstance.Id,
                timezonesidkey='America/Los_Angeles', username='testUserapprovals@noemail.com');
        insert UserInstance;
        
        Group groupInstance = new Group();
        groupInstance.Name = 'TestGroup'; 
        groupInstance.Type = 'Queue';
        insert groupInstance;
        
        GroupMember groupMemberInstance = new GroupMember( GroupId = groupInstance.Id, UserOrGroupId = userInstance.Id);
        insert groupMemberInstance;
        
       
                
        /*List<ProcessInstance> ProcessInstanceList = new List<ProcessInstance> {
        
            new ProcessInstance(
                  Status = 'Started',
                  CompletedDate = date.newinstance(2019, 2, 17),
                  //ElapsedTimeInDays = 0.0006018518518518519,
                  //ElapsedTimeInHours = 0.014444444444444444,
                  //ElapsedTimeInMinutes = 0.8666666666666667,
                  LastActorId = userInstance.Id
                  //ProcessDefinitionId = 
                  //TargetObjectId = 
                  //SubmittedById = userInstance.Id
            ),
            new ProcessInstance(
                  Status = 'Pending',
                  CompletedDate = date.newinstance(2019, 2, 17)
            ),
            new ProcessInstance(
                  Status = 'Approved',
                  CompletedDate = date.newinstance(2019, 2, 17)
            )
        };
        insert ProcessInstanceList ;*/
    }
    
    static testMethod void approvalProcess() {
    
        User userQueryInstance = [SELECT Id FROM User WHERE lastname='TTestUser' LIMIT 1];
        
        nu_dse__Prospect__c prospectInstance = new nu_dse__Prospect__c();
        prospectInstance.nu_dse__First_Name__c = 'Test Prospect';
        prospectInstance.nu_dse__Last_Name__c = 'Test Approval';
        insert prospectInstance;
        
        Approval.ProcessSubmitRequest requestForSubmit = new Approval.ProcessSubmitRequest();
        requestForSubmit.setComments('Submit for Approve.');
        requestForSubmit.setNextApproverIds(new Id[] {userQueryInstance.Id});
        requestForSubmit.setObjectId(prospectInstance.Id);
        requestForSubmit.setSkipEntryCriteria(true);
        Approval.ProcessResult submitResult = Approval.process(requestForSubmit);

        List<ProcessInstanceWorkitem> workItemList = [SELECT Id,ProcessInstanceId 
                                                      FROM ProcessInstanceWorkitem LIMIT 1];

        Approval.ProcessWorkitemRequest rejectRequest = new Approval.ProcessWorkitemRequest();
        rejectRequest.setComments('Rejecting request.');
        rejectRequest.setAction('Reject');
        rejectRequest.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        rejectRequest.setWorkitemId(workItemList[0].Id);
        Approval.ProcessResult rejectResult =  Approval.process(rejectRequest);

        Approval.ProcessSubmitRequest resubmitRequest = new Approval.ProcessSubmitRequest();
        resubmitRequest.setComments('Resubmit for Approve.');
        resubmitRequest.setNextApproverIds(new Id[] {userQueryInstance.Id});
        resubmitRequest.setObjectId(prospectInstance.Id);
        resubmitRequest.setSkipEntryCriteria(true);
        Approval.ProcessResult resubmitResult = Approval.process(resubmitRequest);

        Test.startTest();
            ApprovalsController approvalsCont = new ApprovalsController();
            approvalsCont.renderApprovals();
            ApexPages.currentPage().getParameters().put('filterBy', 'me');
            approvalsCont.onFilterChange();
            ApexPages.currentPage().getParameters().put('filterBy', 'all');
            approvalsCont.onFilterChange();
            ApexPages.currentPage().getParameters().put('filterBy', 'queue');
            approvalsCont.onFilterChange();

        Test.stopTest();
    }
}