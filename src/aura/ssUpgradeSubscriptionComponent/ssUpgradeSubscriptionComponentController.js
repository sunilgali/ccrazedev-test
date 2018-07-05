({
	doInit : function(component, event, helper) {
		console.log("inside doInit");
        helper.doInit(component , event);
	},
    
    termChanged : function(component , event , helper){
        helper.processTermChanged(component , event);
    },
    
    addonTermChanged : function(component , event , helper){
        helper.processAddonTermChanged(component , event);
    },
        
    tierQuantityChanged : function(component , event , helper){
        helper.processQuantityChanged(component , event);
    },
    
    simpleQuantityChanged : function(component , event , helper){
        helper.processQuantityChanged(component , event);
    },
})