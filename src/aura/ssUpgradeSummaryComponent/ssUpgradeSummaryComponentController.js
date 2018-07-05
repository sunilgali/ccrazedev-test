({
	doInit : function(component, event, helper) {
		console.log("inside doInit");
        //helper.doInit(component , event);
	},
     
    handleSubscriptionEvent : function(component , event, helper){
        console.log("inside handleSubscriptionEvent");
        helper.onCartUpdated(component , event);
    },
    
    onUpgradeSubscription : function(component , event, helper){
        console.log("Inside upgradeSubscription");
        helper.onUpgradeSubscription(component , event);
    },
    
})