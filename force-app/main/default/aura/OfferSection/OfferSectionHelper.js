({
    loadProgram : function(component) {
    var action = component.get("c.getPgm");
	console.log('action is-->>' + action);
    action.setParams({
        pgmId : component.get("v.recordId")
    });

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
    
    
})