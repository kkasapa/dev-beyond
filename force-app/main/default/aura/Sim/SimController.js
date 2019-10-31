({
    getPays: function(component, event, helper){
    var action = component.get("c.getPayments");
    action.setCallback(this, function(response){
    var state =response.getState();
    
    if(state === "SUCCESS"){
        //console.log(state);
    component.set("v.Payments", response.getReturnValue());
        console.log();
    
}
        else if(state ==="ERROR"){
            //console.log(state);
        }
    });
        
        $A.enqueueAction(action);
   
 }

})