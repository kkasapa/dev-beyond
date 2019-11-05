({
    
    getPicklist: function(component, event, helper) {
        var action = component.get("c.getPgm");
        action.setParams({
            pgmId : component.get("v.parameters")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                /*
                var pgmMap = [];
                for(var key in result){
                    pgmMap.push({key: key, value: result[key]});
                }
                */
                component.set("v.pgmMap", result);
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
        
        var action = component.get("c.getPickListValuesIntoList");
        console.log('action igetPaymentMethod' + action);
        
        action.setParams({
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.picklistValues", list);
        })
        $A.enqueueAction(action);
    },
    
    getPayments: function(component, event, helper) {          
        
        var action = component.get("c.getObjects");
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
    /*
    ,
    
    loadProgram : function(component) {
        var action = component.get("c.getPgm");
        console.log('action is-->>' + action);
        action.setParams({
            pgmId : component.get("v.parameters")
        });
        console.log('action is-->>' + action);
        console.log("action is json " + JSON.stringify(action));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.program", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    onSelectChange : function(component, event, helper){
        
        var selectedObject = component.find('selectObject').get('v.value');
        var getFieldSet = component.get('c.getFieldSet');
        
        component.set("v.theForm", []);
        
        getFieldSet.setParams({
            "sObjectName" :  selectedObject 
        });
        getFieldSet.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var fieldsSetList = response.getReturnValue();
                var listOptions = [];
                listOptions.push({
                    label : '--Select One--',
                    value : ''
                });
                for(var i=0; i < fieldsSetList.length; i++){
                    listOptions.push({
                        label : fieldsSetList[i].split('####')[1],
                        value : fieldsSetList[i].split('####')[0]
                    });
                }
                component.set('v.fieldSetList', listOptions);
            }else if(state==='INCOMPLETE'){
                console.log('User is Offline System does not support drafts '
                            + JSON.stringify(response.getError()));
            }else if(state ==='ERROR'){
                
            }else{
                
            }
        });
        getFieldSet.setStorable();
        $A.enqueueAction(getFieldSet);
    }
    
   */
    
    
})