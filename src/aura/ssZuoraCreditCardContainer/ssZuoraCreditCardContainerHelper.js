({
    showComponent: function (component, myComponent) {
        //console.log('Came in show myComponent');
        $A.util.removeClass(myComponent, "slds-hide");
    },
    
    hideComponent: function (component, myComponent) {
        //console.log('Came in Hide myComponent');
        $A.util.addClass(myComponent, "slds-hide");
    }
})