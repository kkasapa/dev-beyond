public class TwilioUtil {

     public static Map<String,Document> getVBRecordings(){
       
       
        
        Map<String,Document> recordings = new Map<String,Document>();
        
        for(Document d: [Select Folder.Name,Name from Document where Folder.Name='Recordings']){
            
            recordings.put(d.Name,d);
        }
        
        return recordings;
    }
}