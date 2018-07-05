({
    // Send message to VF page with details sent from parent. 
    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = component.get('v.lcHost');
        var vfWindow = component.find("vfFrameContainer").getElement().contentWindow;
        // Send details to Visual force page
        vfWindow.postMessage(message, component.get("v.vfHost"));
    },
})