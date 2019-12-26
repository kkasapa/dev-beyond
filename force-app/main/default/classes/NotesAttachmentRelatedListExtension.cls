public class NotesAttachmentRelatedListExtension {
 
    public noteandattachment[] NotesList{get;set;}
     
    public NotesAttachmentRelatedListExtension(ApexPages.standardController std){
        NotesList=new noteandattachment[]{};
         string PgmID=ApexPages.currentPage().getParameters().get('id');
        if(PgmID==NULL){
            system.debug('No Id available');
        }
        else{
            nu_dse__Program__c[] PgmNotes=new nu_dse__Program__c[]{};
            PgmNotes=[Select id,(select isnote,title,lastmodifieddate,createdby.name from NotesAndAttachments)  from nu_dse__Program__c where id =:PgmID];
            for( nu_dse__Program__c p:PgmNotes ){
                for(NoteAndAttachment obj:p.NotesAndAttachments ){
                    NotesList.add(obj);
                }
            }
        }
    }
}