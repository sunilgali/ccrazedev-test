({
	requestServerCall : function(component, papexMethod, papexMethodParameters) {
		var action = component.get(papexMethod);
        action.setParams(papexMethodParameters);
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serverResponse = response.getReturnValue();
                console.log("From server: " + serverResponse);
                component.set('v.progress', 100);
                var spinner = component.find("mySpinner");
                this.hideComponent(component, spinner);
                if(serverResponse){
                    component.set('v.displayMessage', 'Product Successfully Configured in Zuora!');
                } else {
                    component.set('v.displayMessage', 'Problem Configuring product in Zuora!');
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
	},
    
    showComponent: function (component, myComponent) {
        //console.log('Came in show myComponent');
        $A.util.removeClass(myComponent, "slds-hide");
    },
    
    hideComponent: function (component, myComponent) {
        //console.log('Came in Hide myComponent');
        $A.util.addClass(myComponent, "slds-hide");
    }
})