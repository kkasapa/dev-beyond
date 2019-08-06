/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for BLPBusTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly   <rmathews@beyondfinance.com>
* @modifiedBy     Resly   <rmathews@beyondfinance.com>
* @maintainedBy   Resly   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-07-16
* @modified       2019-07-26
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class BLPBusHandler extends TriggerHandler {

    private Map<Id, BLP_Bus__e> newBLPBusMap;

    public BLPBusHandler() {
        this.newBLPBusMap = (Map<Id, BLP_Bus__e>) Trigger.newMap;
    }

    public override void afterInsert() {
        for (BLP_Bus__e newBusEvent : (List<BLP_Bus__e>)Trigger.New) {
            AWSSQS.sendMessageAttrib('BODY', 'action', newBusEvent.action__c, 'String', 'program_id', newBusEvent.program_id__c, 'String');
        }
    }
}