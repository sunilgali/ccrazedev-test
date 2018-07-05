({
    showHideSpinner : function(component , event) {
        var showValue = event.getParam("show");
        console.log("Spinner "+showValue);
        component.set("v.show" , showValue);
        /*if(showValue) {
            var spinner = component.find("ssSpinner");
        	$A.util.removeClass(spinner, "slds-hide");
        } else {
            console.log('showValue'+showValue);
            var spinner = component.find("ssSpinner");
        	$A.util.addClass(spinner, "slds-hide");
        }*/
    }

})