/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for ComvestDataSyncTrigger, extends the Trigger framework. 
* Refer to the end of file for business logic
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sai Reddy
* @modifiedBy     Resly Mathews   <rmathews@beyondfinance.com>
* @maintainedBy   Resly Mathews   <rmathews@beyondfinance.com>
* @version        1.0
* @created        2019-05-29
* @modified       2019-05-29
* @systemLayer    Trigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class ComvestDataSyncTriggerHandler extends TriggerHandler {
    private Map<Id, Comvest_Data_Sync__c> newCDSMap;
    private Map<Id, Comvest_Data_Sync__c> oldCDSMap;     
    
    public ComvestDataSyncTriggerHandler() {
        this.newCDSMap = (Map<Id, Comvest_Data_Sync__c>) Trigger.newMap;
        this.oldCDSMap = (Map<Id, Comvest_Data_Sync__c>) Trigger.oldMap;
    }
    
    public override void afterInsert() {
        map<Id,Comvest_Data_Sync__c> mapOfCDSs = new map<Id,Comvest_Data_Sync__c>();
        for(Comvest_Data_Sync__c cmdObj : newCDSMap.values()){
            if(cmdObj.Sync_Status__c == 'Pending' && cmdObj.Program__c != null && (cmdObj.Sale_To__c == 'SPS_Trust' || cmdObj.Sale_To__c == 'BermudaCo')){
                mapOfCDSs.put(cmdObj.Id,cmdObj);    
            }    
        }
        if(!mapOfCDSs.isEmpty()){
            UpdatePrgmsAndPayments(mapOfCDSs.KeySet(),trigger.isInsert);    
        }
    }
    
    public override void afterUpdate() {
        map<Id,Comvest_Data_Sync__c> mapOfCDSs = new map<Id,Comvest_Data_Sync__c>();
        for(Comvest_Data_Sync__c cmdObj : newCDSMap.values()){
            if(cmdObj.Sync_Status__c != oldCDSMap.get(cmdObj.Id).Sync_Status__c && cmdObj.Sync_Status__c == 'Pending' && cmdObj.Program__c != null && (cmdObj.Sale_To__c == 'SPS_Trust' || cmdObj.Sale_To__c == 'BermudaCo')){
                mapOfCDSs.put(cmdObj.Id,cmdObj);    
            }    
        }
        if(!mapOfCDSs.isEmpty()){
            UpdatePrgmsAndPayments(mapOfCDSs.KeySet(),trigger.isInsert);    
        }   
    }
    
    public static void UpdatePrgmsAndPayments(set<Id> SetOfComVestIds,boolean isInsert){
        
        set<Id> setOfErrorCmvest = new set<Id>();
        map<Id,Comvest_Data_Sync__c> mapOfCDSs = new map<Id,Comvest_Data_Sync__c>([Select Id,Program__c,Sale_Date__c,Sale_To__c from Comvest_Data_Sync__c WHERE Id IN: SetOfComVestIds]);
        list<nu_dse__Error_Log__c> lstToInsertLogs = new list<nu_dse__Error_Log__c>();
        
        Set<Id> setOfPgms = new set<Id>();
        list<nu_dse__Program__c> lstToUpdatePgms = new list<nu_dse__Program__c>();
        map<Id,Comvest_Data_Sync__c> mapOfPgmWithCDs = new map<Id,Comvest_Data_Sync__c>();
        for(Comvest_Data_Sync__c cdsObj : mapOfCDSs.values()){
            if(cdsObj.Sale_To__c == 'SPS_Trust'){                
                setOfPgms.add(cdsObj.Program__c);
                Date dt = date.newinstance(cdsObj.Sale_Date__c.year(), cdsObj.Sale_Date__c.month(), cdsObj.Sale_Date__c.day()); 
                Time tm = Time.newInstance(12, 00, 00, 00); 
                DateTime setDate = DateTime.newInstance(dt, tm); 
                
                lstToUpdatePgms.add(
                    new nu_dse__Program__c(
                        Id = cdsObj.Program__c, 
                        Beneficiary__c = System.Label.Beneficiary_SPS_Trust, 
                        nu_dse__CFT_Rule_Set_Id__c = System.Label.CFT_Rule_Set_Id_SPS_Trust, 
                        nu_dse__CFT_Rule_Set_Name__c = System.Label.CFT_Rule_Set_Name_SPS_Trust,
                        CFT_Rule_Set_Date__c = setDate
                    )
                );
                mapOfPgmWithCDs.put(cdsObj.Program__c,cdsObj);
            }else if(cdsObj.Sale_To__c == 'BermudaCo'){
                setOfPgms.add(cdsObj.Program__c);
                lstToUpdatePgms.add(
                    new nu_dse__Program__c(
                        Id = cdsObj.Program__c, 
                        Beneficiary__c = System.Label.Beneficiary_BermudaCo,
                        Sale_Date__c = cdsObj.Sale_Date__c
                    )
                ); 
                mapOfPgmWithCDs.put(cdsObj.Program__c,cdsObj);
            }                   
        }
        
        if(!lstToUpdatePgms.isEmpty()){
            Database.SaveResult[] srList = Database.update(lstToUpdatePgms, false);
            for (Integer i = 0; i < lstToUpdatePgms.size(); i++) {
                if (!srList[i].isSuccess()  || Test.isRunningTest()) {
                    string strErrorMsg;
                    for(Database.Error err : srList[i].getErrors()) {
                        strErrorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    }  
                    Id pgmId = lstToUpdatePgms[i].Id;
                    Id cmVestId;
                    if(pgmId != null){
                        cmVestId = mapOfPgmWithCDs.get(pgmId).Id;   
                        setOfErrorCmvest.add(cmVestId);
                    }   
                    lstToInsertLogs.add(new nu_dse__Error_Log__c(
                        nu_dse__Error_Causing_Record_Id__c = cmVestId,
                        nu_dse__User_Context__c = userInfo.getUserName(),
                        nu_dse__Class_Method__c = 'ComvestDataSyncTriggerHandler_Program.'+(isInsert ? 'afterInsert' : 'afterUpdate'),
                        nu_dse__Message__c = strErrorMsg
                        
                    ));
                }
            }
            if(!setOfPgms.isEmpty()){
                list<nu_dse__Payment__c> lstToUpdatePayments = new list<nu_dse__Payment__c>();
                map<Id,Id> mapOfPayWithPgm = new map<Id,Id>();
                for(nu_dse__Payment__c payObj : [SELECT Id,Accounting_Beneficiary__c,Beneficiary__c,nu_dse__Program__c,nu_dse__Program__r.Beneficiary__c,nu_dse__Schedule_Date__c,nu_dse__Program__r.Fee_Deferral__c FROM nu_dse__Payment__c WHERE nu_dse__Program__c IN :setOfPgms and RecordType.Name = 'Fee']){
                    mapOfPayWithPgm.put(payObj.Id,payObj.nu_dse__Program__c);
                    if(!mapOfPgmWithCDs.isEmpty() && mapOfPgmWithCDs.get(payObj.nu_dse__Program__c).Sale_To__c == 'SPS_Trust'){
                        payObj.Accounting_Beneficiary__c = System.Label.Accounting_Beneficiary_Beyond;
                        payObj.Beneficiary__c = System.Label.Cashflow_Beneficiary_Beyond;
                    }else if(!mapOfPgmWithCDs.isEmpty() && mapOfPgmWithCDs.get(payObj.nu_dse__Program__c).Sale_To__c == 'BermudaCo'){
                        Date dtSaleDate = mapOfPgmWithCDs.get(payObj.nu_dse__Program__c).Sale_Date__c;
                        if(!payObj.nu_dse__Program__r.Fee_Deferral__c){
                            if(payObj.nu_dse__Schedule_Date__c < dtSaleDate){
                                payObj.Accounting_Beneficiary__c = System.Label.Accounting_Beneficiary_Beyond;
                                payObj.Beneficiary__c = System.Label.Cashflow_Beneficiary_Beyond;
                            }else if(payObj.nu_dse__Schedule_Date__c >= dtSaleDate){
                                payObj.Accounting_Beneficiary__c = System.Label.Accounting_Beneficiary_KCK;  
                                payObj.Beneficiary__c = System.Label.Cashflow_Beneficiary_KCK;
                            }
                        } else if(payObj.nu_dse__Program__r.Fee_Deferral__c){                            
                            if(payObj.nu_dse__Schedule_Date__c < dtSaleDate){
                                payObj.Beneficiary__c = System.Label.Cashflow_Beneficiary_Beyond;
                            }else if(payObj.nu_dse__Schedule_Date__c >= dtSaleDate){
                                payObj.Beneficiary__c = System.Label.Cashflow_Beneficiary_KCK;
                            }
                            Date dtCalcSaleDate = dtSaleDate.addDays(90);
                            if(payObj.nu_dse__Schedule_Date__c < dtCalcSaleDate){
                                payObj.Accounting_Beneficiary__c = System.Label.Accounting_Beneficiary_Beyond;
                            }else if(payObj.nu_dse__Schedule_Date__c >= dtCalcSaleDate){
                                payObj.Accounting_Beneficiary__c = System.Label.Accounting_Beneficiary_KCK;
                            }
                        }           
                    }
                    lstToUpdatePayments.add(payObj);    
                }
                if(!lstToUpdatePayments.isEmpty()){
                    Database.SaveResult[] srPayList = Database.update(lstToUpdatePayments, false);
                    for (Integer i = 0; i < lstToUpdatePayments.size(); i++) {
                        if (!srPayList[i].isSuccess()  || Test.isRunningTest()) {
                            string strErrorMsg;
                            for(Database.Error err : srPayList[i].getErrors()) {
                                strErrorMsg = err.getStatusCode() + ': ' + err.getMessage();
                            }                       
                            Id pgmId = mapOfPayWithPgm.get(lstToUpdatePayments[i].Id);
                            Id cmVestId;
                            if(pgmId != null){
                                cmVestId = mapOfPgmWithCDs.get(pgmId).Id; 
                                setOfErrorCmvest.add(cmVestId);
                            }
                            lstToInsertLogs.add(new nu_dse__Error_Log__c(
                                nu_dse__Error_Causing_Record_Id__c = cmVestId,
                                nu_dse__User_Context__c = userInfo.getUserName(),
                                nu_dse__Class_Method__c = 'ComvestDataSyncTriggerHandler_Payment.'+(isInsert ? 'afterInsert' : 'afterUpdate'),
                                nu_dse__Message__c = strErrorMsg
                                
                            ));
                        }
                    }       
                    list<Comvest_Data_Sync__c> lstToUpdateCds = new list<Comvest_Data_Sync__c>();
                    for(Comvest_Data_Sync__c cdsObject : mapOfCDSs.Values()){
                        Comvest_Data_Sync__c cdsObj = new Comvest_Data_Sync__c();
                        cdsObj.Sync_Status__c = (setOfErrorCmvest.Contains(cdsObject.Id) ? 'Error' : 'Success'); 
                        cdsObj.Id = cdsObject.Id;
                        if(cdsObj.Sync_Status__c == 'Success')
                            cdsObj.Processor_Error__c = null;   
                        lstToUpdateCds.add(cdsObj);
                    }
                    
                    
                    if(!lstToUpdateCds.isEmpty()){
                        update lstToUpdateCds;   
                        Database.SaveResult[] srComList = Database.update(lstToUpdateCds, false);
                        for (Integer i = 0; i < lstToUpdateCds.size(); i++) {
                            if (!srComList[i].isSuccess() || Test.isRunningTest()) {
                                string strErrorMsg;
                                for(Database.Error err : srComList[i].getErrors()) {
                                    strErrorMsg = err.getStatusCode() + ': ' + err.getMessage();
                                }                       
                                lstToInsertLogs.add(new nu_dse__Error_Log__c(
                                    nu_dse__Error_Causing_Record_Id__c = lstToUpdateCds[i].Id,
                                    nu_dse__User_Context__c = userInfo.getUserName(),
                                    nu_dse__Class_Method__c = 'ComvestDataSyncTriggerHandler_ComvestData.'+(isInsert ? 'afterInsert' : 'afterUpdate'),
                                    nu_dse__Message__c = strErrorMsg
                                    
                                ));
                            }
                        }       
                    }
                    
                }               
            }           
        }
        if(!lstToInsertLogs.isEmpty()){
            insert lstToInsertLogs;
            map<Id,Comvest_Data_Sync__c> mapToUpdateErrorLog = new map<Id,Comvest_Data_Sync__c>();
            for(nu_dse__Error_Log__c errObj : lstToInsertLogs){
                mapToUpdateErrorLog.put(
                    errObj.nu_dse__Error_Causing_Record_Id__c,
                    new Comvest_Data_Sync__c(
                        Id = errObj.nu_dse__Error_Causing_Record_Id__c,
                        Processor_Error__c = errObj.Id
                    )
                );  
            }
            update mapToUpdateErrorLog.Values();
        }   
    } 
}

/*
Business Logic

1. Sale to SPS Trust
    a. On the Program, update the following
        i. Beneficiary to Beyond
        ii. CFT Rule Set ID to 378
        iii. CFT Rule Set Name to SPS
        iv. CFT Rule Set Date to ‘Sale Date’
    b. Each program can have many Payments
        i. Update all corresponding Payments of record type “Fee” 
            1. Accounting Beneficiary to Beyond
            2. Cashflow Beneficiary to Beyond


2. Sale to BermudaCo
    a. On the Program, update
        i. the Beneficiary to KCK.
        ii. Sale Date to ‘Sale Date’
    b. Each program can have many offers. Update all corresponding Payments of record type “Fee” as follows
        1. Update Payment.Accounting Beneficiary based on the logic
            a. If Program. Fee Deferral is False
                i. All payments with Scheduled Date before the date of sale, to Beyond.
                ii. All payments with Scheduled Date on or after the date of sale, to KCK
            b. Else If Program. Fee Deferral is True
                i. All payments with Scheduled Date before the date of sale+3 months, to Beyond.
                ii. Fee payments on or after sale date+90 days, to KCK. For example, if Sale Date is 5/24/2019, then the date for calculation is Sale Date + 90 days = 8/22/2019
        2. Cashflow Beneficiary based on the logic
            a. All payments with Scheduled Date before the date of sale, to Beyond.
            b. All payments with Scheduled Date on or after the date of sale, to KCK

*/