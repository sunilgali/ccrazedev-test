({
    showHideSpinner : function(component , event) {
        var showValue = event.getParam("show");
        console.log("Spinner "+showValue);
        component.set("v.show" , showValue);
    }
})