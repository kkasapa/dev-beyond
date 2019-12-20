/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Handler class for tradelineTrigger, extends the TriggerHandler. 
* TestClass : SavingsCalcTest
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vignesh Sadhasivam   <vsadhasivam@selastech.com>
* @maintainedBy   Vlad Polotvtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-27
* @modified       2019-08-27
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class TradelineHandler extends TriggerHandler {
    
    private Map<Id, nu_dse__TradeLine__c> newTLMap;
    private Map<Id, nu_dse__TradeLine__c> oldTLMap;
    private Set<ID> TLIds;

    public TradelineHandler() {
        this.newTLMap = (Map<Id, nu_dse__TradeLine__c>) Trigger.newMap;
        this.oldTLMap = (Map<Id, nu_dse__TradeLine__c>) Trigger.oldMap;
    }
    
    Static Set<Id> savignCalculatedTradelineIds = new Set<Id>();//Set of Tradeline Id which has already Savings calculated
    Set<Id> savignCalcTradelineIds = new Set<Id>(); // Set of Tradeline Id for Savings Calc 
    Set<Id> savingCalcUpdateProgramIds = new Set<Id>(); // Set of Program Id for Savings Calc based on tradeline savings
    Map<Id, List<nu_dse__TradeLine__c>> programIdTradelineMap = new Map<Id, List<nu_dse__TradeLine__c>>();
    Map<Id, nu_dse__Program__c> programsToUpdate = new Map<Id,nu_dse__Program__c>();
    Set<Id> dicoverUpdateProgramIds = new Set<Id>();
    Static Set<Id> staticDicoverUpdateTradelineIds = new Set<Id>();
    
    public override void afterInsert() {
    
        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {
            // Collect tradeline Ids for Savings calculation
            collectSavingCalcTradelines(newTradeline, null);
            // Collect Program Ids for Update Program Discover Included
            collectProgramIdsforDiscoverUpdate(newTradeline, null);
        }
        
        if(savignCalcTradelineIds.isEmpty() == false) {
            // Calculate Saving calculation using callout
            calculateSavings(savignCalcTradelineIds);
        }

        if(dicoverUpdateProgramIds.isEmpty() == false) {
            // Update Program discover Included based on creditor name
            updateProgramDiscoverIncluded();
        }
        update programsToUpdate.values();
    }
    
    public override void beforeInsert() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectProgramIdsforSettlementOrder(newTradeline, null);
        }

        if(programIdTradelineMap.isEmpty() == false) {

            updateTradelineSettlementOrder();
        }
    }

    public override void beforeUpdate() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {

            collectProgramIdsforSettlementOrder(newTradeline, oldTLMap.get(newTradeline.Id));
        }

        if(programIdTradelineMap.isEmpty() == false) {

            updateTradelineSettlementOrder();
        }
    }

    public override void afterUpdate() {

        for (nu_dse__TradeLine__c newTradeline : (List<nu_dse__TradeLine__c>) trigger.new) {
            // Collect tradeline Ids for Savings calculation
            collectSavingCalcTradelines(newTradeline, oldTLMap.get(newTradeline.Id));
            //on updates on saving calc field, rolling up to Program.
            collectsavingCalcUpdates(newTradeline, oldTLMap.get(newTradeline.Id));
            //Runs Loan Update Calculations if TL Fees/Payments Outstanding/Collected is updated
            loanAppCalcUpdate(newTradeline, oldTLMap.get(newTradeline.Id));
            // Collect Program Ids for Update Program Discover Included
            collectProgramIdsforDiscoverUpdate(newTradeline, oldTLMap.get(newTradeline.Id));
        }

        if(savignCalcTradelineIds.isEmpty() == false) {
            // Calculate Saving calculation using callout
            calculateSavings(savignCalcTradelineIds);
        }

        if (savingCalcUpdateProgramIds.isEmpty() == false) {
            aggregateSavingsToProgram();
        } 

        if(dicoverUpdateProgramIds.isEmpty() == false) {
            // Update Program discover Included based on creditor name
            updateProgramDiscoverIncluded();
        }

        update programsToUpdate.values();

    }

    public void collectProgramIdsforSettlementOrder(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {
        
        Set<String> currentStageSet = new Set<String>{'Settled - Legal', 'Settled - Non Legal', 'Making payments'};
        if(newTradeline.nu_dse__Program__c != null
            && currentStageSet.contains(newTradeline.nu_dse__Current_Stage__c) == true
            && (Trigger.isInsert 
                || (newTradeline.nu_dse__Current_Stage__c != oldTradeline.nu_dse__Current_Stage__c
                    && currentStageSet.contains(oldTradeline.nu_dse__Current_Stage__c) == false))) {
            
            if(programIdTradelineMap.containsKey(newTradeline.nu_dse__Program__c) == false) {
                programIdTradelineMap.put(newTradeline.nu_dse__Program__c, new List<nu_dse__TradeLine__c> {newTradeline});
            } else {
                programIdTradelineMap.get(newTradeline.nu_dse__Program__c).add(newTradeline);
            }
        }
    }

    public void collectProgramIdsforDiscoverUpdate(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {
        
        if(newTradeline.nu_dse__Program__c != null
            && (newTradeline.nu_dse__Original_Creditor__c != null || newTradeline.nu_dse__New_Creditor__c != null)
            && staticDicoverUpdateTradelineIds.contains(newTradeline.Id) == false
            && (Trigger.isInsert 
                || (newTradeline.nu_dse__Program__c != oldTradeline.nu_dse__Program__c
                    || newTradeline.nu_dse__Original_Creditor__c != oldTradeline.nu_dse__Original_Creditor__c
                    || newTradeline.nu_dse__New_Creditor__c != oldTradeline.nu_dse__New_Creditor__c
                    || newTradeline.nu_dse__Include_In_The_Program__c != oldTradeline.nu_dse__Include_In_The_Program__c))) {
            
            dicoverUpdateProgramIds.add(newTradeline.nu_dse__Program__c);
            staticDicoverUpdateTradelineIds.add(newTradeline.Id);
        }
    }

    public void collectSavingCalcTradelines(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {

        if((newTradeline.nu_dse__Current_Balance__c  != null || newTradeline.nu_dse__Original_Debt__c != null
                || newTradeline.nu_dse__Current_Balance__c  != 0 || newTradeline.nu_dse__Original_Debt__c != 0)
                && (Trigger.isInsert 
                    || (savignCalculatedTradelineIds.contains(newTradeline.Id) == false
                        && (newTradeline.nu_dse__Current_Balance__c != oldTradeline.nu_dse__Current_Balance__c
                            || ((newTradeline.nu_dse__Current_Balance__c == null || newTradeline.nu_dse__Current_Balance__c == 0)
                                && newTradeline.nu_dse__Original_Debt__c != oldTradeline.nu_dse__Original_Debt__c))))) {

            savignCalcTradelineIds.add(newTradeline.Id);
            savignCalculatedTradelineIds.add(newTradeline.Id);
        }
    }

    public void collectsavingCalcUpdates(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {

        if(newTradeline.nu_dse__Program__c != null && (Trigger.isInsert
            || (newTradeline.nu_dse__Program__c != oldTradeline.nu_dse__Program__c
                || newTradeline.Savings_Months_to_Payoff__c != oldTradeline.Savings_Months_to_Payoff__c
                || newTradeline.Savings_Payoff_Amount__c != oldTradeline.Savings_Payoff_Amount__c
                || newTradeline.Savings_Calculated_Savings__c != oldTradeline.Savings_Calculated_Savings__c
                || newTradeline.nu_dse__Include_In_The_Program__c != oldTradeline.nu_dse__Include_In_The_Program__c ))) {

            savingCalcUpdateProgramIds.add(newTradeline.nu_dse__Program__c);
        }
    }

    public void updateProgramDiscoverIncluded() {

        for(nu_dse__TradeLine__c newTradeLine : [SELECT Id, nu_dse__Include_In_The_Program__c, nu_dse__Original_Creditor__c, 
                                                    nu_dse__Program__c, nu_dse__Original_Creditor__r.Name, 
                                                    nu_dse__New_Creditor__c, nu_dse__New_Creditor__r.name, nu_dse__Program__r.Discover_Included__c 
                                                 FROM nu_dse__TradeLine__c 
                                                 WHERE nu_dse__Program__c IN :dicoverUpdateProgramIds]) {
            
            nu_dse__Program__c updateProgram = new nu_dse__Program__c(Id = newTradeLine.nu_dse__Program__c, Discover_Included__c = false);
            
            if(programsToUpdate.containskey(updateProgram.Id)) {
                updateProgram = programsToUpdate.get(updateProgram.Id);
            }
            if(((newTradeLine.nu_dse__Original_Creditor__c != null && newTradeLine.nu_dse__Original_Creditor__r.Name == 'Discover') 
                || (newTradeLine.nu_dse__New_Creditor__c != null && newTradeLine.nu_dse__New_Creditor__r.Name == 'Discover'))
                && newTradeLine.nu_dse__Include_In_The_Program__c == true){
                updateProgram.Discover_Included__c = true;
            }
            if(updateProgram.Discover_Included__c != newTradeLine.nu_dse__Program__r.Discover_Included__c) {
                programsToUpdate.put(updateProgram.Id, updateProgram);
            }
        }
    }

    public void updateTradelineSettlementOrder() {

        for(AggregateResult result: [SELECT count(Id) setteledTradelinesCount, nu_dse__Program__c
                                     FROM nu_dse__Tradeline__c
                                     WHERE nu_dse__Program__c IN :programIdTradelineMap.keyset()
                                        AND (nu_dse__Current_Stage__c = 'Settled - Legal' OR nu_dse__Current_Stage__c = 'Settled - Non Legal'
                                            OR nu_dse__Current_Stage__c = 'Making payments')
                                     GROUP BY nu_dse__Program__c]) {

            Id programId = Id.valueOf(String.valueOf(result.get('nu_dse__Program__c')));
            Integer setteledTradelinesCount = Integer.valueOf(result.get('setteledTradelinesCount'));

            for (nu_dse__TradeLine__c newTradeLine : programIdTradelineMap.get(programId)) {

                setteledTradelinesCount++;
                newTradeLine.Program_Settlement_Order__c = setteledTradelinesCount;
            }
            programIdTradelineMap.remove(programId);
        }

        for(Id programId : programIdTradelineMap.keyset()) {

            Integer setteledTradelinesCount = 1;
            for(nu_dse__TradeLine__c newTradeLine : programIdTradelineMap.get(programId)){

                newTradeLine.Program_Settlement_Order__c = setteledTradelinesCount;
                setteledTradelinesCount++;
            }
        }
    }

    public void aggregateSavingsToProgram() {

        for (AggregateResult result: [SELECT sum(Savings_Months_to_Payoff__c) payOffMonthSum, 
                                        sum(Savings_Payoff_Amount__c) payOffAmountSum, 
                                        sum(Savings_Calculated_Savings__c) savingCalcSum , 
                                        nu_dse__Program__c 
                                        FROM nu_dse__Tradeline__c 
                                        WHERE nu_dse__Program__c IN :savingCalcUpdateProgramIds 
                                        AND nu_dse__Include_In_The_Program__c = true
                                        GROUP BY nu_dse__Program__c]) {
           
            Id programId = Id.valueOf(String.valueOf(result.get('nu_dse__Program__c')));
            nu_dse__Program__c program = new nu_dse__Program__c(Id = programId);                    
            if (programsToUpdate.containsKey(programId) == true) {
                program = programsToUpdate.get(programId);
            } 

            program.Savings_Payoff_Amount_TL__c = Integer.valueOf(result.get('payOffAmountSum'));
            program.Savings_Months_to_Payoff_TL__c = Integer.valueOf(result.get('payOffMonthSum'));
            program.Savings_Calculated_Savings_TL__c = Integer.valueOf(result.get('savingCalcSum'));
            program.Savings_Calculation_Timestamp_TL__c = System.now();
            programsToUpdate.put(programId, program);
        }
    }

    @future(callout=true)
    public static void calculateSavings(Set<Id> tradelineIds) {
        
        List<nu_dse__TradeLine__c> tradelineToUpdateList = new List<nu_dse__TradeLine__c>(); 

        PaymentsCalcService.SavingCalcSettings savingCalcSetting = PaymentsCalcService.getSavingCalcSettings();

        for (nu_dse__TradeLine__c newTradeline : [SELECT Id, Name, nu_dse__Current_Balance__c, nu_dse__Original_Debt__c 
                                                  FROM nu_dse__TradeLine__c WHERE Id IN :tradelineIds]) {
            
            Double debt = 0; 

            if((newTradeline.nu_dse__Current_Balance__c == 0
                || newTradeline.nu_dse__Current_Balance__c == null)
                && newTradeline.nu_dse__Original_Debt__c != null) {

                debt = newTradeline.nu_dse__Original_Debt__c;

            } else if(newTradeline.nu_dse__Current_Balance__c != null) {

                debt = newTradeline.nu_dse__Current_Balance__c;
            }
            
            nu_dse__TradeLine__c tradelineToUpdate = (nu_dse__Tradeline__c)PaymentsCalcService.savingsCalculatorExternalService(
                                                                    savingCalcSetting, debt, 'nu_dse__Tradeline__c');
            tradelineToUpdate.Id = newTradeline.Id;
            tradelineToUpdateList.add(tradelineToUpdate);
        }

        update tradelineToUpdateList;
    }
    
    public void loanAppCalcUpdate(nu_dse__TradeLine__c newTradeline, nu_dse__TradeLine__c oldTradeline) {
        
    	if((oldTradeline.Creditor_Payments_Outstanding__c != newTradeline.Creditor_Payments_Outstanding__c
            || oldTradeline.Fees_Outstanding__c != newTradeline.Fees_Outstanding__c)
        	&& newTradeline.Loan_Application__c != null){
                Id LoanId = newTradeline.Loan_Application__c;
                updateLoanCalcs(LoanId);
            }
    }
     public static void updateLoanCalcs(string LoanApplicationId){
        System.debug('flow working');
        Map<String, Object> params = new Map<String, Object>();
        params.put('LoanApplicationId', LoanApplicationId);
        try {
            Flow.Interview.Update_Loan Update_Loan = new Flow.Interview.Update_Loan(params);
            Update_Loan.start();
            System.debug('after flow');
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }   
}