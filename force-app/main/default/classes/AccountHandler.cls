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

    public override void afterUpdate() {
        for(Account newAccount: (List<Account>)Trigger.new) {
            createBLP_BusList(newAccount, oldAccountMap.get(newAccount.Id));
        }

        if (BLPBUSEvents.isEmpty() == false) {
            EventBus.publish(BLPBUSEvents);
        }
    }

    //filters Accounts that have changes in Applicant/Co-Applicant that are to be synced with BLP
    public void createBLP_BusList(Account newAccount, Account oldAccount) {
        if (newAccount.FirstName != oldAccount.FirstName 
                    || newAccount.LastName != oldAccount.LastName 
                    || newAccount.PersonBirthdate != oldAccount.PersonBirthdate 
                    || newAccount.PersonEmail != oldAccount.PersonEmail
                    || newAccount.PersonMailingAddress != oldAccount.PersonMailingAddress 
                    || newAccount.PersonMobilePhone != oldAccount.PersonMobilePhone
                    || newAccount.PersonOtherPhone != oldAccount.PersonOtherPhone 
                    || newAccount.Phone != oldAccount.Phone
                    || newAccount.nu_dse__SSN__c != oldAccount.nu_dse__SSN__c 
                    || newAccount.nu_dse__SSN__c != oldAccount.nu_dse__SSN__c
                    || newAccount.nu_dse__co_other_phone__c != oldAccount.nu_dse__co_other_phone__c 
                    || newAccount.nu_dse__Co_Address_Line__c != oldAccount.nu_dse__Co_Address_Line__c
                    || newAccount.nu_dse__Co_Addressline2__c != oldAccount.nu_dse__Co_Addressline2__c 
                    || newAccount.nu_dse__CO_Best_Phone__c != oldAccount.nu_dse__CO_Best_Phone__c
                    || newAccount.nu_dse__CO_Email_Address__c != oldAccount.nu_dse__CO_Email_Address__c 
                    || newAccount.nu_dse__CO_Home_Phone__c != oldAccount.nu_dse__CO_Home_Phone__c
                    || newAccount.nu_dse__Co_First_Name__c != oldAccount.nu_dse__Co_First_Name__c 
                    || newAccount.nu_dse__Co_Last_Name__c != oldAccount.nu_dse__Co_Last_Name__c
                    || newAccount.nu_dse__CO_Cell_Phone__c != oldAccount.nu_dse__CO_Cell_Phone__c 
                    || newAccount.nu_dse__Co_Date_of_Birth__c != oldAccount.nu_dse__Co_Date_of_Birth__c
                    || newAccount.nu_dse__Co_Phone__c != oldAccount.nu_dse__Co_Phone__c
                    || newAccount.nu_dse__Co_Postal_Code__c != oldAccount.nu_dse__Co_Postal_Code__c
                    || newAccount.nu_dse__Co_SSN__c != oldAccount.nu_dse__Co_SSN__c
                    || newAccount.nu_dse__Co_State__c != oldAccount.nu_dse__Co_State__c
                    || newAccount.nu_dse__External_CFT_ID__c != oldAccount.nu_dse__External_CFT_ID__c) {
            BLPBUSEvents.add(new BLP_Bus__e(action__c='update', account_id__c=newAccount.Id));
        }
    }
}