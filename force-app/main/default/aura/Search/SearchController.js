({
	Searchtheword : function(component, event, helper) {
        var SearchWord = component.get('v.SearchWord');
        var action =component.get('c.searchforWords');
        
        action.setParams({SearchWord: SearchWord});
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if(state ==='SUCCESS'){
                var words = response.getReturnValue();
                component.set("v.words", response.getReturnValue());
                //component.set("v.Data", response.getReturnValue());
                console.log(words);
                //console.log(getReturnValue());
            }
        });
		$A.enqueueAction(action);
	}
})