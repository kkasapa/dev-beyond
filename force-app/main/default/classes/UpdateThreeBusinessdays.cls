/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Class for Updating Custom Setting. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Avco Team - Karthik Kasapa <kkasapa@beyondfinance.com>
* @created        Dec 2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class UpdateThreeBusinessdays {
    
    public static  void UpdateThreeBdays(){
      
        BusinessDays__c Bst = BusinessDays__c.getOrgDefaults();
        system.debug('I am BST'+Bst);
        Bst.Three_Business_Days__c = Holidays.calculateNthWorkingDay(Date.Today(), 3);
        update bst;
        
    }
}