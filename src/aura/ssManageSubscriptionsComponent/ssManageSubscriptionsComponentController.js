({
	doInit : function(component, event, helper) {
		helper.doInit(component , event);
    },
    
    onClickCancel : function(component, event, helper) {
        helper.cancelSubscription(component, event);
    },
    
    onClickUpgrade : function(component, event, helper) {
        console.log("subId = "+event.getSource().get("v.name"));
        console.log("productId = "+event.getSource().get("v.value"));
        helper.upgradeSubscription(component, event);
    },
    
    onClickConvert : function(component, event, helper) {
        helper.convertSubscription(component, event);
    },
    
    
   
})