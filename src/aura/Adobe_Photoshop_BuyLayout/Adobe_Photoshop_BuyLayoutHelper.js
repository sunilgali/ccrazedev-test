({
	   toggleModalWindow : function(component, event) {
        var modalDialog = component.find("modalDialog");
        $A.util.toggleClass(modalDialog, "slds-fade-in-open");
        
        var modalBackdrop = component.find("modalBackdrop");
        $A.util.toggleClass(modalBackdrop, "slds-backdrop--open");   
    },
})