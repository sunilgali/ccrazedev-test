({
	doInit : function(component) {
        //console.debug(component.get("v.productSKU"));
        
        /*var cartId = sessionStorage.getItem("cartId");
        if(!cartId){
            cartId = component.get("v.cartId");
            //sessionStorage.setItem("cartId" , cartId);
        }
        //alert(cartId);*/
        component.set("v.isSpin",true);
        //this.showSpinner();
        
        var cartId = this.getNavigateParameter("cartId");
        
		var action = component.get("c.getCartAndProduct");
        action.setParams({"cartId" : cartId});
        //action.setParams({"productSKU" : productSKU , "cartId" : cartId});
        action.setCallback(this , function(response){
            var state = response.getState();
            if( state === "SUCCESS"){
                var cartAndProduct = response.getReturnValue();
                var product = cartAndProduct['product'];
                component.set("v.product" , product);
                var cart = cartAndProduct['userCart'];
                console.log("sub total "+cart.subTotalAmount);
                console.log("cartId "+cart.cartId);
                
                var productSKU = product.productSKU;
                console.log("productSKU = "+productSKU);
                component.set("v.productSKU" , productSKU);
                
                component.set("v.showAddons" , true);
                
                /*component.set("v.cart" , cart);
                component.set("v.cartId" , cart.cartId);
                component.set("v.totalPrice" , cart.totalAmount);*/
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
            }
            component.set("v.isSpin",false);
            //this.hideSpinner();
        });
        $A.enqueueAction(action);
        
	},
    
    applyCoupon : function(component, event ){
        component.set("v.isSpin",true);
		var action = component.get("c.applyCouponToCart");
        var couponCode = component.find("couponCode").get("v.value");
        action.setParams({"cartId" : component.get("v.cartId"), "couponCode" : couponCode});
        action.setCallback(this , function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var cart = response.getReturnValue();
                component.set("v.cart" , cart);
                component.set("v.cartId" , cart.cartId);
                component.set("v.totalPrice" , cart.totalAmount);
                
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
                this.showToast("Error" , "error" , "sticky" , "Invalid Coupon");
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invalid Coupon."
                });
    			toastEvent.fire();*/
                //alert("Invalid Coupon");
            }
            component.set("v.isSpin",false);
        });
        $A.enqueueAction(action);
    },
    
})