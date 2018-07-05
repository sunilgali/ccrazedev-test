({
	doInit : function(component, event) {
        
        var subItemId = this.getNavigateParameter("subscriptionItemId");
        console.log("subItemId = "+subItemId);
        //var subId = "a1l1N00000285tyQAA";//a1l1N000001pUveQAE";
		var action = component.get("c.getSubscription");
        component.set("v.isSpin" , true);
        action.setParams({"subscriptionId" : subItemId});
        action.setCallback(this , function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var map = response.getReturnValue();
                if(map){
                    var subscription = map['subscription'];
                    var cart = map['cart'];
                    console.log("cartId = "+cart.cartId);
                    component.set("v.cart" , cart);
                   	this.processSubscription(component , subscription);
                    component.set("v.isSpin" , false);
                }
            }
            else{
                console.log("Error getting the subscription ");
            }
            component.set("v.isSpin" , false);
        });
        $A.enqueueAction(action);
	},
    
    processSubscription : function(component , subscription){
        var mainProduct = {};
        var subTotal = 0;
        if(subscription){
                if(subscription.subscribedProducts){
                	var subProducts = subscription.subscribedProducts;
                	var sChildProducts = [];
                	subProducts.forEach(subProduct =>{
                        //subTotal += subProduct.productPrice;
                        if( !subProduct.relatedProductParentSku || subProduct.relatedProductParentSku == null 
                				|| subProduct.relatedProductParentSku.length == 0){
                        	mainProduct = subProduct;
                        }
                        else{
                            sChildProducts.push(subProduct);
        				}
            		});
    				if(mainProduct && sChildProducts.length > 0){
       					var cProducts = [];
                        sChildProducts.forEach(cProduct =>{
                            if(cProduct.relatedProductParentSku && cProduct.relatedProductParentSku.length > 0
                            && cProduct.relatedProductParentSku === mainProduct.productSKU){
                            cProducts.push(cProduct);
                        	} 
                         });
                        if(cProducts && cProducts.length > 0){
                            mainProduct.addOns = cProducts;
                        }
					}
                    
            	}
            //mainProduct.totalAmount = subTotal;
            subscription.sortedSubscription = mainProduct;
            //component.set("v.sortedSubscription" , mainProduct);
			component.set("v.subscription" , subscription);
            this.setProductSelection(component);
            this.fireSubscriptionEvent(component);
        }
    },
                            
    fireSubscriptionEvent : function(component){ 
    	var sEvent = $A.get("e.c:ssSubscriptionEvent");
        var subscription = component.get("v.subscription");
        sEvent.setParams({"subscription": subscription , "userCart": component.get("v.cart")});
        sEvent.fire();     
    console.log("after firing fireSubscriptionEvent");
    },
    
    setProductSelection : function(component){
    	var selectedProduct ;
        var upsellProduct = {};
        var pOptions = component.find("upsellProductOption");
        var selectedProductSKU;
        var subscriptionItemId;
        [].concat(pOptions).forEach(pOption =>{
            if(pOption.get("v.checked")){
            	selectedProductSKU = pOption.get("v.value");
	            var sProducts = component.get("v.subscription").sortedSubscription.upsellProducts;
            	sProducts.forEach(sProduct => {
                    if(sProduct.productSKU == selectedProductSKU){
                        selectedProduct = sProduct;
                     }
                });
    		}
         });
         component.set("v.selectedProduct" , selectedProduct);
    },
                            
    processTermChanged : function(component , event){
        var selectedProduct = component.get("v.selectedProduct");
        var termType = event.getSource().get("v.value");
        var productSKU = event.getSource().get("v.name");
        if(selectedProduct){
            var termId = "";
            if(termType){
                component.set("v.selectedTerm" , termType);
                selectedProduct.price.forEach(pModel => {
                    if(pModel.subscriptionInstallmentUOM == termType){
                        termId = pModel.priceListID;
                    }
                });
            }
            if(termId && termType && termId.length > 0 && termType.length > 0){
                if(selectedProduct.isTierPriced){
                    var tierVal;
                    var tierQuantity;
                    var tierSelect = component.find("tierSelect");
                    [].concat(tierSelect).forEach(tSelect =>{
                        var tName = tSelect.get("v.name");
                        if(tName == selectedProduct.productSKU){
                            tierVal = tSelect.get("v.value");
                        }
                    });
                    var tQuantity = component.find("tierQuantity");
                    [].concat(tQuantity).forEach(tQuan =>{
                        var qName = tQuan.get("v.name");
                        if(qName == selectedProduct.productSKU){
                            tierQuantity = tQuan.get("v.value");
                        }
                    });
                    if(tierVal && tierQuantity && tierVal.length > 0 && tierQuantity > 0 ){
                        this.generatePayload(component , selectedProduct , termId , termType , tierVal , tierQuantity);
                    }
                }
                else{
                    var quantity;
                    var simQuantity = component.find("simpQuantity");//.get("v.value");
                    [].concat(simQuantity).forEach(sQuan =>{
                        var qName = sQuan.get("v.name");
                        if(qName == selectedProduct.productSKU){
                            quantity = sQuan.get("v.value");
                        }
                    });
                    this.generatePayload(component , selectedProduct , termId , termType , tierVal , quantity , "" , "");
                }
            }
        }
    }, 
        
    processAddonTermChanged : function(component , event){
        var selectedProduct = component.get("v.selectedProduct");
        var termType = event.getSource().get("v.value");
        var productSKU = event.getSource().get("v.name");
        console.log("productSKU = "+productSKU);
        var addChecks = component.find("addOnCheckBox");
        var cCheck = false;
        [].concat(addChecks).forEach(addCheck =>{
            if(addCheck.get("v.value") == productSKU && addCheck.get("v.checked")){
            	cCheck = true
        	}
        });
        console.log("cCheck = "+cCheck);
        if(cCheck){
            var selectedAddon;
            var addOns = [];
            if(selectedProduct.addOnProducts && selectedProduct.addOnProducts.length > 0)
                addOns = addOns.concat(selectedProduct.addOnProducts);
            if(selectedProduct.maintainanceProducts && selectedProduct.maintainanceProducts.length > 0)
                addOns = addOns.concat(selectedProduct.maintainanceProducts);
            console.log("addOns.length = "+addOns.length);
            if(addOns && addOns.length > 0){
                addOns.forEach(addOn => {
                    console.log("addOn.productSKU = "+addOn.productSKU);
                    console.log("productSKU = "+productSKU);
                    if(addOn.productSKU == productSKU){
                        selectedAddon = addOn;
                    }
                });
            }
            console.log("selectedAddon = "+selectedAddon.productSKU);
            console.log("selectedAddon is relationType = "+selectedAddon.relationType);
            if(selectedAddon){
                var termId = "";
                if(termType){
                    //component.set("v.selectedTerm" , termType);
                    selectedAddon.price.forEach(pModel => {
                        if(pModel.subscriptionInstallmentUOM == termType){
                            termId = pModel.priceListID;
                        }
                    });
                }
                console.log("termId = "+termId);
                if(termId && termType && termId.length > 0 && termType.length > 0){
                    
                    var quantity;
                    if(selectedAddon.relationType == "Maintenance"){
                    	quantity = "1";
                	}
                    else{
                        var simQuantity = component.find("addOnQuantity");
                        [].concat(simQuantity).forEach(sQuan =>{
                            var qName = sQuan.get("v.name");
                            if(qName == selectedAddon.productSKU){
                                quantity = sQuan.get("v.value");
                            }
                        });
                	}
                    console.log("quantity = "+quantity);
                    if(quantity && quantity.length > 0)
                    	this.generatePayload(component , selectedAddon , termId , termType , "" , quantity , selectedProduct.productSKU , selectedAddon.relationType)
                }
            }
        }
    },
    
    generatePayload : function(component , product , termId , termType , tierVal , quantity , relatedProductParentSku ,relationType){
        console.log("generating payload....");
        var payload = {};
        var cart = component.get("v.cart");
        payload.cartId = cart.cartId;
        payload.Sku = product.productSKU; 
        payload.subscriptionTermId = termId; 
        payload.subscriptionTermType = termType; 
        payload.productType = product.productType;
        if(relatedProductParentSku && relatedProductParentSku.length > 0){
        	payload.relatedProductParentSku = relatedProductParentSku;
        	payload.relatedProductType = relationType;
        }
        if(product.isTierPriced){
            payload.quantity = "1";
            payload.tier = [];
            var tierChild = {};
            tierChild.tierAttribute = tierVal;
            tierChild.attributeValue = quantity;
            payload.tier.push(tierChild);
        }
        else{
            payload.quantity = quantity;
        }
        this.executeAction(component , 'AddItem' , payload)
    },
    
    processQuantityChanged : function(component , event) {
        /*var selectedProduct = component.get("v.selectedProduct");
        var termButton = component.find("productTermSelect");
        var monthlyAmount;
        var yearlyAmount;
        
        product.price.forEach(pModel => {
                if(pModel.subscriptionInstallmentUOM == "Monthly"){ 
                    termId = pModel.priceListID;
                }
            });
        
        
        component.set("v.monthlyAmount" , "");
        */
        //var termType = component.find("productTermSelect").get("v.value");
        /*var termType = component.get("v.selectedTerm");
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
        }*/
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
                    console.log("cart amount = "+cart.totalAmount);
                    console.log("cart subtotla = "+cart.subTotalAmount);
                    component.set("v.cart" , cart);
                    this.fireSubscriptionEvent(component);
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

        
})