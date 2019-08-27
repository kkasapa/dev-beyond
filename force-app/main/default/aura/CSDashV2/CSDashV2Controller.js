({
	doInit : function(component, event, helper) {
		component.set("v.infoMessage", "CUSTOM MESSAGE CAN BE DISPLAYED HERE ");	
        helper.getExiGridWrapHelper(component, event, helper);	
        helper.getExiTradeLineHelper(component, event, helper);
	}
})