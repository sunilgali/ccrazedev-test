({
	doInit : function(component, event) {
        
        /*var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        var cartId = getUrlParameter("cartId");*/
        var cartId = this.getNavigateParameter("cartId");
        if(cartId){
            var action = component.get("c.getCart");
            action.setParams({"cartId" : cartId});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cart = response.getReturnValue();
                    console.log("transactionType = "+cart.transactionType);
                    var transactionType = cart.transactionType;
                    if(transactionType == "Trail" || transactionType == "Trial" 
                       || transactionType == "Try"){
                        component.set("v.endDateStr" , "July 14, 2018")
                    }
                    if(cart){
                        this.updateSummary(component , cart);
                    }
                }
            });
            $A.enqueueAction(action);
        }
	},
    
    updateSummary : function(component , cart){
        var mainProducts = [];
        console.log("cart.cartItems = "+cart.cartItems);

        if(cart && cart.cartItems){
            var cItems = cart.cartItems;
            cItems.forEach(cartItem => {
                console.log("cartItem.relatedProductParentSku = "+cartItem.relatedProductParentSku);
                
                if((!cartItem.relatedProductParentSku || cartItem.relatedProductParentSku == null 
                || cartItem.relatedProductParentSku.length == 0 )
                && (!cartItem.parentSku || cartItem.parentSku == null 
                || cartItem.parentSku.length == 0)){
                	console.log("Found main product ");
               	 mainProducts.push(cartItem);
            	}
                else{
                    console.log("inside else ");
                }
            });
                    
                if(mainProducts && mainProducts.length > 0){
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
})