trigger NotesTrigger on Note (before update) {    
   List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    String MyProflieName = PROFILE[0].Name;
   for (Note n : Trigger.new) {
    if (MyProflieName != 'System Administrator') {
               n.addError('Update on this record is restricted, Please Contact your System Admin!');
     }
   }
   
}