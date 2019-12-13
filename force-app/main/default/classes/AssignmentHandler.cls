/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for AssignmentTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Digu 
* @modifiedBy     
* @maintainedBy   Digu
* @version        1.0
* @created        2019-12-11
* @modified       2019-12-11
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AssignmentHandler extends TriggerHandler{
    private Map<Id,Assignment__c> NewAssignmentsMap;
    private Map<Id,Assignment__c> OldAssignmentMap;
    
    public AssignmentHandler(){
        this.NewAssignmentsMap =(Map<Id,Assignment__c>)Trigger.newMap;
        this.OldAssignmentMap =(Map<Id,Assignment__c>)Trigger.oldmap;
    }
    
    Map<Id,nu_dse__Program__c> ParentPrograms = New Map<Id,nu_dse__Program__c>();
    List<id> Assignmentids = New List<id>();
    
    public override void afterInsert() {
        for(Assignment__c Assn:NewAssignmentsMap.values()){
            if(Assn.Negotiator__c != null){
          Assignmentids.add(Assn.Program_Name__c);
            }
        }
        
        ParentPrograms = new Map<Id,nu_dse__Program__c>([SELECT Id,Name,Negotiator__c,(Select id,Negotiator__c,Program_Name__c from Assignments__r) From nu_dse__Program__c Where ID IN:Assignmentids]);
        
        for(Assignment__c Assnment:NewAssignmentsMap.values()){
           nu_dse__Program__c  myParentPrograms = ParentPrograms.get(Assnment.Program_Name__c);
           myParentPrograms.Negotiator__c = Assnment.Negotiator__c;
        }
        
        update ParentPrograms.values();
    }

}