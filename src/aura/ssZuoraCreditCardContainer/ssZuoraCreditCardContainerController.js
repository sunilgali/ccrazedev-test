({
	initScripts : function(component, event, helper) {
		console.log('Scripts Loaded Successfully');
	},
    
    doInit : function(component, event, helper) {
		console.log('Scripts Loaded Successfully');
	},
    
    handleSpinnerToggle : function(component, event, helper) {
		var spinnerStatus = component.get('v.spinnerStatus');
        var spinner = component.find("mySpinner");
        if(spinnerStatus === 'Show'){
            helper.showComponent(component, spinner);
        } else if(spinnerStatus === 'Hide'){
            helper.hideComponent(component, spinner);
        }
	},
})