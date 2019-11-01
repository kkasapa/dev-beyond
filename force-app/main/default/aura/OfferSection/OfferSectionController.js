({
    doInit : function(component, event, helper) {
        helper.loadProgram(component);
    },
   
    
      getMyObjects: function(cmp){
        var action = cmp.get("c.getObjects");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.myObjects", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    toggleSection : function(component, event, helper) {      
        
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    doSelectChange : function(component, event, helper) {
        helper.onSelectChange(component, event, helper);
    },
    
    
})