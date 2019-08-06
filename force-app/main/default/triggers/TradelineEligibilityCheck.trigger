trigger TradelineEligibilityCheck on nu_dse__Prospect__c (before update) {

    if (Trigger.New[0].nu_dse__Prospect_Status__c == 'Check Eligibility' && Trigger.New[0].ApprovalSubmitted__c == false){
    
      for(nu_dse__Prospect__c p : Trigger.New){
        Boolean excludedUserCheck = [Select Exclude_from_Prospect_Triggers__c From User Where Id = :UserInfo.getUserId()][0].Exclude_from_Prospect_Triggers__c;       

            if(excludedUserCheck == false){
                List<nu_dse__TradeLine__c> tlEntries = [SELECT Id FROM nu_dse__TradeLine__c WHERE nu_dse__Prospect__c = :Trigger.New[0].Id];
                    if(tlEntries.size() > 0){
                        Trigger.New[0].Eligibility_Check_Ran__c = true;
                        Trigger.New[0].Last_Eligibility_Check__c = System.Now();
                        
                        List<AggregateResult> tradelineEnrollmentCheck1 = [select count(id) from nu_dse__TradeLine__c where nu_dse__Prospect__c = :Trigger.New[0].Id AND nu_dse__Include_In_The_Program__c = true];
                        List<AggregateResult> tradelineEnrollmentCheck2 = [select SUM(nu_dse__Original_Debt__c) from nu_dse__TradeLine__c where nu_dse__Prospect__c = :Trigger.New[0].Id AND nu_dse__Include_In_The_Program__c = true];
                        List<AggregateResult> tradelineEnrollmentCheck3 = [select MIN(nu_dse__Original_Debt__c) from nu_dse__TradeLine__c where nu_dse__Prospect__c = :Trigger.New[0].Id AND nu_dse__Include_In_The_Program__c = true];
                        
                        Integer tradelineEnrollmentCheck2Results = ((decimal)tradelineEnrollmentCheck2[0].get('expr0')).intValue();
                        Integer tradelineEnrollmentCheck3Results = ((decimal)tradelineEnrollmentCheck3[0].get('expr0')).intValue();
                        
                        System.Debug('Check1 Value: '+tradelineEnrollmentCheck1[0].get('expr0'));
                        System.Debug('Check2 Value: '+tradelineEnrollmentCheck2Results);
                        System.Debug('Check3 Value: '+tradelineEnrollmentCheck3Results);
                        
                        if(
                            (tradelineEnrollmentCheck1.size() > 0 && tradelineEnrollmentCheck1[0].get('expr0') == 1) || 
                            (tradelineEnrollmentCheck2.size() > 0 && tradelineEnrollmentCheck2Results < 7500) || 
                            (tradelineEnrollmentCheck3.size() > 0 && tradelineEnrollmentCheck3Results < 750)
                          ){
                                    Trigger.New[0].Tradeline_Enrollment_Approval_Required__c = true;
                                    System.Debug('Approval required.');
                        }
                        else{
                            if(Trigger.New[0].nu_dse__Prospect_Status__c == 'Check Eligibility'){
                                Trigger.New[0].nu_dse__Prospect_Status__c = 'Eligible';
                                Trigger.New[0].Tradeline_Enrollment_Approval_Required__c = false;
                            }
                            else{
                                Trigger.New[0].Tradeline_Enrollment_Approval_Required__c = false;
                            }
                        }
                    }
                    else{
                        Trigger.New[0].addError('Please add Tradelines prior to changing the status to check eligibility');
                    }
            }
        }
        
      }
        
}