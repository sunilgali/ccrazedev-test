({
	doInit : function(component, event, helper) {
        var strApexMethod = component.get('v.strApexMethod');
        var strApexMethodParameters = { productId : component.get('v.recordId') };
        //helper.showSpinner(component);
        helper.requestServerCall(component, strApexMethod, strApexMethodParameters);
	},
    
    onRender: function (component, event, helper) {
        var interval = setInterval($A.getCallback(function () {
            var progress = component.get('v.progress');
            if(progress === 100){
                component.set('v.progress', clearInterval(interval));
            } else {
                if(progress < 99){
                    component.set('v.progress',progress + 1);
                }
            }
        }), 200);
    },
    
    handleProgressChange: function (component, event, helper) {
        var progress = component.get('v.progress');
        if(progress === 100){
            var progressBar = component.find("myProgressBar");
            helper.hideComponent(component, progressBar);
            var outputContainer = component.find("outputContainer");
            helper.showComponent(component, outputContainer);
        }
    }
})