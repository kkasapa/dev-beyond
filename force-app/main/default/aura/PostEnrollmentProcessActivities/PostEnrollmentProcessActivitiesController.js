({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.setColumns(component);
        const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.getPostEnrolmntGroupTasks"), // Action
            {}, // Action parameters 
            $A.getCallback(function(response) { // Success callback
                var data = JSON.parse(response); 
                console.log('data-->',data);
                component.set('v.tableData',data);
                component.set('v.showSpinner', false);
            }),
            $A.getCallback(function(response) { // Error callback
                component.set('v.showSpinner', false);
                console.log('Error',response);
            })
        );
    },
})