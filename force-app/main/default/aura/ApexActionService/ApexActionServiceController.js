({
	callServer : function(component, event, helper) {
        const params = event.getParam('arguments');
        
        const action = params.action;
        console.log(params);
        // Pass action parameters if applicable
        if (params.params !== null) {
            action.setParams(params.params);
        }

        action.setCallback(this, function(response) {
            const state = response.getState();
            console.log('state',state);
            if (state === 'SUCCESS') {
                // Call custom success callback if applicable
                if (params.successCallback) {
                    params.successCallback(response.getReturnValue());
                }
            }
            else if (state === 'ERROR') {
                const errors = response.getError();
                console.log('Error->',errors);
                helper.handleErrors(component, params, errors);
                // Call custom error callback if applicable
                if (params.errorCallback) {
                    params.errorCallback(errors);
                }
            }
        });

        // Call server-side action
        $A.enqueueAction(action);
    }
})