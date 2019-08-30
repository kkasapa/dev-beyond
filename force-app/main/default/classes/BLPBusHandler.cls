/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for BLPBusTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly   <rmathews@beyondfinance.com>
* @modifiedBy     Ashwin  <abretto@selastech.com>
* @maintainedBy   Resly   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-07-16
* @modified       2019-08-20
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BLPBusHandler extends TriggerHandler {

    private Map<Id, BLP_Bus__e> newBLPBusMap;

    public BLPBusHandler() {
        this.newBLPBusMap = (Map<Id, BLP_Bus__e>) Trigger.newMap;
    }
    

    public override void afterInsert() {
        Map<Id, String> accId_actionsMap = new Map<Id, String>();

        for (BLP_Bus__e newBusEvent : (List<BLP_Bus__e>)Trigger.New) {
            if (String.isNotBlank(newBusEvent.program_Id__c) == true) {
                AWSSQS.sendMessageAttrib('BODY', 'action', newBusEvent.action__c, 'String', 'program_id', newBusEvent.program_id__c, 'String');
            } else {
                accId_actionsMap.put(newBusEvent.account_Id__c, newBusEvent.action__c);
            }
        }
        invokeAPIforAccount(accId_actionsMap);

    }

    public void invokeAPIforAccount(Map<Id, String> accId_actionsMap) {
        for(nu_dse__Program__c prog: [SELECT Id, nu_dse__Account__c 
                                        FROM nu_dse__Program__c 
                                        WHERE nu_dse__Account__c IN :accId_actionsMap.keySet() AND Legal_Plan_Included__c = true]) {
            AWSSQS.sendMessageAttrib('BODY', 'action', accId_actionsMap.get(prog.nu_dse__Account__c) , 'String', 'program_id', prog.Id, 'String');                              
        }
    }
}