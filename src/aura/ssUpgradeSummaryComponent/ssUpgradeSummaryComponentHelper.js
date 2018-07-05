({
    
    onCartUpdated : function(component , event){
        var previousSubscription = event.getParam("subscription");
        var userCart = event.getParam("userCart");
        if(userCart){
            //this.updateSummary(component , userCart);
            component.set("v.previousSubscription" , previousSubscription);
            this.getTaxAmount(component , userCart);
        	//component.set("v.userCart" , userCart);
    	}
        
	},
    
	updateSummary : function(component , cart){
        var newSubscription = {};
        if(cart && cart.cartItems && cart.cartItems.length >0){
            console.log("cart.cartItems = "+cart.cartItems.length);
            component.set("v.isSubscriptionDisabled" , false);
            var sChildProducts = [];
            var cItems = cart.cartItems;
            cItems.forEach(cartItem => {
                console.log("cartItem.relatedProductParentSku = "+cartItem.relatedProductParentSku);
                if((!cartItem.relatedProductParentSku || cartItem.relatedProductParentSku == null 
                	|| cartItem.relatedProductParentSku.length == 0 )){
               	 	newSubscription = cartItem;
            	}
                else{
                    sChildProducts.push(cartItem);
                }
            });
                    
            if(newSubscription && sChildProducts.length > 0){
                var adProducts = [];
                cItems.forEach(cartItem => {
                	if(cartItem.relatedProductParentSku && cartItem.relatedProductParentSku.length > 0
                    && newSubscription.Sku == cartItem.relatedProductParentSku){
                    	adProducts.push(cartItem);
                	}
             
           		 });
				if(adProducts && adProducts.length > 0){
                    newSubscription.addOnProducts = adProducts;
                }
            }	
            component.set("v.userCart" , cart);
            component.set("v.isSubscriptionDisabled" , false);
        }
        else{
            component.set("v.userCart" , cart);
            component.set("v.isSubscriptionDisabled" , true);
        }
        component.set("v.newSubscription" , newSubscription);
		
    },
        
    getTaxAmount : function(component , cart){
        var payload = {};
         if(cart && cart.cartItems && cart.cartItems.length >0){
            if(component.get("v.previousSubscription").contact && component.get("v.previousSubscription").contact.address){
                var addr = component.get("v.previousSubscription").contact.address;
                payload.city = addr.city; 
                payload.streetAddress = addr.streetAddress; 
                payload.state = addr.state; 
                payload.country = addr.country; 
                payload.postalCode = addr.postalCode;
                console.log("address payload = "+JSON.stringify(payload));
                var action = component.get("c.getTaxAmount");
                action.setParams({"cartId" : cart.cartId, "payload" : JSON.stringify(payload)});
                action.setCallback(this , function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var newCart = response.getReturnValue();
                        //component.set("v.userCart" , cart);
                        console.log("Updating new cart");
                        this.updateSummary(component , newCart);
                    }
                    else{
                        console.log("Error getting the subscription ");
                    }
                });
                $A.enqueueAction(action);
            }
             else{
                 this.updateSummary(component , cart);
             }
        }
        
    },
      
    onUpgradeSubscription : function(component , event){
        component.set("v.isSubscriptionDisabled" , true);
    	var cart = component.get("v.userCart");
        var previousSubscription = component.get("v.previousSubscription").sortedSubscription;
        console.log("previousSubscription.subscriptionItemId = "+previousSubscription.subscriptionItemId);
        console.log("cart.cartId  = "+ cart.cartId);
    	var action = component.get("c.upgradeSubscription");
        action.setParams({"cartId" : cart.cartId, "subscriptionItemId" : previousSubscription.subscriptionItemId});
        component.set("v.isSpinner" , true);
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var subModel = response.getReturnValue();
                console.log("subscription model = "+subModel.orderId);
                if(subModel && subModel.orderId && subModel.orderId.length > 0){
                	this.navigateToCommunityPage("/upgrade-confirmation?previousSubscriptionId="+previousSubscription.subscriptionItemId+"&upgradeSubscriptionId="+subModel.orderId , false);
            	}
                else{
                    this.showToast("Error" , "error" , "sticky" , "Error upgrading the subscription.");
                }
            }
            else{
                console.log("Error creating a subcription...");
            }
            component.set("v.isSpinner" , false);
        });
        $A.enqueueAction(action);
        
    },
        
})