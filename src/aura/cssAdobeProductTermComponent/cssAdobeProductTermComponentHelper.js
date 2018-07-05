({
    processTermChanged : function(component , event){
        var termType = event.getSource().get("v.value");
        component.set("v.selectedTerm" , termType);

        var product = component.get("v.product");
        var cart = component.get("v.cart");
        var termId = "";
        
        if(termType){
            product.price.forEach(pModel => {
                if(pModel.subscriptionInstallmentUOM == termType){
                    termId = pModel.priceListID;
                }
            });
        }
        console.log("termId = "+termId); 
        console.log("termType = "+termType);
        if(cart && termId && termType && termId.length > 0 && termType.length > 0){
            this.payloadAction(component , cart , product , termId , termType, event , true);
        }
    },
    
    processQuantityChanged : function(component , event) {
        //var termType = component.find("productTermSelect").get("v.value");
        var termType = component.get("v.selectedTerm");
        var product = component.get("v.product");
        var cart = component.get("v.cart");
        var termId = "";
        
        if(termType){
            product.price.forEach(pModel => {
                if(pModel.subscriptionInstallmentUOM == termType){
                    termId = pModel.priceListID;
                }
            });
        }
        console.log("termId = "+termId); 
        console.log("termType = "+termType);
        if(cart && termId && termType && termId.length > 0 && termType.length > 0){
            this.payloadAction(component , cart , product , termId , termType, event , false);
            //padding-left:8px;width: 150px;
        }
    },
    
    executeAction : function(component , type , payload ){
        console.log("payLoad = "+JSON.stringify(payload));
        
        var action;
        if(type == "AddItem"){
            action = component.get("c.addToCart");
        }
        else if(type == "RemoveItem"){
            action = component.get("c.removeFromCart");
        }
        if(action){
            component.set("v.isSpin",true);
            action.setParams({"jsonStr" : JSON.stringify(payload)});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cart = response.getReturnValue();
                    var cEvent = $A.get("e.c:ssCartEvent");
                    var cart = response.getReturnValue();
                    //component.set("v.cart" , cart);
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
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
                else{
                    console.log("Unknown error");
                }
                component.set("v.isSpin",false);
            });
            $A.enqueueAction(action);
        }
    },
    
    processDynamicKitItem : function(component , event){
        var product = component.get("v.product");
        //var cartId = component.get("v.cartId");
        var cart = component.get("v.cart");
        
        var cName = event.getSource().getLocalId();
        if(cName == "dynamicCheckbox" && !event.getSource().get("v.checked")){
            var dSKU = event.getSource().get("v.value");
            var payload = {
                "cartId" : cart.cartId,
                "productSKU" : dSKU
            }
            this.executeAction(component , "RemoveItem" , payload);
            var cQuantity = component.find("dynamicTierQuantity");
            if(cQuantity){
                [].concat(cQuantity).forEach(sqmp => {
                    if(sqmp.get("v.name") == dSKU){
                    sqmp.set("v.value" , "");
                }
                                             } );   
            }
        }
        else{
            var termType = component.get("v.selectedTerm");//component.find("productTermSelect").get("v.value");
            var termId = "";
            
            if(termType){
                product.price.forEach(pModel => {
                    if(pModel.subscriptionInstallmentUOM == termType){
                    termId = pModel.priceListID;
                }
                                      });
            }
            var cpName = event.getSource().get("v.name");    
            var cpValue = event.getSource().get("v.value");
            if(cart && termId && termType && termId.length > 0 && termType.length > 0){
                this.payloadAction(component , cart , product , termId , termType , event , false);
            }
        }
    },
    
    payloadAction : function(component , cart , product , termId , termType , event , ignoreSource){
        var callAction = false;
    	var payload = {}; 
        payload.cartId = cart.cartId; 
        payload.Sku = product.productSKU; 
        payload.subscriptionTermId = termId; 
        payload.subscriptionTermType = termType; 
        payload.productType = product.productType;
        
        if(product.isBundledProduct){
            //payload.productType = product.productType;
            var simQuantity = component.find("simpQuantity").get("v.value");
            if (simQuantity){
            	payload.quantity = simQuantity;
            }
            else{
                payload.quantity = "1";
            }
            payload.bundleComponent = [];
            console.log("Inside bundle product")
            callAction = this.buildBundle(component , product , payload.bundleComponent , event , ignoreSource);
    	}
        else if(product.isTierPriced){
            var tierVal = component.find("tierSelect").get("v.value");
            var quantity = component.find("quantity").get("v.value");
            payload.quantity = "1";
            //payload.productType = "Tiered";
             if(tierVal && quantity && tierVal.length > 0 && quantity > 0  && cart && cart.cartItems[0]){
                 payload.tier = [];
                 var tierChild = {};
                 tierChild.tierAttribute = tierVal;
				//to get the difference of the quantity first get the current cart quantity and substact from
				//the slected quantity.                
                 /*var cQuantity = this.cartQuantity(cart , product);
                 if(cQuantity && cQuantity > 0){
                 	var diffQuantity = parseInt(quantity) - cartItem.quantity;
                    tierChild.attributeValue = diffQuantity;
                 }
                 else{*/
                 	tierChild.attributeValue = quantity;
                 //}
                 payload.tier.push(tierChild);
                 callAction = true;
                 //console.log("diffQuantity = "+diffQuantity);
             }
        }
        else{
            //payload.productType = product.productType;
            var simQuantity = component.find("simpQuantity").get("v.value");
            //var cQuantity = this.cartQuantity(cart , product);
            if (simQuantity){
                /*if(cQuantity && cQuantity > 0){
                //for simple products always send the difference of the current and previous quantity.
                	var diffQuantity = parseInt(simQuantity) - cQuantity;
                	payload.quantity = diffQuantity;
                }
                else{*/
                    payload.quantity = simQuantity;
                //}
                callAction = true;
            }  
        }
        if(callAction){
            //console.log(JSON.stringify(payload));
        	this.executeAction(component , "AddItem" , payload );
        }
    },
    
    cartQuantity : function(cart , product){
        var cartItems = cart.cartItems;
        var cQuantity;
        if(cartItems){
            cartItems.forEach(cartItem => {
                if(cartItem.Sku == product.productSKU){
                    cQuantity = cartItem.quantity;
                }
            });
        }
        console.log("cQuantity = "+cQuantity);
        return cQuantity;
    },
    
    buildBundle : function(component , product , bundles , event , ignoreSource){
        var callAction = false;
        //console.log("inside buildBundle");
        var cName = event.getSource().get("v.name");
        var prodComponents = product.bundleComponents;
        /*prodComponents.forEach(pComp =>{
            if(!pComp.bundleComponentIsOptional){
            	var bundle = {};
                bundle.childProductType = pComp.productType;		
                bundle.childProductSKU = pComp.productSKU;
                bundle.quantity = "1";
                bundles.push(bundle);
                if(cName == "simpQuantity"){
                   callAction = true; 
                }
            }
        });
        */
        
		var cCheck = component.find("dynamicCheckbox");
        if(cCheck){
            //console.log("insdide buildBundle cCheck = "+cCheck);
            [].concat(cCheck).forEach(scmp => {
                if(scmp.get("v.checked")){
                	console.log("insdide buildBundle checked = "+scmp.get("v.checked"));
                    var cmpName = scmp.get("v.name");
                    var childProduct;
                    prodComponents.forEach(pComp =>{
                        if(pComp.productSKU == cmpName){
                            childProduct = pComp;
                        }
                    });
            		var bundle = {};
        			bundle.childProductType = childProduct.productType;		
        			bundle.childProductSKU = childProduct.productSKU;
        			bundle.quantity = "1";
                    if(childProduct.isTierPriced){
                        //bundle.childProductType = "Tiered";
                        var tierValue = "";
                        var tierQuantity = "";
                        var cSelect = component.find("dynamicTierSelect");
                        if(cSelect){
                            [].concat(cSelect).forEach(ssmp => {
                                if(ssmp.get("v.name") == cmpName){
                                    tierValue = ssmp.get("v.value");
                                }
                            } );   
                        }
                        var cQuantity = component.find("dynamicTierQuantity");
                        if(cQuantity){
                            [].concat(cQuantity).forEach(sqmp => {
                                if(sqmp.get("v.name") == cmpName){
                                    tierQuantity = sqmp.get("v.value");
                                }
                            } );   
                        }
                        if(tierValue && tierValue.length > 0 && tierQuantity && tierQuantity.length >0){
                        	bundle.tier = [];
                            var tierChild = {};
                            tierChild.tierAttribute = tierValue;
                            tierChild.attributeValue = tierQuantity;
                            bundle.tier.push(tierChild);
                            bundles.push(bundle);
                            console.log("tiered cName = "+cName);
                        	console.log("tiered cmpName = "+cmpName);
                            if(ignoreSource){
                                callAction = true;
                            }
                            else{
                                if(cName == cmpName){
                                    callAction = true;
                                }
                            }
                            /*else{
                                callAction = false;
                            }*/
                        }
                    }
                    else{
                        console.log("insdide buildBundle non-tiered = ");
                        //bundle.childProductType = childProduct.productType;
                        bundles.push(bundle);
                        //callAction = true;
                        console.log("cName = "+cName);
                        console.log("cmpName = "+cmpName);
                        if(ignoreSource){
                            callAction = true;
                        }
                        else{
                            if(cName == cmpName){
                                callAction = true;
                            }
                        }
                        
                        /*else{
                            callAction = false;
                        }*/
                    }
                }
            } );   
        }
 		return callAction;
    },
})