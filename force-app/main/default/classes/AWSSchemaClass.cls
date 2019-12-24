/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* This class contains schema structures to be used to return API results. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shravan 
* @modifiedBy     
* @maintainedBy   Shravan
* @version        1.0
* @created        2019-12-19
* @modified       2019-12-19
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class AWSSchemaClass {
    public class SplitByTitleSingle{
        public String title{get;set;}
        public String bucket{get;set;}
        public String sourceFileName{get;set;}
        public String outputFileName{get;set;}
    }
    
    public class SplitByPageSingle{
        public Decimal page{get;set;}
        public String bucket{get;set;}
        public String sourceFileName{get;set;}
        public String outputFileName{get;set;}
        public Decimal pages{get;set;}             
    }
    
    public class ResponseClass{
        public String outputFileName;
        public String outputFileUrl;
    }
    
    public class awsWrapper{
        public List<splitNodesWrap> splitNodes;       
        public String bucket{get;set;}
        public String sourceFileName{get;set;}        
    }
    
    public class splitNodesWrap{
        public String title{get;set;}        
        public String outputFileName{get;set;} 
        
        public splitNodesWrap(){
            title = '';          
            outputFileName='';            
        } 
        public splitNodesWrap(String t, String o){
            title = t;          
            outputFileName=o;            
        }  

    } 
}