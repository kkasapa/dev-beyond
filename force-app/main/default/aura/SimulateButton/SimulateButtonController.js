({
    getMyObjects: function(cmp){
        var action = cmp.get("c.getObjects");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.myObjects", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})