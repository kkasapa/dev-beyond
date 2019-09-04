({
    doInit : function(component, event, helper) {
        
        const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.getPageData"), // Action
            {"offerId": component.get('v.currentOfferId')}, // Action parameters
			$A.getCallback(function(response) { // Success callback
                //component.set('v.memPreference', response);
            }),
            $A.getCallback(function(response) { // Error callback

            })
        );
    }
})