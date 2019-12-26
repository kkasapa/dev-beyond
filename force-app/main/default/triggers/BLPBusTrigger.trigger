/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Trigger on platform event BLP_Bus_e 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Resly   <rmathews@beyondfinance.com>
* @modifiedBy     Ashwin   <abretto@beyondfinance.com>
* @maintainedBy   Resly   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-07-16
* @modified       2019-08-17
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
trigger BLPBusTrigger on BLP_Bus__e (after insert) {
	new BLPBusHandler().run();
}