({
	doInit : function(component, event, helper) {
		component.set('v.showSpinner', true);
		helper.setPaymentColumns(component);
		const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.getPageData"), // Action
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
				component.set('v.showSpinner', false);
                //component.set('v.memPreference', response);
            }),
            $A.getCallback(function(response) { // Error callback
				console.log('response->',JSON.parse(response));
				//component.set('v.memPreference', response);
				component.set('v.showSpinner', false);
            })
        );
	},

	updatePayments : function(component, event, helper) {
		const toastComp = component.find("showToast");
		if(Array.isArray(toastComp)){
			toastComp = toastComp[0];
		} 
		//toastComp.closeToast();
		var selectedPaymentMethod;
		let paymentMethodSelect = component.find('paymentMethodSelect');
		if(Array.isArray(paymentMethodSelect)){
			selectedPaymentMethod = paymentMethodSelect[0].get('v.value');
		} else {
			selectedPaymentMethod = paymentMethodSelect.get('v.value');
		}
		console.log('Selected Value',selectedPaymentMethod);
		
		if (!selectedPaymentMethod) {
			toastComp.set('v.autoCloseTime', 2000);
			toastComp.showToastModel('Please select a valid Payment Transaction Method!', 'warning');
		} else {
			component.set('v.showSpinner', true);
			let paymentsList = component.get('v.settlementPayments');
			paymentsList.forEach(payment => {
				if (payment.nu_dse__Transaction_Status__c 
					&& payment.nu_dse__Transaction_Status__c != 'Completed'
					&& payment.nu_dse__Transaction_Status__c != 'Cleared'
					&& payment.nu_dse__Transaction_Status__c != 'Cancelled') {
						payment.nu_dse__Transaction_Method__c = selectedPaymentMethod;
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
					component.set('v.showSpinner', false);
					toastComp.showToastModel('Payment updated successfully!', 'success');
					
				}),
				$A.getCallback(function(response) { // Error callback
					console.log('response->',response);
					//component.set('v.memPreference', response);
					component.set('v.showSpinner', false);
				})
			);
		}
	},
})