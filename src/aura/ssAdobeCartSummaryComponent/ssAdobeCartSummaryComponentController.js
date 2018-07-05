({
    doInit : function(component, event, helper) {
        /*console.log("Inside do Init");
		var action = component.get("c.getCart");
        action.setParams({"cartId" : "2ee85a1c-f9ae-4333-8681-fb1d3cf0eb1f"});
        action.setCallback(this , function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var cart = response.getReturnValue();
                var cEvent = $A.get("e.c:ssCartEvent");
                cEvent.setParams({"userCart" : cart});
                console.log("Cast Summary userCart "+cart);
                cEvent.fire();
            }
        });
        $A.enqueueAction(action);*/
    },
    
    removeItem : function(component , event , helper){
    	helper.removeItem(component , event);
	},
    
	onCartUpdated : function(component, event, helper) {
        var cart = event.getParam("userCart");
        helper.onCartUpdated(component, event , cart );
	},
                
    onPaymentInfoUpdated : function(component , event , helper){
        helper.onPaymentInfoUpdated(component , event);
    },
    
    onPayPalPaymentInfoUpdated : function(component , event , helper){
        helper.onPayPalPaymentInfoUpdated(component , event);
    },
        
    onNewPaymentInfoUpdated : function(component, event , helper){
        helper.onNewPaymentInfoUpdated(component, event);
    },
    
    onSubscriptionItemUpdated : function(component, event , helper){
        helper.onSubscriptionItemUpdated(component, event);
    },
    
    applyCoupon : function(component, event , helper){
        helper.applyCoupon(component , event);
    },
    
    onTermConditionCheck : function(component , event , helper){
    	var isSubscriptionDisabled = true;
        var cart = component.get("v.cart");
        console.log("onTermConditionCheck transactionType = "+cart.transactionType);
        if(event.getSource().get("v.checked") && (component.get("v.paymentInfoComplete") || cart.transactionType == "Trail")){
            isSubscriptionDisabled = false;
        }
        component.set("v.isSubscriptionDisabled" , isSubscriptionDisabled);
    },
                
    startSubscription : function(component , event , helper){
    	helper.startSubscription(component, event);
    },
     
})