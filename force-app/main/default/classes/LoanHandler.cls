public class LoanHandler extends TriggerHandler {
    
    private Map<Id, nu_dse__Program__c> newProgramMap;
    private Map<Id, nu_dse__Program__c> oldProgramMap;
    
     public LoanHandler() {
        this.newProgramMap = (Map<Id, nu_dse__Program__c>) Trigger.newMap;
        this.oldProgramMap = (Map<Id, nu_dse__Program__c>) Trigger.oldMap;

	}
    
    public  override void afterupdate(){
        for (nu_dse__Program__c newProgram : (List<nu_dse__Program__c>)Trigger.New) {
		createLoan(newProgram, oldProgramMap.get(newProgram.Id));
        }
    }
    
            // Create New Lender Application Data for Interested Program Enrolled Clients
    // Uses Loan Interest Status = "Interested" to Run
    // A Check to Make Sure flow runs once, so multiple loan are not created   
    public void createLoan(nu_dse__Program__c newProgram, nu_dse__Program__c oldProgram){
        if (newProgram.Loan_Interest_Status__c == 'Interested'){
            system.debug(' I am here  Status Interested');
            if(newProgram.Loan_Interest_Status__c != oldProgram.Loan_Interest_Status__c){
                system.debug(' I am here to check Old Vs New');
                
                if(!newProgram.Flow_Initiated__c){
                    System.debug('loan if statement');
                    futureFlowCall(newProgram.Id);
                }
            }
        }
    }
    //@future(callout=true)
    public static void futureFlowCall(string ProgramId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('ProgramId', ProgramId);
        try {
            Flow.Interview.Create_Loan Create_Loan = new Flow.Interview.Create_Loan(params);
            Create_Loan.start();
        } catch (Exception e){
            system.debug('Exception caught: ' + e.getMessage());
        }
    }
    
}