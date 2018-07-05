({
    doInit : function(component, event, helper) {
        component.set('v.spinnerStatus', 'Show');
        console.log('VfHost: ' + component.get("v.iFrameSrc"));
        component.set('v.lcHost', window.location.hostname);
        var message = { 'submit': false, 'origin': ''};
        component.set("v.message", message);
        window.addEventListener("message", function(event) {
            console.log('Page Type: ' + component.get('v.iframePageType').replace("%20", " ") + 'Type: ' + event.data.type);
            if(component.get('v.iframePageType').replace("%20", " ") === event.data.type){
                console.log(JSON.stringify(event.data));
                // Handle the message
                if(event.data.state == 'LOADED'){
                    //Set vfHost which will be used later to send message
                    component.set('v.vfHost', event.data.vfHost);
                    console.log('Output Loaded: ' + JSON.stringify(event.data));
                    setTimeout(function(){ component.set('v.spinnerStatus', 'Hide'); }, 2000);
                    //$A.util.toggleClass(component.find("buttonContainer"), "slds-hide");
                    //Send data to VF page to draw map
                    helper.sendMessage(component, helper, component.get("v.message"));
                } else if(event.data.state == 'PAYLOAD_OUTPUT'){
                    component.set('v.vfHost', event.data.vfHost);
                    console.log('Output Payload: ' + JSON.stringify(event.data.payload));
                    component.set('v.objPayload', event.data.payload);
                }
            }
        }, false);
    },
    
    updateIframeReolution: function(component){
        if($A.util.isUndefinedOrNull(component.get('v.iframeWidth')) || $A.util.isEmpty(component.get('v.iframeWidth'))){
            component.set('v.iframeWidth', screen.width);
        } 
    },
    
    handleSubmitClick: function(component, event, helper){
        var message = { 'submit': true, 'origin': ''};
        component.set("v.message", message);
        helper.sendMessage(component, helper, component.get("v.message"));
    }
})