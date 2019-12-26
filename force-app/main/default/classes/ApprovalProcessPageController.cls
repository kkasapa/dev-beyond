public with sharing class ApprovalProcessPageController {
    public nu_dse__Prospect__c prospectRecord {get;set;}
    public String correctId{get;set;}
    
    //
    public String queryString {get;set;}
    public  nu_dse__Prospect__c ProspectList {get;set;}
    
    public ApprovalProcessPageController() {    
        String currentRecordId ='';
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('retURL');
       
        String str = currentRecordId;
        correctId = str.substringAfter('/');
        
         
        //
        queryString ='Select ';
        
        for(Schema.FieldSetMember fld :this.getFields()){
          QueryString +=fld.getFieldPath() + ', ';
          }
           QueryString += 'id, Name From nu_dse__Prospect__c where Id=: correctId';
            ProspectList = (nu_dse__Prospect__c )database.query(QueryString);
        
        
        
        //
        
        prospectRecord = [Select id,nu_dse__Prospect_Status__c,Rejection_Reason_Pick__c,Name FROM nu_dse__Prospect__c WHERE id =: correctId];
        
        
    }
    
    public list<schema.fieldsetMember> getFields(){
    return SobjectType.nu_dse__Prospect__c.FieldSets.ApprovalsProspect.getFields();
    }
    
    public PageReference approveAStep(){
        try{
            if(prospectRecord.nu_dse__Prospect_Status__c == 'Approval'){
                ProcessInstanceWorkitem workItem = [SELECT Id, ProcessInstanceId 
                                                FROM ProcessInstanceWorkitem 
                                                WHERE ProcessInstance.TargetObjectId =:correctId 
                                               ];
            
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);                
            req.setAction('Approve');
            req.setComments('Your record is approved');
            
            
            Approval.ProcessResult processResult = Approval.process(req);
            return new PageReference('/' + correctId); 
            }else if(prospectRecord.nu_dse__Prospect_Status__c == 'Clear to Close'){
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Already Approved');
            ApexPages.addMessage(msg);
            return null;
                
            }
            else{
                return null;
            }
                       
        }
        catch(Exception e){
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'There is some error on Page, Contact Admin');
            ApexPages.addMessage(msg);
            return null;
        }
        
    }
    
    public PageReference rejectRecord(){
        
        
        if(prospectRecord.Rejection_Reason_Pick__c == '' || prospectRecord.Rejection_Reason_Pick__c == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter Rejection Reason');
            ApexPages.addMessage(msg);
            return null;
        }else{
            update prospectRecord;
            /*
            PageReference ReturnPage = new PageReference('/' + correctId);
            ReturnPage.setRedirect(true); 
            return ReturnPage; 
            */
            ProcessInstanceWorkitem workItem = [SELECT Id, ProcessInstanceId 
                                                FROM ProcessInstanceWorkitem 
                                                WHERE ProcessInstance.TargetObjectId =:correctId 
                                               ];
            
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);                
            req.setAction('Reject');
            req.setComments('');
            
            
            Approval.ProcessResult processResult = Approval.process(req);
            return new PageReference('/' + correctId);
            
        }
    }
    
    public PageReference CancelRec(){
        return new PageReference('/' + correctId);
    }
}