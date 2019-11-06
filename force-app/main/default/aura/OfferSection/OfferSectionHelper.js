({  
    getTLines: function(component, event, helper) {
        var action = component.get("c.getTradelines");
        
        action.setParams({
            pgmId : component.get("v.parameters")          
        });        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var tList = [];
                for(var key in result){
                    tList.push({key: key, value: result[key]});
                }
                component.set("v.tradelinesList", tList);
            }
        });
        $A.enqueueAction(action);
    },
    getOfferPicklist: function(component, event, helper) {
        var action = component.get("c.getOffers");
        action.setParams({
            pgmId : component.get("v.parameters")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var ofMap = [];
                for(var key in result){
                    ofMap.push({key: key, value: result[key]});
                }
                component.set("v.ofMap", ofMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPaymentMethod: function(component, event, helper) {        
        var action = component.get("c.getPaymentMethod");
        console.log('action igetPaymentMethod' + action);
        
        action.setParams({
            objectName : component.get("v.sObjectName"),
            field_apiname : component.get("v.fieldName")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var payList = response.getReturnValue();              
                
                component.set("v.picklistValues", payList);
            }
        })
        $A.enqueueAction(action);
    },
    
    getPayments: function(component, event, helper) {
        var action = component.get("c.getPaym");
        action.setParams({
            pgmId : component.get("v.parameters")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.myObjects", response.getReturnValue());
                component.set("v.boolean", true);
            }
        });
        $A.enqueueAction(action);
    }
})