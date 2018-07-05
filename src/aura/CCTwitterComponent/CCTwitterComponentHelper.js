({
    toggleModalWindow : function(component, event) {
        var modalDialog = component.find("modalDialog");
        $A.util.toggleClass(modalDialog, "slds-fade-in-open");
        
        var modalBackdrop = component.find("modalBackdrop");
        $A.util.toggleClass(modalBackdrop, "slds-backdrop--open");
    },
    getComponentConfig: function(component, event) {
        this.callTwitterAPI(component);                                               
    },
    callTwitterAPI:function(component){
        var value=component.get("v.value");
        var action = component.get("c.callTwitterAPI");
        action.setParams({
            "value": 'salesforce'
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.tweets", JSON.parse(response.getReturnValue()));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
})