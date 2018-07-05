({
	doInit : function(component) {
        console.log("related component = productSKU "+component.get("v.productSKU"));
		var action = component.get("c.getRelatedProducts");
        action.setParams({
            "productSKU" : component.get("v.productSKU"),
            "relationType" : component.get("v.relationType")
        });
        action.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var relatedProducts = response.getReturnValue();
                component.set("v.relatedProducts" , relatedProducts);
            }
            else{
                console.log("Error getting related products");
            }
        });
        $A.enqueueAction(action);
	},
    
    processAddonProducts : function(component , event){
        //var cartId = component.get("v.cartId");
        var cValue = event.getSource().get("v.name");
        console.log("cValue = "+cValue);
        var cart = component.get("v.cart");
        var auraId = event.getSource().getLocalId();
        var addonProduct;
        var relatedProducts = component.get("v.relatedProducts");
        relatedProducts.forEach(rProduct => {
            if(rProduct.productSKU == cValue){
            	addonProduct = rProduct;
        	}
        });
        if(addonProduct){
            var termId = "";
            var termSelect = component.find("addOnTermPlanSelect");
            var termType;
            if(auraId == "addOnTermPlanSelect"){
                termType = event.getSource().get("v.value");
            }
            /*
            [].concat(termSelect).forEach(scmp =>{
                if(scmp.get("v.name") == cValue){
                	console.log("checked = "+scmp.get("v.checked"));
                	console.log("clicked = "+scmp.get("v.clicked"));
                	termType = scmp.get("v.value");
            	}
            })*/
            if(termType){
                addonProduct.price.forEach(pModel => {
                    if(pModel.subscriptionInstallmentUOM == termType){
                    	termId = pModel.priceListID;
	                }
                });
            }
            if(auraId == "addOnCheckBox" && !event.getSource().get("v.checked")){
                if(!event.getSource().get("v.checked")){
                    var payload = {
                        "cartId" : cart.cartId,
                        "productSKU" : cValue
                    }
                    this.executeAction(component , "RemoveItem" , payload);
                }
            }
            else{
                console.log("term id = "+termId+" termType = "+termType);
                if(cart && termId && termType && termId.length > 0 && termType.length > 0){
                	this.payloadAction(component , cart , addonProduct , termId , termType , event);
                }
            }
       }
    },
 
 	payloadAction : function(component , cart , product , termId , termType , event){
        var callAction = false;
    	var payload = {}; 
        payload.cartId = cart.cartId; 
        payload.Sku = product.productSKU; 
        payload.subscriptionTermId = termId; 
        payload.subscriptionTermType = termType; 
        payload.productType = product.productType;
        payload.relatedProductParentSku = component.get("v.productSKU");
        payload.relatedProductType = component.get("v.relationType");
        var cName = event.getSource().get("v.name");
        var isChecked = false;
        var cCheck = component.find("addOnCheckBox");
        if(cCheck){
            [].concat(cCheck).forEach(scmp => {
                if(scmp.get("v.name") == cName && scmp.get("v.checked")){
                    isChecked = true;
                }
            } );   
        }
        if(product.isTierPriced){
            var tierVal = component.find("addOnTierSelect").get("v.value");
            var quantity = component.find("addOnTierSelect").get("v.value");
            payload.quantity = "1";
            
            var addonTierVal;
            var addonTiers = component.find("addOnTierSelect");
            [].concat(addonTiers).forEach(ssmp => {
                if(ssmp.get("v.name") == cName){
                	addonTierVal = ssmp.get("v.value");
            	}
            });
            
            var addonQty;
            var addonQtyTxt = component.find("addonQuantity");
            [].concat(addonQtyTxt).forEach(sqmp => {
                if(sqmp.get("v.name") == cName){
                	addonQty = sqmp.get("v.value");
            	}
            });
            
            console.log("addonTierVal = "+addonTierVal  +" addonQty = "+addonQty + " isChecked = "+isChecked);
            if(addonTierVal && addonTierVal.length > 0 && addonQty ){
                payload.tier = [];
                var tierChild = {};
                tierChild.tierAttribute = tierVal
                 
                /*var cartItems = cart.cartItems;
                var cQuantity;
                if(cartItems){
                    [].concat(cartItems).forEach(cartItem => {
                        if(cartItem.Sku == cName && (cartItem.parentSku || cartItem.parentSku == "")){
                            cQuantity = cartItem.quantity;
                        }
                    });
                }
                if(cQuantity && cQuantity > 0){
                    var diffQuantity = parseInt(simQuantity) - cartItem.quantity;
                    tierChild.attributeValue = diffQuantity;
                }
				else{*/
                 		tierChild.attributeValue = addonQty;
               // }
                payload.tier.push(tierChild);
                callAction = true;
            }
             /*if(tierVal && quantity && tierVal.length > 0 && quantity > 0  && cart && cart.cartItems[0]){
                 payload.tier = [];
                 var tierChild = {};
                 tierChild.tierAttribute = tierVal;
                 var cartItem = cart.cartItems[0];
                 var diffQuantity = parseInt(quantity) - cartItem.quantity;
                 //tierChild.attributeValue = quantity;
                 tierChild.attributeValue = diffQuantity;
                 payload.tier.push(tierChild);
                 callAction = true;
                 console.log("diffQuantity = "+diffQuantity);
             }*/
        }
        else if(!product.isBundledProduct){
            var addonVal;
            var addonQty;
            var addonQtyTxt = component.find("addonQuantity");
            if(addonQtyTxt){
                [].concat(addonQtyTxt).forEach(sqmp => {
                    if(sqmp.get("v.name") == cName){
                        addonQty = sqmp.get("v.value");
                    }
                });
            }
            else{
                addonQty = 1;
            }
            console.log("addonQty = "+addonQty + " isChecked = "+isChecked);
            
            if(addonQty && isChecked){
                var cartItems = cart.cartItems;
                /*var cQuantity;
                if(cartItems){
                    cartItems.forEach(cartItem => {
                        if(cartItem.Sku == cName && (cartItem.parentSku || cartItem.parentSku == "")){
                            cQuantity = cartItem.quantity;
                        }
                    });
                }
                if(cQuantity && cQuantity > 0){
                    var diffQuantity = parseInt(simQuantity) - cartItem.quantity;
                	payload.quantity = diffQuantity;
                }
                else{*/
                		payload.quantity = addonQty;
                //}
                callAction = true;
            }
            /*var simQuantity = component.find("simpQuantity").get("v.value");
            if (simQuantity && cart && cart.cartItems[0]){
                var cartItem = cart.cartItems[0];
                //for simple products always send the difference of the current and previous quantity.
                var diffQuantity = parseInt(simQuantity) - cartItem.quantity;
                payload.quantity = diffQuantity;
                callAction = true;
            } */ 
        }
        if(callAction){
        	this.executeAction(component , "AddItem" , payload );
        }
    },
 	
    executeAction : function(component , type , payload ){
        console.log("payLoad = "+JSON.stringify(payload));
        var action;
        if(type == 'AddItem'){
            action = component.get("c.addToCart");
        }
        else if(type == 'RemoveItem'){
            action = component.get("c.removeFromCart");
        }
        if(action){
            component.set("v.isSpin",true);
            action.setParams({"jsonStr" : JSON.stringify(payload)});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cart = response.getReturnValue();
                    console.debug("cart.totalAmount = "+cart.totalAmount);
                    var cEvent = $A.get("e.c:ssCartEvent");
                    cEvent.setParams({"userCart" : response.getReturnValue()});
                    cEvent.fire();
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
                else{
                    console.log("Unknown error");
                }
            });
            component.set("v.isSpin",false);
            $A.enqueueAction(action);
        }
    },
})