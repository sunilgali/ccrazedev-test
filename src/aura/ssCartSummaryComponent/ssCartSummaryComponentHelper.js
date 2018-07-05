({
    onSubscriptionItemUpdated : function(component, event , helper){
        console.log("onSubscriptionItemUpdated ... ");
        var subscriptionItemId = event.getParam("subscriptionItemId");
        console.log("got the subscription id from the sub event "+subscriptionItemId);
        component.set("v.subscriptionItemId" , subscriptionItemId);
    },
    
    onPayPalPaymentInfoUpdated : function(component, event ){
        var cart =  event.getParam("userCart");
        component.set("v.payerId" , event.getParam("payerId"));
        component.set("v.paymentId" , event.getParam("paymentId"));
        component.set("v.token" , event.getParam("token"));
        component.set("v.account" , event.getParam("account"));
        component.set("v.fromPaypal" , event.getParam("fromPaypal"));
        
        console.log("onPayPalPaymentInfoUpdated.......cart "+cart);
        component.set("v.paymentInfoComplete" , true);
        this.updateSummary(component , cart);
        
    },
    
    onPaypalEvent : function(component , event){
        console.log("Inside the hnadler")
    },
    
    onNewPaymentInfoUpdated : function(component, event ){
        var cart = component.get("v.cart");
        console.log("onNewPaymentInfoUpdated.......");
        
        var paymentcomplete = event.getParam("paymentcomplete");
        console.log("paymentcomplete = "+paymentcomplete);
        var newPayment = event.getParam("newPayment");
        console.log("the newPayment value is "+newPayment);
        
        component.set("v.paymentInfoComplete" , paymentcomplete);
        component.set("v.paymentInfo" , newPayment);
        
        if(paymentcomplete && newPayment){
            //console.log("cart summary - updating cart "+cart.totalAmount);
            var payload={};
            payload.city = newPayment.city; 
            payload.streetAddress = newPayment.streetAddress; 
            payload.state = newPayment.state; 
            payload.country = newPayment.country; 
            payload.postalCode = newPayment.postalCode;
            
            console.log("calling tax....."+cart.cartId);
            console.log("payload "+JSON.stringify(payload)); 
            var action = component.get("c.applyTax");
            action.setParams({"cartId" : cart.cartId,
                              "payload" : JSON.stringify(payload)});
            action.setCallback(this , function(response){
                cart = response.getReturnValue();
                component.set("v.cart" , cart);
                console.log("got new cart");
            });
            $A.enqueueAction(action);
        }
        
    },
    
    onPaymentInfoUpdated : function(component , event){
        console.log("onPaymentInfoUpdated....");
        var cart = component.get("v.cart");
        console.log("cart = "+cart);
        var paymentInfoComplete = event.getParam("paymentInfoComplete");
        var paymentInfo = event.getParam("paymentInfo");
        console.log("paymentInfo onPaymentInfoUpdated" + paymentInfo);
        component.set("v.paymentInfoComplete" , paymentInfoComplete);
        component.set("v.paymentInfo" , paymentInfo);
        
        //if(paymentInfoComplete && paymentInfo){
        if(paymentInfo && paymentInfo.postalCode && paymentInfo.postalCode.length > 0){
            //console.log("cart summary - updating cart "+cart.totalAmount);
            var payload={};
            payload.city = paymentInfo.city; 
            payload.streetAddress = paymentInfo.streetAddress; 
            payload.state = paymentInfo.state; 
            payload.country = paymentInfo.country; 
            payload.postalCode = paymentInfo.postalCode
                
            var action = component.get("c.applyTax");
            action.setParams({"cartId" : cart.cartId,
                              "payload" : JSON.stringify(payload)});
            action.setCallback(this , function(response){
                cart = response.getReturnValue();
                component.set("v.cart" , cart);
            });
            $A.enqueueAction(action);
        }
    },
    
    updateSummary : function(component , cart){
        var mainProducts = [];
        //console.log("cart.cartItems = "+cart.cartItems);

        if(cart && cart.cartItems){
            var cItems = cart.cartItems;
            cItems.forEach(cartItem => {
                //console.log("cartItem.parentSku = "+cartItem.parentSku);
                //console.log("cartItem.parentbundleSKU = "+cartItem.parentbundleSKU);
                if((!cartItem.relatedProductParentSku || cartItem.relatedProductParentSku == null 
                || cartItem.relatedProductParentSku.length == 0 )
                && (!cartItem.parentSku || cartItem.parentSku == null 
                || cartItem.parentSku.length == 0)){
                	console.log("Found main product ");
               	 	mainProducts.push(cartItem);
            	}
                else{
                    //console.log("inside else ");
                }
            });
                    
                if(mainProducts && mainProducts.length > 0){
                    //console.log("Inside mainProducts ")
                    mainProducts.forEach(mProduct => {
                        var adProducts = [];
                        var bProducts = [];
                        cItems.forEach(cartItem => {
                            if(cartItem.relatedProductParentSku && cartItem.relatedProductParentSku.length > 0
                            && mProduct.Sku == cartItem.relatedProductParentSku){
                                //console.log("found addproduct "+cartItem.Sku);
                                adProducts.push(cartItem);
                            }
                            else{
                                 console.log("cartItem.parentProductBundleSKU = "+cartItem.parentProductBundleSKU);
                                 if(cartItem.parentSku && cartItem.parentSku.length > 0
                                && mProduct.Sku == cartItem.parentSku){
                                    console.log("found bundle component "+cartItem.Sku);
                                    bProducts.push(cartItem);
                                }            
                            }
                		});
                	mProduct.addOnProducts = adProducts;
        			mProduct.bundleComponents = bProducts;
            		});
            	}	
                
            }
 			component.set("v.cart" , cart);
            component.set("v.mainProducts" , mainProducts);
    },
    
    onCartUpdated : function(component , event , cart){
        console.log("onCartUpdated = "+cart.cartId);
        if(cart){
            this.updateSummary(component , cart);
            /*var action = component.get("c.getCart");
            action.setparams({"cartId" : cart.cartId});
            action.setCallback(this , function(response){
                if(response.getState() === SUCCESS){
                    var cart = reposnse.getReturnValue();
                    this.updateSummary(component , cart);                
                 }
            });
            $A.enqueueAction(action);*/
    	}
        
	},
                
    removeItem : function(component , event ){
        
        var selectedItem = event.currentTarget;
        var productSku= selectedItem.dataset.sku;
        var cart = component.get("v.cart");
        console.log("deleting productSku = "+productSku);
        console.log("deleting productSku from cart = "+cart.cartId);
        if(cart && productSku){
            var action = component.get("c.removeItemFromCart");
            var payload = {
                "cartId" : cart.cartId,
                "productSKU" : productSku
            };
            action.setParams({"payload" : JSON.stringify(payload)});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cart = response.getReturnValue();
                    var cEvent = $A.get("e.c:ssCartEvent");
                    cEvent.setParams({"userCart" : cart});
                    cEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
	},
                
    applyCoupon : function(component, event){
        var couponCode = component.find("couponCode").get("v.value");
		console.log("applying coupon..."+couponCode);
        if(couponCode && couponCode.length > 0){
			var action = component.get("c.applyCouponToCart");
        
            action.setParams({"cartId" : component.get("v.cart").cartId, "couponCode" : couponCode});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cart = response.getReturnValue();
                    var cEvent = $A.get("e.c:ssCartEvent");
                    cEvent.setParams({"userCart" : cart});
                    cEvent.fire();
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
                    console.log("Invalid Coupon");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
	startSubscription : function(component , event){
    	var cartId = component.get("v.cart").cartId;
        var payment = component.get("v.paymentInfo");
        var account = component.get("v.account");
        var fromPaypal = component.get("v.fromPaypal");
        console.log("fromPaypal "+fromPaypal);
        console.log("payment = "+JSON.stringify(payment));
        if(fromPaypal == true){
            payment = {};
            var address = account.billingContact.address;
            payment.paymentType = "Paypal";
            payment.paymentId = component.get("v.paymentId");
            payment.payerId = component.get("v.payerId");
            payment.paymentToken = component.get("v.token");
            payment.street = address.streetAddress;
            payment.city = address.city;
            payment.state = address.state;
            payment.country = address.country;
            payment.postalCode = address.postalCode;
        }
		//console.log("payment.paymentId = "+payment.paymentId );
		
        var subscriptionItemId = component.get("v.subscriptionItemId");
        console.log("subscriptionItemId = "+subscriptionItemId);
        var action;
        if(subscriptionItemId){
            console.log("calling convert.......");
            action = component.get("c.convertSubscription");
            action.setParams({"parentSubscriptionId":subscriptionItemId, "cartId" : cartId, "paymentModel" : JSON.stringify(payment)});
        }
        else{
            console.log("calling create.......");
            action = component.get("c.createSubscription");
            action.setParams({"cartId" : cartId, "paymentModel" : JSON.stringify(payment)});
        }
    	 
        component.set("v.showSpinner",true);
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log("created subscription.........");
                var subModel = response.getReturnValue();
                console.log("subscription model = "+subModel.orderId);
                component.set("v.showSpinner",false);
                if(subModel && subModel.orderId && subModel.orderId.length > 0){
                	this.navigateToCommunityPage("/confirmation?cartId="+cartId , false);
                }
                else{
                    this.showToast("Error" , "error" , "sticky" , "Error while creating a Subscription!");
                }
            }
            else{
                this.showToast("Error" , "error" , "sticky" , "Error while creating a Subscription!");
                console.log("Error creating a subcription...");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
})