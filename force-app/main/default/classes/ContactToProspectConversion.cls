public class ContactToProspectConversion{ 

    public ContactToProspectConversion(){}
    // Depricate...SF-581       
    /*public static void convertToPropsect(Map<id,Contact> newcontactMap) {
             List<RecordType> recType = [SELECT id FROM RecordType WHERE SObjectType = 'nu_dse__Prospect__c' and DeveloperName='Debt_Settlement' LIMIT 1];
             List<contact> updatedContacts = new List<Contact>(); 
             List<nu_dse__Prospect__c> insertProspects = new LIst<nu_dse__Prospect__c>(); 
        
            for (Contact c :newContactMap.values()){
                
                if (c.Prospect_Created__c == False) {
                
                    nu_dse__Prospect__c p   = new nu_dse__Prospect__c();
                    p.nu_dse__First_Name__c = c.FirstName;
                    p.nu_dse__Last_Name__c  = c.LastName;
                    p.nu_dse__Email_Address__c = c.Email;
                    p.nu_dse__Prospect_Source__c = 'Digital';
                    p.nu_dse__Home_Phone__c = c.HomePhone;
                    p.nu_dse__Work_Phone__c = c.OtherPhone;
                    p.Best_Phone__c = c.Phone;
                    p.nu_dse__Cell_Phone__c = c.Phone;
                    p.Estimated_Total_Debt__c = c.Estimated_Total_Debt__c;
                    p.Debtor_Bill_Status__c = c.Debtor_Bill_Status__c;
                    p.Best_Time_to_Call__c = c.Best_Time_to_Call__c;
                    p.Remove_From_Pardot_Campaign__c = c.Remove_From_Pardot_Campaign__c;
                    p.Middle_Name__c = c.Middle_Name__c;
                    p.Mail_Date__c = c.MailDate__c;
                    p.Landing_Page__c = c.Landing_Page__c;
                    p.UTM_Content__c = c.UTM_Content__c;
                    p.UTM_Term__c = c.UTM_Term__c;
                    p.Debt_Amount_Qualification__c = c.Debt_Amount_Qualification__c;
                    p.nu_dse__DOB__c = c.Birthdate;
                    p.State_Qualification__c = c.State_Qualification__c;
                    p.Expiration_Date__c = c.Expiration_Date__c;
                    p.MailerID__c = c.MailerID__c;
                    p.UTM_Campaign__c = c.UTM_Campaign__c;
                    p.UTM_ID__c = c.UTM_ID__c;
                    p.UTM_Medium__c = c.UTM_Medium__c;
                    p.UTM_Source__c = c.UTM_Source__c;
                    p.kClickID__c = c.kClickID__c;
                    p.optimizelyExperimentID__c = c.optimizelyExperimentID__c;
                    p.optimizelyVariationID__c = c.optimizelyVariationID__c;
                    p.optimizelyVariationName__c = c.optimizelyVariationName__c;
                    p.Affiliate_ID__c = c.Affiliate_ID__c;
                    p.nu_dse__Address_Line_2__c = c.Address_2__c;
                    p.Pardot_Created__c = true;
                    p.nu_dse__Address_Line_1__c = c.Address_1__c;
                    p.nu_dse__State__c = C.MailingState;
                    p.nu_dse__City__c = C.MailingCity; 
                    p.nu_dse__Postal_Code__c = C.MailingPostalCode; 
                    p.Contact__c  = c.Id;
                    //p.OwnerId = '00G46000000YnlI';
                    
                        if(recType.size() > 0){
                            p.RecordTypeId = recType[0].Id;
                        } 
                    
                    insertProspects.add(p);
                }
            }
        
         insert insertProspects; 
        
        for(nu_dse__Prospect__c p: insertProspects){
            
            Contact c = new Contact(); 
            c.id=p.Contact__c;
            c.NuDebt_Prospect__c = p.Id; 
            
            updatedContacts.add(c);
        }
        
        update updatedContacts; 
    }*/
}