({        
    doInit: function(component, event, helper) {          
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'id') { 
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }        
        var finalvalue = sParameterName[1];
        component.set("v.parameters", finalvalue);
        
        helper.getTLines(component, event, helper);
        helper.getOfferPicklist(component, event, helper);
        helper.getPaymentMethod(component,event,helper);
        helper.getPgm(component,event,helper);
        helper.getBankDetails(component,event,helper);
        helper.getTradeObj(component,event,helper);
        
        var pageSize = component.get("v.pageSize");
        
        var action = component.get("c.getAllTradelines");
        
        action.setCallback(this, function(response)
                           
                           {
                               
                               var state = response.getState();
                               
                               if (component.isValid() && state === "SUCCESS")
                                   
                               {
                                   
                                   component.set('v.tradeList', response.getReturnValue());
                                   
                                   component.set("v.totalSize", component.get("v.tradeList").length);
                                   
                                   component.set("v.start",0);
                                   
                                   component.set("v.end",pageSize-1);
                                   
                                   var paginationList = [];
                                   
                                   for(var i=0; i< pageSize; i++)
                                       
                                   {
                                       
                                       paginationList.push(response.getReturnValue()[i]);
                                       
                                   }
                                   
                                   component.set('v.paginationList', paginationList);
                                   
                                   //console.log(paginationList);
                                   
                               }
                               
                           });
        
        $A.enqueueAction(action);
        
    },   
    next : function(component, event, helper)
    
    {
        
        var oppList = component.get("v.tradeList");
        
        var end = component.get("v.end");
        
        var start = component.get("v.start");
        
        var pageSize = component.get("v.pageSize");
        
        var paginationList = [];
        
        var counter = 0;
        
        for(var i=end+1; i<end+pageSize+1; i++)
            
        {
            
            if(oppList.length > end)
                
            {
                
                paginationList.push(oppList[i]);
                
                counter ++ ;
                
            }
            
        }
        
        start = start + counter;
        
        end = end + counter;
        
        component.set("v.start",start);
        
        component.set("v.end",end);
        
        component.set('v.paginationList', paginationList);
        
    },
    
    getPays : function(component, event, helper) {
        helper.getPayments(component, event, helper);
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
    
    toggleClientSection : function(component, event, helper) { 
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
    }
})