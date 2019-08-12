({
    handleErrors : function(cmp, params, errors) {
        const helper = this;
		const toastComp = cmp.find("customToast");
        // Display error if applicable
        if (params.disableErrorNotification === true) {
            return;
        }
        
        // Retrieve and display the error message(s) sent by the server
        let isUnknownError = true;
        if (typeof errors !== 'undefined' && Array.isArray(errors) && errors.length > 0) {
            errors.forEach(function(error) {
                // Check for 'regular' errors
                if (typeof error.message !== 'undefined') {
                    toastComp.set('v.autoClose',false);
                    toastComp.showToastModel(error.message, 'error');
                    //helper.displayError(error.message, params);
                    isUnknownError = false;
                }
                // Check for 'pageError' errors
                const pageErrors = error.pageErrors;
                if (typeof pageErrors !== 'undefined' && Array.isArray(pageErrors) && pageErrors.length > 0) {
                    pageErrors.forEach(function(pageError) {
                        if (typeof pageError.message !== 'undefined') {
                            //helper.displayError(pageError.message, params);
                            toastComp.showToastModel(pageError.message, 'error');
                            isUnknownError = false;
                        }
                    });
                }
            });
        }
        // Make sure that we display at least one error message
        if (isUnknownError) {
            toastComp.showToastModel(error.message, 'error');
            //this.displayError('Unknown error', params);
        }
        // Display raw error stack in console
        console.error(JSON.stringify(errors));
    },

    displayError : function(errorMessage, actionParams) {
        // Display error in console
        console.error('Server Error: ', errorMessage);
        console.error('Action: ', actionParams.action.getName(), ' Params: ', actionParams.params);
        // Fire error toast if available
        const toastEvent = $A.get("e.force:showToast");
        if (typeof toastEvent !== 'undefined') {
            toastEvent.setParams({
                title : 'Server Error',
                message : errorMessage,
                type : 'error',
                mode: 'sticky'
            });
            toastEvent.fire();
        }
    }
})