public class ProspectOpenEventTrigger{ 
    public static void checkOpenEvents(Event[] evnts) {
            for (Event e :evnts){
                List<nu_dse__Prospect__c> p = [SELECT id, InQueue__c, Remove_from_Five9_Campaign__c, Remove_From_Pardot_Campaign__c, OwnerId FROM nu_dse__Prospect__c WHERE Id = :e.WhatId LIMIT 1];
                if(p.size() > 0 && p[0].Remove_From_Five9_Campaign__c == false){
                    p[0].Remove_from_Five9_Campaign__c =  true;
                        if(p[0].InQueue__c == false){
                            p[0].OwnerId = UserInfo.getUserId();
                        }
                }
                if(p.size() > 0 && p[0].Remove_From_Pardot_Campaign__c == false){
                    p[0].Remove_From_Pardot_Campaign__c =  true;
                        if(p[0].InQueue__c == false){
                            p[0].OwnerId = UserInfo.getUserId();
                        }
                }
                update p;
            }
    }
}