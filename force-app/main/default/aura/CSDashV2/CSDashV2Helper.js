({
	getExiGridWrapHelper : function(component, event, helper) {
		var param 	= 'pgmId';
        var result	= decodeURIComponent((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20')) || null;
    	var pgmId 	= result;
        
        var action = component.get("c.getData");	
        action.setParams({'strPgmId': pgmId}); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
            	component.set("v.fldDetails", response.getReturnValue());         
            }else if (response.getState() === "ERROR") {            	   
            }else{}       
        });
        $A.enqueueAction(action);
	},
    getExiTradeLineHelper : function(component, event, helper) {
		var param 	= 'pgmId';
        var result	= decodeURIComponent((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20')) || null;
    	var pgmId 	= result;
        
        var action = component.get("c.getTradeLineData");	
        action.setParams({'strPgmId': pgmId}); 
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
            	component.set("v.tradeLines", response.getReturnValue());         
            }else if (response.getState() === "ERROR") {            	   
            }else{}       
        });
        $A.enqueueAction(action);
	}
})