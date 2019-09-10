({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.data',[]);
        helper.setColumns(component);
        console.log('recordId',component.get('v.programId'));
        const apexService = component.find("apexService");
		apexService.callServer(
            component.get("c.getSettlementsOutforAuth"), // Action
            {"progId": component.get('v.programId')}, // Action parameters 'a0L22000000Vmzh'
            $A.getCallback(function(response) { // Success callback
                var tradelineList = JSON.parse(response); 
                console.log('tradelineList-->',tradelineList);
                component.set('v.data',tradelineList);
                component.set('v.showSpinner', false);
            }),
            $A.getCallback(function(response) { // Error callback
                component.set('v.showSpinner', false);
                console.log('Error',response);
            })
        );
    },
    handleActive: function (cmp, event, helper) {
        console.log('injecting comp');
        helper.handleActive(cmp, event);
    },
    getNewSettlements: function (cmp, event, helper) {
        console.log('onActive');
        cmp.set('v.showSpinner', true);
        cmp.set('v.data',[]);
        const apexService = cmp.find("apexService");
		apexService.callServer(
            cmp.get("c.getNewSettlementsfromTradeline"), // Action
            {"progId": cmp.get('v.programId')}, // Action parameters 'a0L22000000Vmzh'
            $A.getCallback(function(response) { // Success callback
                var tradelineList = JSON.parse(response); 
                console.log('tradelineList-->',tradelineList);
                cmp.set('v.data',tradelineList);
                helper.setTradelinesColumns(cmp);
                cmp.set('v.showSpinner', false);
            }),
            $A.getCallback(function(response) { // Error callback
                cmp.set('v.showSpinner', false);
                console.log('Error',response);
            })
        );
    }

})