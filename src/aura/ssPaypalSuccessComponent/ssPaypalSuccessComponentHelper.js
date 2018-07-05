({
	doInit : function(component , helper) {
        
        var url_string = window.location.href;
        var url = new URL(url_string);
        
        component.set('v.payerId',url.searchParams.get("PayerID"));
        component.set('v.paymentId',url.searchParams.get("paymentId"));
        component.set('v.token',url.searchParams.get("token"));
        var cartId = url.searchParams.get("cartId");
        component.set('v.cartId',url.searchParams.get("cartId"));
        var subscriptionItemId = url.searchParams.get("subscriptionItemId");
        
        console.log("the subscriptionItemId = "+subscriptionItemId);
       
        component.set("v.isSpin",true);
        var action = component.get("c.getAccountAndCart");
        action.setParams({"cartId" : cartId});
        
        action.setCallback(this , function(response){
            var state = response.getState();
            if( state === "SUCCESS"){
                var rMap = response.getReturnValue();
                var account = rMap['account'];
                component.set("v.account" , account);
                
                var cart = rMap['cart'];
                console.log("cart = "+cart);
                var sEvent = $A.get("e.c:ssPaypalPaymentEvent");
                console.log("sEvent = "+sEvent);
                sEvent.setParams({"userCart": cart});
                sEvent.setParams({"payerId": component.get("v.payerId")});
                sEvent.setParams({"paymentId": component.get("v.paymentId")});
                sEvent.setParams({"token": component.get("v.token")});
                sEvent.setParams({"account": account});
                sEvent.setParams({"fromPaypal": true});
                sEvent.fire();
                console.log("fired paypal event");
                
                if(subscriptionItemId && subscriptionItemId != null && subscriptionItemId != "null"){
                    console.log("firing ssSubscriptionItemEvent");
                    component.set('v.subscriptionItemId' , subscriptionItemId);
                    var subEvent = $A.get("e.c:ssSubscriptionItemEvent");
                    subEvent.setParams({"subscriptionItemId" : subscriptionItemId});
                    subEvent.fire();
                    console.log("AFTER firing ssSubscriptionItemEvent");
        		}
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isSpin",false);
            
        });
        $A.enqueueAction(action);
	},
    
})