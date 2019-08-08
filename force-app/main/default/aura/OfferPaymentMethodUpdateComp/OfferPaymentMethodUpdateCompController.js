({
	doInit : function(component, event, helper) {
		
		const apexService = component.find("apexService");

		apexService.callServer(
            component.get("c.getAncillaryFees"), // Action
            {"offerId": component.get('v.currentOfferId')}, // Action parameters
			$A.getCallback(function(response) { // Success callback
				let serverResponse = JSON.parse(response);

				component.set('v.ancillaryFees', serverResponse.ancillaryFeesList);
				component.set('v.settlementPayments', serverResponse.settlementPayments);
				console.log('response->',JSON.parse(response));
				console.log(JSON.stringify(response));
                //component.set('v.memPreference', response);
            }),
            $A.getCallback(function(response) { // Success callback
				console.log('response->',JSON.parse(response));
                //component.set('v.memPreference', response);
            })
        );
	},

	updatePayments : function(component, event, helper) {
		console.log('Selected Value',event.getParam("v.value"));
	}
})