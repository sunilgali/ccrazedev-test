({
	doInit : function(component, event) {
		var action = component.get("c.getSubscriptions");
        component.set("v.isSpin" , true);
        action.setCallback(this , function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var subscriptions = response.getReturnValue();
                if(subscriptions){
                    this.processSubscriptions(component , subscriptions);
                }
            }
            component.set("v.isSpin" , false);
        });
        $A.enqueueAction(action);
    },
    
    processSubscriptions : function(component , subscriptions){
        var mainProducts = [];
        if(subscriptions){
            subscriptions.forEach(subscription => {
                if(subscription.subscribedProducts){
                	var subProducts = subscription.subscribedProducts;
                	var sMainProducts = [];
                	var sChildProducts = [];
                	subProducts.forEach(subProduct =>{
                        if( !subProduct.relatedProductParentSku || subProduct.relatedProductParentSku == null 
                				|| subProduct.relatedProductParentSku.length == 0){
                        	sMainProducts.push(subProduct);
                			console.log("add main product "+subProduct.productSKU);
                        }
                        else{
                            sChildProducts.push(subProduct);
            				console.log("add child product "+subProduct.productSKU);
        				}
            		});
    				//console.log("sMain size = "+sMainProducts.length+" sChildProducts size = "+sChildProducts.length);
    				if(sMainProducts.length > 0 && sChildProducts.length > 0){
                        sMainProducts.forEach(sProduct =>{
                            var cProducts = [];
                            sChildProducts.forEach(cProduct =>{
    							console.log("child sku "+cProduct.relatedProductParentSku+" parent sku "+sProduct.productSKU);
                            	if(cProduct.relatedProductParentSku && cProduct.relatedProductParentSku.length > 0
                            		&& cProduct.relatedProductParentSku === sProduct.productSKU){
                            		cProducts.push(cProduct);
    								//console.log("adding the product add on --"+cProduct.relatedProductParentSku)
                        		} 
                         	});
							console.log("cProducts = "+cProducts.length);
                            if(cProducts && cProducts.length > 0){
                                sProduct.addOns = cProducts;
                            }
							mainProducts.push(sProduct);
                        });
					}
                    else{
                        if(sMainProducts.length > 0 ){
                            mainProducts = mainProducts.concat(sMainProducts);
                            console.log("Aftrer concating...")
                        	//mainProducts.push(sMainProducts[0]);
                        }
                    }
            	}
            });
            component.set("v.sortedSubscriptions" , mainProducts);
			component.set("v.subscriptions" , subscriptions);
        }
    },
        
    cancelSubscription : function(component, event) {
        
        var subId = event.getSource().get("v.name");
        
        var subscriptions = component.get("v.subscriptions");
        var sModel;
        if(subscriptions && subId){
            subscriptions.forEach(subModel =>{
                if(subModel.subscribedProducts){
                        var subProducts = subModel.subscribedProducts;
                        subProducts.forEach(subProduct =>{
                        //console.log("subProduct.subscriptionItemId = "+subProduct.subscriptionItemId);
                        if(subProduct.subscriptionItemId && subProduct.subscriptionItemId == subId) {
                            sModel = subProduct;
                        }
                                          });
                }
            });
        }
        if(sModel){
            console.log("subscriptionItemId = "+subId);
            console.log("accountId = "+sModel.accountId);
            console.log("billingSubscriptionId = "+sModel.billingSubscriptionId)
            if(confirm("Please confirm the cancellation of the subscription "+sModel.productName)){
                var action = component.get("c.cancelSubscriptionItem");
                action.setParams({"accountId": sModel.accountId , "subscriptionItemId": subId, "billingSubscriptionId": sModel.billingSubscriptionId});
                component.set("v.isSpin" , true);
                action.setCallback(this , function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var subscriptions = response.getReturnValue();
                        if(subscriptions){
                            this.showToast("Success" , "success" , "sticky" , sModel.productName+" Subscription has been cancelled");
                            this.processSubscriptions(component , subscriptions);
                        }
                    }
                    else{
                        console.log("Error deleting a subscription");
                        this.showToast("Error" , "error" , "sticky" , "Error deleting a subscription");
                    }
                    component.set("v.isSpin" , false);
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    upgradeSubscription : function(component , event){
    	var subId = event.getSource().get("v.name");
        this.navigateToCommunityPage("/upgrade-subscription?subscriptionItemId="+subId , false);
    },
        
    convertSubscription : function(component , event){
     	var subId = event.getSource().get("v.name");
        var subscriptions = component.get("v.subscriptions");
        var sModel;
        if(subscriptions && subId){
            subscriptions.forEach(subModel =>{
                if(subModel.subscribedProducts){
                        var subProducts = subModel.subscribedProducts;
                        subProducts.forEach(subProduct =>{
                        //console.log("subProduct.subscriptionItemId = "+subProduct.subscriptionItemId);
                        if(subProduct.subscriptionItemId && subProduct.subscriptionItemId == subId) {
                            sModel = subProduct;
                        }
                                          });
                }
            });
        }
        if(sModel){
        	var action = component.get("c.getConvertSubscriptionData");
            action.setParams({"productId": sModel.productId , 
                              "productQuantity": sModel.productQuantity+"",
                              "subscriptionTermType": sModel.subscriptionTermType
                             });
            console.log("sModel.productQuantity = "+sModel.productQuantity);
            //action.setParams({"productQuantity": sModel.productQuantity+""});
            //action.setParams({"subscriptionTermType": sModel.subscriptionTermType});
            //action.setParams({"subscriptionItemId": sModel.subscriptionItemId});                              
            component.set("v.isSpin" , true);
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var cartId = response.getReturnValue();
                    if(cartId){
						this.navigateToCommunityPage("/cart-listing?cartId="+cartId+"&subscriptionItemId="+subId , false); 
                    }
                    else{
                        console.log("Error converting a subscription");
                    	this.showToast("Error" , "error" , "sticky" , "Error converting the subscription");
                    }
                }
                else{
                    console.log("Error converting a subscription");
                    this.showToast("Error" , "error" , "sticky" , "Error converting the subscription");
                }
                component.set("v.isSpin" , false);
            });
            $A.enqueueAction(action);
        }
    }
        
})