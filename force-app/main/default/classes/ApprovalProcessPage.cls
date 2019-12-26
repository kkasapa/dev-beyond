public with sharing class ApprovalProcessPage {
    public nu_dse__Prospect__c prospectRecord {get;set;}
    public String correctId{get;set;}
    
    public ApprovalProcessPage() {    
        String currentRecordId ='';
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('retURL');
        
        String str = currentRecordId;
        correctId = str.substringAfter('/');
        
        
        prospectRecord = [Select id,nu_dse__Prospect_Status__c,Rejection_Reason_Pick__c,Name FROM nu_dse__Prospect__c WHERE id =: correctId];
        
        }
    
    public PageReference approveAStep(){
        
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
    }
    
     public PageReference CancelRec(){
         return new PageReference('/' + correctId);
    }
    }