/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Handler class for AccountTrigger, extends the TriggerHandler. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ashwin Bretto   <abretto@selastech.com>
* @modifiedBy     Ashwin Bretto   <abretto@selastech.com>
* @maintainedBy   Ashwin Bretto   <abretto@selastech.com>
* @version        1.0
* @created        2019-08-16
* @modified       2019-08-16
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AccountHandler extends TriggerHandler {

    private Map<Id, Account> newAccountMap;
    private Map<Id, Account> oldAccountMap;

    public AccountHandler() {
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }

    List<BLP_Bus__e> BLPBUSEvents = new List<BLP_Bus__e>();

    public override void afterInsert() {

        for(Account newAccount: (List<Account>)Trigger.new) {
            createBLP_BusList(newAccount, null);
        }
        
    }

    public override void afterUpdate() {
        for(Account newAccount: (List<Account>)Trigger.new) {
            createBLP_BusList(newAccount, oldAccountMap.get(newAccount.Id));
        }
    }

    //filters Accounts that have changes in Applicant/Co-Applicant that are to be synced with BLP
    public void createBLP_BusList(Account newAccount, Account oldAccount) {
        /*,,
        , ,nu_dse__Co_Phone__c,nu_dse__Co_Postal_Code__c,nu_dse__Co_SSN__c,
        nu_dse__Co_State__c*/

        //if (String.isNotBlank(newAccount.nu_dse__Fee_Template__c) == true 
        //        && newAccount.Legal_Plan_Included__c == true) {
            //create BLP Bus events and append to scope variable.
            if (Trigger.isInsert) {
                BLPBUSEvents.add(new BLP_Bus__e(action__c='create', account_id__c=newAccount.Id));
            } else if (newAccount.Name != oldAccount.Name || newAccount.Name != oldAccount.Name
                        || newAccount.PersonBirthdate != oldAccount.PersonBirthdate || newAccount.PersonEmail != oldAccount.PersonEmail
                        || newAccount.PersonMailingAddress != oldAccount.PersonMailingAddress || newAccount.PersonMobilePhone != oldAccount.PersonMobilePhone
                        || newAccount.PersonOtherPhone != oldAccount.PersonOtherPhone || newAccount.Phone != oldAccount.Phone
                        || newAccount.nu_dse__SSN__c != oldAccount.nu_dse__SSN__c || newAccount.nu_dse__SSN__c != oldAccount.nu_dse__SSN__c
                        || newAccount.nu_dse__co_other_phone__c != oldAccount.nu_dse__co_other_phone__c || newAccount.nu_dse__Co_Address_Line__c != oldAccount.nu_dse__Co_Address_Line__c
                        || newAccount.nu_dse__Co_Addressline2__c != oldAccount.nu_dse__Co_Addressline2__c || newAccount.nu_dse__CO_Best_Phone__c != oldAccount.nu_dse__CO_Best_Phone__c
                        || newAccount.nu_dse__CO_Email_Address__c != oldAccount.nu_dse__CO_Email_Address__c || newAccount.nu_dse__CO_Home_Phone__c != oldAccount.nu_dse__CO_Home_Phone__c
                        || newAccount.nu_dse__Co_First_Name__c != oldAccount.nu_dse__Co_First_Name__c || newAccount.nu_dse__Co_Last_Name__c != oldAccount.nu_dse__Co_Last_Name__c
                        || newAccount.nu_dse__CO_Cell_Phone__c != oldAccount.nu_dse__CO_Cell_Phone__c || newAccount.nu_dse__Co_Date_of_Birth__c != oldAccount.nu_dse__Co_Date_of_Birth__c) {
                BLPBUSEvents.add(new BLP_Bus__e(action__c='update', account_id__c=newAccount.Id));
            }
        //} 
    }

}