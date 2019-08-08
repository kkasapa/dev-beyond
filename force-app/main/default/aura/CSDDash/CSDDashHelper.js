({
	getExiGridWrapHelper : function(component, event, helper) {
		var action = component.get("c.getData");	
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
            	component.set("v.Gridwrap", response.getReturnValue());         
            }else if (response.getState() === "ERROR") {            	   
            }else{}       
        });
        $A.enqueueAction(action);
	}
})