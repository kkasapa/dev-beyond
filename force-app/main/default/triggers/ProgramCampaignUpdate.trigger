trigger ProgramCampaignUpdate on nu_dse__Program__c (before insert,before update) {
    Set<String> setProgramIds = new Set<String>();
    if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
        for(nu_dse__Program__c objProgram : Trigger.new){
            if(Trigger.isInsert){
                if(objProgram.File_Review_Checklist_Start__c || objProgram.File_Review_Checklist_Stop__c){
                    if(objProgram.File_Review_Checklist_Start_Date__c != null){
                       objProgram.Campaign_Disposition__c = 'STARTFREV';
                       objProgram.Campaign_Updated__c = true;
                    }
                    if(objProgram.File_Review_Checklist_Stop_Date__c != null){
                       objProgram.Campaign_Disposition__c = 'STOPFREV';
                       objProgram.Campaign_Updated__c = true;
                    }
                }
            }
            
            if(Trigger.isUpdate){
                nu_dse__Program__c oldObjProgram = Trigger.oldMap.get(objProgram.Id);
                 if(oldObjProgram != null){
                   //File Review Checkilist 
                    if(objProgram.File_Review_Checklist_Start__c || objProgram.File_Review_Checklist_Stop__c){
                        if(objProgram.File_Review_Checklist_Start_Date__c != null && (objProgram.File_Review_Checklist_Start_Date__c != oldObjProgram.File_Review_Checklist_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTFREV';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.File_Review_Checklist_Stop_Date__c != null && (objProgram.File_Review_Checklist_Stop_Date__c != oldObjProgram.File_Review_Checklist_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPFREV';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    //Initial Review Checklist
                    if(objProgram.Initial_Checklist_Start__c || objProgram.Initial_Checklist_Stop__c){
                        if(objProgram.Initial_Checklist_Start_Date__c!= null && (objProgram.Initial_Checklist_Start_Date__c != oldObjProgram.Initial_Checklist_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTIC';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.Initial_Checklist_Stop_Date__c!= null && (objProgram.Initial_Checklist_Stop_Date__c != oldObjProgram.Initial_Checklist_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPIC';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    //NCP
                     if(objProgram.NCP_Start__c || objProgram.NCP_Stop__c){
                        if(objProgram.NCP_Start_Date__c != null && (objProgram.NCP_Start_Date__c != oldObjProgram.NCP_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTNCP';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.NCP_Stop_Date__c != null && (objProgram.NCP_Stop_Date__c != oldObjProgram.NCP_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPNCP';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    //NSF 1
                     if(objProgram.NSF_Start__c || objProgram.NSF_Stop__c){
                        if(objProgram.NSF_Start_Date__c != null && (objProgram.NSF_Start_Date__c != oldObjProgram.NSF_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTNSF1';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.NSF_Stop_Date__c != null && (objProgram.NSF_Stop_Date__c != oldObjProgram.NSF_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPNSF1';
                           objProgram.Campaign_Updated__c = true;
                        }
                    } 
                    
                    //NSF 2
                     if(objProgram.NSF_2_Start__c || objProgram.NSF_2_Stop__c){
                        if(objProgram.NSF_2_Start_Date__c != null && (objProgram.NSF_2_Start_Date__c != oldObjProgram.NSF_2_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTNSF2';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.NSF_2_Stop_Date__c != null && (objProgram.NSF_2_Stop_Date__c != oldObjProgram.NSF_2_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPNSF2';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    
                    //NSF 3
                     if(objProgram.NSF_Final_Start__c || objProgram.NSF_Final_Stop__c){
                        if(objProgram.NSF_Final_Start_Date__c != null && (objProgram.NSF_Final_Start_Date__c != oldObjProgram.NSF_Final_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTNSF3';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.NSF_Final_Stop_Date__c != null && (objProgram.NSF_Final_Stop_Date__c != oldObjProgram.NSF_Final_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPNSF3';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    
                    //NSF In Settlement
                     if(objProgram.NSF_In_Settlement_Start__c || objProgram.NSF_In_Settlement_Stop__c){
                        if(objProgram.NSF_In_Settlement_Start_Date__c != null && (objProgram.NSF_In_Settlement_Start_Date__c != oldObjProgram.NSF_In_Settlement_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTNSF1SETT';
                           objProgram.Campaign_Updated__c = true;
                        }
                        
                        if(objProgram.NSF_In_Settlement_Stop_Date__c != null && (objProgram.NSF_In_Settlement_Stop_Date__c != oldObjProgram.NSF_In_Settlement_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPNSF1SETT';
                           objProgram.Campaign_Updated__c = true;
                        }
                    } 
                    
                    //Offer Letter
                     if(objProgram.Offer_Letter_Start__c || objProgram.Offer_Letter_Stop__c){
                        if(objProgram.Offer_Letter_Start_Date__c != null && (objProgram.Offer_Letter_Start_Date__c != oldObjProgram.Offer_Letter_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTOI';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.Offer_Letter_Stop_Date__c  != null && (objProgram.Offer_Letter_Stop_Date__c    != oldObjProgram.Offer_Letter_Stop_Date__c )){
                           objProgram.Campaign_Disposition__c = 'STOPOI';
                           objProgram.Campaign_Updated__c = true;
                        }
                    }
                    
                    //Program Progress
                     if(objProgram.Program_Progress_Start__c || objProgram.Program_Progress_Stop__c){
                        if(objProgram.Program_Progress_Start_Date__c != null && (objProgram.Program_Progress_Start_Date__c != oldObjProgram.Program_Progress_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTPP';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.Program_Progress_Stop_Date__c != null && (objProgram.Program_Progress_Stop_Date__c != oldObjProgram.Program_Progress_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPPP';
                           objProgram.Campaign_Updated__c = true;
                        }
                    } 
                    
                    //Sett Auth
                     if(objProgram.Sett_Auth_Start__c || objProgram.Sett_Auth_Stop__c){
                        if(objProgram.Sett_Auth_Start_Date__c != null && (objProgram.Sett_Auth_Start_Date__c != oldObjProgram.Sett_Auth_Start_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STARTSA';
                           objProgram.Campaign_Updated__c = true;
                        }
                        if(objProgram.Sett_Auth_Stop_Date__c != null && (objProgram.Sett_Auth_Stop_Date__c != oldObjProgram.Sett_Auth_Stop_Date__c)){
                           objProgram.Campaign_Disposition__c = 'STOPSA';
                           objProgram.Campaign_Updated__c = true;
                        }
                     }
                }
            }
        }
    }
}