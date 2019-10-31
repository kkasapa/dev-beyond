public with sharing class TestRecordCreator {
    
    public static Account createAccount (String lstName, Id recordTypeId) {
        
        Account accountInstance = new Account(FirstName = 'Test',
                                              LastName = lstName,
                                              RecordTypeId = recordTypeId);
        return accountInstance;
    }
    
    public static Account createCreditorAccount (Id recordTypeId) {
        
        Account accountInstance = new Account(Name = 'Test Creditor Account',
                                              RecordTypeId = recordTypeId);
        return accountInstance;
        
    }
    
    public static nu_dse__Prospect__c createProspect() {
        
        nu_dse__Prospect__c prospectInstance = new nu_dse__Prospect__c(nu_dse__First_Name__c = 'Test', 
                                                                       nu_dse__Last_name__c = 'Prospect');
        
        return prospectInstance;
    }
    
    public static nu_dse__Prospect__c createProspect(Id processorId) {
        
        nu_dse__Prospect__c prospect = new nu_dse__Prospect__c(nu_dse__First_Name__c ='TestProspect1', nu_dse__Last_name__c = 'Test1',nu_dse__Processor__c = processorId,
                            nu_dse__DOB__c = System.today()-50, nu_dse__Address_Line_1__c = 'Test1', nu_dse__Address_Line_2__c = 'Test2',nu_dse__City__c = 'Clio', nu_dse__Postal_Code__c = '12578', 
                            nu_dse__State__c = 'NY', nu_dse__SSN_ENC__c = '457-78-4512', nu_dse__Email_Address__c = 'ttt@test.com', nu_dse__Country__c = 'US'  );
        return prospect;
    }
    
    public static nu_dse__Program__c createProgram(Id accountId, Id processorId) {
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c(nu_dse__Account__c = accountId, 
                                                                    nu_dse__Processor__c = processorId,
                                                                    Language__c = 'German',
                                                                    nu_dse__Payment_Frequency__c = 'Monthly',
                                                                    nu_dse__Program_Length__c = 2);
        return programInstance;
    }
    
    public static Task createTask(Id whatId) {
        
        Task taskInstance = new Task(Subject = 'Testing ', 
                                     Description = 'to use it in test class', 
                                     WhatId = whatId, 
                                     Status = 'In Progress',
                                     ActivityDate = System.today(),
                                     nu_dse__Is_Sticky_Note__c = true );
        return taskInstance;
    }
    
    public static nu_dse__Processor__c createProcessor(String processorName){
        
        nu_dse__Processor__c newProcessor = New nu_dse__Processor__c(Name = processorName, nu_dse__Is_Default__c = True);
        return newProcessor;
    }
    
    public static nu_dse__TradeLine__c createTradeLine(Id AccId, Id programId){
        
        Id recId = [select id from RecordType where sObjectType='Account' and developerName='Creditor' limit 1].id;
        Account creditor = createCreditorAccount(recId);
        insert creditor; 
        
        nu_dse__TradeLine__c trdLine = new nu_dse__TradeLine__c(
                                                nu_dse__Program__c = programId,
                                                nu_dse__Percentage__c = 10,
                                                nu_dse__Original_Debt__c = 10000,
                                                nu_dse__Original_Account_Number__c = '8746876756'
                                               );
        return trdLine;
    } 
    
    public static nu_dse__Quote__c createQuote(Id prospectId) {
        
        nu_dse__Quote__c quoteInstance = new nu_dse__Quote__c(nu_dse__Prospect__c = prospectId, nu_dse__Status__c = 'New', nu_dse__Program_Length__c = 10, 
                                            nu_dse__Program_Fees__c = 1000, nu_dse__Payment_Frequency__c = 'Monthly');
        
        return quoteInstance;
    }
    
    public static Attachment createAttachment(Id AccId){
        
        Attachment newAttachment = new Attachment(Name = 'AttachmentName', Body = Blob.valueOf('Attachment Body'), ParentId = AccId);
        
        return newAttachment;
    }
    public static nu_dse__Financial_profile__c createFinancialProfile(Id prospectId) {
    
        nu_dse__Financial_profile__c financialProfile = new nu_dse__Financial_profile__c(Name = 'Test', nu_dse__prospect__c = prospectId );
        
        return financialProfile;
    }
    public static nu_dse__Offer__c createoffer(Id programId, Id tradeId, Integer offerAmount, Integer programFee, Integer numOfFeePaymnts, Integer numOfPaymnts) {
        
        nu_dse__Offer__c offerInstance = new nu_dse__Offer__c(nu_dse__Program__c = programId, 
                                                                  nu_dse__TradeLine__c = tradeId, 
                                                                  nu_dse__Offer_Amount__c = offerAmount, 
                                                                  nu_dse__Program_Fee__c = programFee, 
                                                                  nu_dse__number_of_Fee_payments__c = numOfFeePaymnts, 
                                                                  nu_dse__Number_of_Payments__c = numOfPaymnts, 
                                                                  nu_dse__First_Payment_Date__c = System.today().addDays(1),
                                                                  nu_dse__Program_Fee_Start_Date__c= System.today().addDays(1));
        
        return offerInstance;
        
    }
    
     public static nu_dse__Payment__c createPayment(Id programId, String transactionStatus, String paymentType, Id recordTypeId, Id offerId){
        
        nu_dse__Payment__c newPayment = new nu_dse__Payment__c(nu_dse__Program__c = programId, 
                                                                nu_dse__Transaction_Status__c = transactionStatus, 
                                                                nu_dse__Payment_Type__c = paymentType, 
                                                                nu_dse__Schedule_Date__c = system.today() + 1, 
                                                                nu_dse__Amount__c = 500, 
                                                                RecordTypeId = recordTypeId, 
                                                                nu_dse__Offer__c = offerId);
        return newPayment;
    }
    
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        Id recordTypeId;
        
        if (recordTypeMap.containsKey(recordTypeName)) {
            
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
            System.debug('**recordTypeId'+recordTypeId);
        }
        
        return recordTypeId;
        
    }
    
    public static nu_dse__Bank_Account__c createBankAccount(Id programId) {
        
        nu_dse__Bank_Account__c bankAccountInstance = new nu_dse__Bank_Account__c(nu_dse__Program__c = programId,
                                                                                  nu_dse__Bank_Name__c = 'Test Bank', 
                                                                                  nu_dse__Account_Type__c = 'Saving', 
                                                                                  nu_dse__Bank_Account_Number__c = '1245225', 
                                                                                  nu_dse__Routing_Number__c = '41414141',
                                                                                  nu_dse__Holder_s_Name__c = 'TestHolderName');
        
        return bankAccountInstance;
    
    }
    
    public static nu_dse__Fee_Template__c createFeeTemplate() {
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test Fee', nu_dse__Maximum_Program_Length__c = 1000, nu_dse__Default__c = True, 
                                            nu_dse__Settlement_Pct__c = 7, nu_dse__GCS_Fee_Group_Id__c = '70292');
        
        return feeTemp;
    }
    
    public static nu_dse__Fee_Item__c createfeeItem(Id rectypeId, Id feeTemp) {
    
        nu_dse__Fee_Item__c feeItem = new nu_dse__Fee_Item__c(nu_dse__Fee_Template__c = feeTemp, nu_dse__Percent__c = 10 , RecordTypeId = rectypeId, Name = 'Test', 
                                                                                        nu_dse__Fee_Amount__c = 10000, nu_dse__Fee_basis__c = 'Debt', nu_dse__CFT_Subscriber_Fee_Id__c = '27556', 
                                                                                        nu_dse__Frequency__c = 'Monthly', nu_dse__Debit_Type__c = 'M');
        return feeItem;
    }
    
    public static nu_dse__Group_Task__c createGroupTask(Id relatedToId) {
    
        nu_dse__Group_Task__c groupTaskRec = new nu_dse__Group_Task__c(nu_dse__Related_To__c = relatedToId, nu_dse__Subject__c = 'Test', nu_dse__Description__c = 'Test Description', nu_dse__ActivityDate__c = system.today());
        return groupTaskRec;
    }
    
    public static nu_dse__Data_Mapping__c ABTestingProspect() {
        
        nu_dse__Data_Mapping__c datamappingInstance = new nu_dse__Data_Mapping__c(Name = 'ABTestingProspectToProspect', 
                                                                    Filter_Criteria__c = 'nu_dse__First_Name__c =  \''+'Test'+'\'',
                                                                    Filter_Percent__c = 100);
        return datamappingInstance;
    }    
    
    public static nu_dse__Data_Mapping__c ABTestingProgram() {
        
        nu_dse__Data_Mapping__c datamappingInstance = new nu_dse__Data_Mapping__c(Name = 'ABTestingProspectToProgram', 
                                                                    Filter_Criteria__c = 'Language__c  =  \''+'German'+'\'',
                                                                    Filter_Percent__c = 100);
        return datamappingInstance;
    }
    
     public static nu_dse__Data_Mapping__c createDataMapping(String name, String sourceObj, String destObj) {
        
        nu_dse__Data_Mapping__c datamappingInstance = new nu_dse__Data_Mapping__c(Name = name, 
                                                                    nu_dse__Source_sObject__c = sourceObj,
                                                                    nu_dse__Target_sObject__c = destObj);
        return datamappingInstance;
    }    
    
    public static nu_dse__Field_mapping__c createFieldMapping(Id DataMappingId, String sourceFie, String targetFie, Boolean isSetDefVal, String defVal) {
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c (nu_dse__Data_Mapping__c = DataMappingId,
                                                                      nu_dse__Source_Field__c = sourceFie,
                                                                      nu_dse__Target_Field__c = targetFie,
                                                                      nu_dse__setDefaultValue__c = isSetDefVal,
                                                                      nu_dse__Default_Value__c = defVal );
        return fieldMappingInstance;
    }
    
    public static List<nu_dse__Field_mapping__c> ABTestingFieldMap(Id DataMappingId) {
        
        List<nu_dse__Field_mapping__c> fieldmappingList = new List<nu_dse__Field_mapping__c>();
        nu_dse__Field_mapping__c fieldmappingInstance = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId, 
                                                                    nu_dse__Default_Value__c = 'True', nu_dse__Target_Field__c = 'Available_for_AB_Testing__c',
                                                                    nu_dse__setDefaultValue__c = True, nu_dse__Source_Field__c = 'Available_for_AB_Testing__c');
        fieldmappingList.add(fieldmappingInstance);
        
        nu_dse__Field_mapping__c fieldmappingInstance1 = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId, 
                                                                    nu_dse__Default_Value__c = 'Test User', nu_dse__Target_Field__c = 'nu_dse__First_Name__c',
                                                                    nu_dse__setDefaultValue__c = True, nu_dse__Source_Field__c = 'nu_dse__First_Name__c');
        fieldmappingList.add(fieldmappingInstance1);
        
        nu_dse__Field_mapping__c fieldmappingInstance2 = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId, 
                                                                    nu_dse__Target_Field__c = 'nu_dse__CO_Last_Name__c', nu_dse__Source_Field__c = 'nu_dse__Last_name__c');
        fieldmappingList.add(fieldmappingInstance2);
        return fieldmappingList;
    }
    
     public static List<nu_dse__Field_mapping__c> ABTestingFieldMap2(Id DataMappingId) {
        
        List<nu_dse__Field_mapping__c> fieldmappingList = new List<nu_dse__Field_mapping__c>();
        nu_dse__Field_mapping__c fieldmappingInstance = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId, 
                                                                    nu_dse__Default_Value__c = 'True', nu_dse__Target_Field__c = 'Available_for_AB_Testing__c',
                                                                    nu_dse__setDefaultValue__c = True, nu_dse__Source_Field__c = 'Available_for_AB_Testing__c');
        fieldmappingList.add(fieldmappingInstance);
        
         nu_dse__Field_mapping__c fieldmappingInstance2 = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId, 
                                                                    nu_dse__Target_Field__c = 'nu_dse__Last_Disposition__c', nu_dse__Source_Field__c = 'nu_dse__Disposition__c');
        fieldmappingList.add(fieldmappingInstance2);
         
         nu_dse__Field_mapping__c fieldmappingInstance3 = new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = DataMappingId,  nu_dse__Default_Value__c = 'Call Completed', nu_dse__setDefaultValue__c = True,
                                                                    nu_dse__Target_Field__c = 'SalesPerson__c', nu_dse__Source_Field__c = 'SalesPerson__c');
        fieldmappingList.add(fieldmappingInstance3);
        return fieldmappingList;
    }
    
    public static AWS_Credentials_Settings__c createAwsCredentialsSettings() {
        
        AWS_Credentials_Settings__c awsCredentialsSetting = new AWS_Credentials_Settings__c (ACL__c = 'XYZ',
                                                                                             Bucket_Name__c = 'ABCD',
                                                                                             Key__c = '1234',
                                                                                             Secret__c = 'AB12');
        return awsCredentialsSetting ;
    }
    
    public static Loan_Application__c createLoanApplication(Id programId) {
        
        Loan_Application__c loan = new Loan_Application__c (program_name__c =  programId,
                                                    		Application_Status__c = '04-Preapproved');
        return loan ;
    }
}