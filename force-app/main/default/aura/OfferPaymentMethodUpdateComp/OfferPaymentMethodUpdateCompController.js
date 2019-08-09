({
	doInit : function(component, event, helper) {
		helper.setPaymentColumns(component);
		const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.getAncillaryFees"), // Action
            {"offerId": component.get('v.currentOfferId')}, // Action parameters
			$A.getCallback(function(response) { // Success callback
				let serverResponse = JSON.parse(response);
				if (serverResponse.ancillaryFeesList) {
					component.set('v.ancillaryFees', serverResponse.ancillaryFeesList);
				}
				if (serverResponse.settlementPayments) {
					component.set('v.settlementPayments', serverResponse.settlementPayments);
				}
				console.log('response->',serverResponse);
				console.log('stringResponse',JSON.stringify(response));
                //component.set('v.memPreference', response);
            }),
            $A.getCallback(function(response) { // Error callback
				console.log('response->',JSON.parse(response));
                //component.set('v.memPreference', response);
            })
        );
	},

	updatePayments : function(component, event, helper) {
		var selectedPaymentMethod;
		let paymentMethodSelect = component.find('paymentMethodSelect');
		if(Array.isArray(paymentMethodSelect)){
			selectedPaymentMethod = paymentMethodSelect[0].get('v.value');
		} else {
			selectedPaymentMethod = paymentMethodSelect.get('v.value');
		}
		console.log('Selected Value',selectedPaymentMethod);

		let paymentsList = component.get('v.settlementPayments');
		paymentsList.forEach(element => {
			if (element.nu_dse__Transaction_Status__c 
				&& element.nu_dse__Transaction_Status__c != 'Completed'
				&& element.nu_dse__Transaction_Status__c != 'Cleared'
				&& element.nu_dse__Transaction_Status__c != 'Cancelled') {
					element.nu_dse__Transaction_Method__c = selectedPaymentMethod;
			}
		});
		console.log('updatedPayments',paymentsList);
		const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.updatePaymentTransactionMethod"), // Action
            {"paymentListStr": JSON.stringify(paymentsList)}, // Action parameters
			$A.getCallback(function(response) { // Success callback
				let serverResponse = JSON.parse(response);
				console.log('response->',serverResponse);
				console.log('stringResponse',JSON.stringify(response));
				component.set('v.settlementPayments', paymentsList);
                //component.set('v.memPreference', response);
            }),
            $A.getCallback(function(response) { // Error callback
				console.log('response->',JSON.parse(response));
                //component.set('v.memPreference', response);
            })
        );
	}
})