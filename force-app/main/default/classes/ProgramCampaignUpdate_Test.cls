@isTest
public class ProgramCampaignUpdate_Test {
    
    @isTest static void ProgramCamp() {
    
        nu_dse__Program__c  prog = new nu_dse__Program__c ();
        prog.Prospect_Name__c ='DailyProgramReport';
        prog.Campaign_Updated__c = true; 
        prog.Campaign_Disposition__c =  'NSF1Start';
        prog.File_Review_Checklist_Start__c = true;
        prog.File_Review_Checklist_Start_Date__c = system.now();
        prog.File_Review_Checklist_Stop_Date__c = system.now();
        prog.File_Review_Checklist_Start__c = true;
        prog.File_Review_Checklist_Start_Date__c  = system.now();
        prog.File_Review_Checklist_Stop_Date__c = system.now();
        prog.Initial_Checklist_Start__c = true;
        prog.Initial_Checklist_Start_Date__c = system.now();
        prog.Initial_Checklist_Stop_Date__c = system.now();
        prog.NCP_Start__c = true;
        prog.NCP_Start_Date__c  = system.now();
        prog.NCP_Stop_Date__c  = system.now();
        prog.NSF_Start__c  =  true;
        prog.NSF_Start_Date__c =  system.now();
        prog.NSF_Stop_Date__c  = system.now();
        prog.NSF_2_Start__c  = true;
        prog.NSF_2_Start_Date__c  = system.now();
        prog.NSF_2_Stop_Date__c  = system.now();
        prog.NSF_Final_Start__c  = true;
        prog.NSF_Final_Start_Date__c  = system.now();
        prog.NSF_Final_Stop_Date__c  = system.now();
        prog.NSF_In_Settlement_Start__c  = true;
        prog.NSF_In_Settlement_Start_Date__c  = system.now();
        prog.NSF_In_Settlement_Stop_Date__c  = system.now();
        prog.Offer_Letter_Start__c = true;
        prog.Offer_Letter_Start_Date__c  = system.now();
        prog.Offer_Letter_Stop_Date__c  =system.now();
        prog.Program_Progress_Start__c = true;
        prog.Program_Progress_Start_Date__c  = system.now();
        prog.Program_Progress_Stop_Date__c  = system.now();
        prog.Sett_Auth_Start__c  = true;
        prog.Sett_Auth_Start_Date__c  = system.now();
        prog.Sett_Auth_Stop_Date__c  =system.now();
        insert prog;
        
        list<nu_dse__Program__c> proglist = [select id,name from nu_dse__Program__c where Prospect_Name__c = 'DailyProgramReport' limit 1];
        proglist[0].Campaign_Updated__c = true; 
        proglist[0].Campaign_Disposition__c =  'NSF1Start';
        proglist[0].File_Review_Checklist_Start__c = true;
        proglist[0].File_Review_Checklist_Start_Date__c = system.now().adddays(1);
        proglist[0].File_Review_Checklist_Stop_Date__c = system.now().adddays(1);
        proglist[0].File_Review_Checklist_Start__c = true;
        proglist[0].File_Review_Checklist_Start_Date__c  = system.now().adddays(1);
        proglist[0].File_Review_Checklist_Stop_Date__c = system.now().adddays(1);
        proglist[0].Initial_Checklist_Start__c = true;
        proglist[0].Initial_Checklist_Start_Date__c = system.now().adddays(1);
        proglist[0].Initial_Checklist_Stop_Date__c = system.now().adddays(1);
        proglist[0].NCP_Start__c = true;
        proglist[0].NCP_Start_Date__c  = system.now().adddays(1);
        proglist[0].NCP_Stop_Date__c  = system.now().adddays(1);
        proglist[0].NSF_Start__c  =  true;
        proglist[0].NSF_Start_Date__c =  system.now().adddays(1);
        proglist[0].NSF_Stop_Date__c  = system.now().adddays(1);
        proglist[0].NSF_2_Start__c  = true;
        proglist[0].NSF_2_Start_Date__c  = system.now().adddays(1);
        proglist[0].NSF_2_Stop_Date__c  = system.now().adddays(1);
        proglist[0].NSF_Final_Start__c  = true;
        proglist[0].NSF_Final_Start_Date__c  = system.now().adddays(1);
        proglist[0].NSF_Final_Stop_Date__c  = system.now().adddays(1);
        proglist[0].NSF_In_Settlement_Start__c  = true;
        proglist[0].NSF_In_Settlement_Start_Date__c  = system.now().adddays(1);
        proglist[0].NSF_In_Settlement_Stop_Date__c  = system.now().adddays(1);
        proglist[0].Offer_Letter_Start__c = true;
        proglist[0].Offer_Letter_Start_Date__c  = system.now().adddays(1);
        proglist[0].Offer_Letter_Stop_Date__c  =system.now().adddays(1);
        proglist[0].Program_Progress_Start__c = true;
        proglist[0].Program_Progress_Start_Date__c  = system.now().adddays(1);
        proglist[0].Program_Progress_Stop_Date__c  = system.now().adddays(1);
        proglist[0].Sett_Auth_Start__c  = true;
        proglist[0].Sett_Auth_Start_Date__c  = system.now().adddays(1);
        proglist[0].Sett_Auth_Stop_Date__c  =system.now().adddays(1);
        Update proglist[0];

        attachment att = new attachment();
        att.name = 'programs.csv';
        att.body = blob.valueof('testbody');
        att.parentid = prog.id;
        insert att;
        
        
         
    
    }
    
}