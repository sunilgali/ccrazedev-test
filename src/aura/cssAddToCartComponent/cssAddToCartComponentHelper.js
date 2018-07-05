({
	onInit : function(component, event, helper) {
        //retrieve Product SKU, Storefront Name and Locale information passed
        var productSKU = helper.getUrlParameterByName(component, event, "productSKU");
        component.set("v.productSKU", productSKU);
        console.log("cssAddToCartComponentHelper: onInit: Product SKU from URL is " + productSKU);

        var storefront = helper.getUrlParameterByName(component, event, "storefront");
        component.set("v.storefront", storefront);
        console.log("cssAddToCartComponentHelper: onInit: storefront " + storefront);

        /*
        var userLocale = helper.getUrlParameterByName(component, event, "userLocale");
        component.set("v.userLocale", userLocale);
        console.log("cssAddToCartComponentHelper: onInit: userLocale " + userLocale);

        var userCurrency = helper.getUrlParameterByName(component, event, "userCurrency");
        component.set("v.userCurrency", userCurrency);
        console.log("cssAddToCartComponentHelper: onInit: userCurrency " + userCurrency);
        */

        var quantity = helper.getUrlParameterByName(component, event, "quantity");
        if (quantity != null) {
	        component.set("v.quantity", quantity);        
        }
        console.log("cssAddToCartComponentHelper: onInit: quantity " + quantity);
        
        var transactionType = helper.getUrlParameterByName(component, event, "transactionType");
        if (transactionType != null) {
	        component.set("v.transactionType", transactionType);        
        }
        console.log("cssAddToCartComponentHelper: onInit: transactionType " + transactionType);
        
        var userLocale = $A.get("$Locale.langLocale");
        var userCurrency = $A.get("$Locale.currencyCode");

        var isTier = helper.getUrlParameterByName(component, event, "isTier");
        var cartItems = [];
        var cartItem = {"Sku": productSKU, "cartItemQuantity": quantity, "productType": "Product", "subscriptionTermType": "Monthly"};
        if (isTier != null) {
            cartItem = {"Sku": productSKU, "cartItemQuantity": quantity, "productType": "Product", "subscriptionTermType": "Monthly", "tier": [{"tierAttribute": "11 - 25", "attributeValue": "12"}]};
        }

        var isBundle = helper.getUrlParameterByName(component, event, "isBundle");
        var bundleComponent = {};
        if (isBundle != null) {
            bundleComponent = [{"childProductSKU":"MUSMED","childProductType":"Tiered","quantity":1,"tier":[]},
            {"childProductSKU":"ADOLIGHT","childProductType":"Tiered","quantity":1,"tier":[{"tierAttribute": "26 - 100", "attributeValue": "27"}]},
            {"childProductSKU":"ADOSTK","childProductType":"Product","quantity":3}];
            cartItem = {"Sku": productSKU, "cartItemQuantity": quantity, "productType": "Dynamic Kit", "subscriptionTermType": "Monthly"};
        }
        
        cartItems.push(cartItem);
        console.log("cssAddToCartComponentHelper: onInit: calling server function to add %o", cartItems);
		var action = component.get("c.addToCart");
        var _self = this;
        if (isBundle != null) {
	        action.setParams({"storefront": storefront, "userName": "", "userLocale": userLocale, "userCurrency": userCurrency, "cartId": "", "cartItemsJson": JSON.stringify(cartItems), "transactionType": transactionType, "bundleComponentJson": JSON.stringify(bundleComponent)});        
        }
        else {
    	    action.setParams({"storefront": storefront, "userName": "", "userLocale": userLocale, "userCurrency": userCurrency, "cartId": "", "cartItemsJson": JSON.stringify(cartItems), "transactionType": transactionType});                    
        }
           action.setCallback(this , function(response){
            var state = response.getState();
            console.log("callback state " + state);
            if( state === "SUCCESS"){
                var cart = response.getReturnValue();
				console.log("cssAddToCartComponentHelper: onInit: Cart created successfully %o", cart);
                var cartId = cart.cartId;
				console.log("cssAddToCartComponentHelper: onInit:redirecting to  /product-details?cartId=" + cart + "&productSKU=" + productSKU);
                helper.navigateToCommunityPage("/product-detail?cartId="+cartId + "&productSKU=" + productSKU , false);
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
            console.log("Hiding spinner");
            _self.hideSpinner();
        });
        $A.enqueueAction(action);
        
	},
    
})