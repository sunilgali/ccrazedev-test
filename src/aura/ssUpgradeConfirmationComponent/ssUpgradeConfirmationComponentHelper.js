({
	doInit : function(component, event) {
       	var previousSubscriptionId = this.getNavigateParameter("previousSubscriptionId");
        var upgradeSubscriptionId = this.getNavigateParameter("upgradeSubscriptionId");
        console.log("previousSubscriptionId = "+previousSubscriptionId);
        console.log("upgradeSubscriptionId = "+upgradeSubscriptionId);
        //previousSubscriptionId = "a1l1N00000285tyQAA";
        //upgradeSubscriptionId = "a1l1N00000285tyQAA";
        if(previousSubscriptionId && upgradeSubscriptionId){
            var action = component.get("c.getSubscriptions");
            component.set("v.isSpinner" , true);
            action.setParams({"previousSubscriptionId" : previousSubscriptionId , "upgradeSubscriptionId" : upgradeSubscriptionId});
            action.setCallback(this , function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var map = response.getReturnValue();
                    if(map){
                        var previousSubscription = map['previousSubscription'];
                        console.log("previousSubscription = "+previousSubscription.subscriptionId);
                        this.processSubscription(component , previousSubscription , true);
                        
                        var upgradeSubscription = map['upgradeSubscription'];
                        console.log("upgradeSubscription = "+upgradeSubscription.subscriptionId);
                        console.log("upgradeSubscription cart = "+upgradeSubscription.cart.cartId);
                        this.processSubscription(component , upgradeSubscription , false);
                    }
                }
                else{
                    console.log("Error....");
                }
                component.set("v.isSpinner" , false);
            });
            $A.enqueueAction(action);
        }
        else{
            console.log("Error....");
        }
	},
    
    processSubscription : function(component , subscription , previous){
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
            subscription.sortedSubscription = mainProduct;
    		if(previous){
				component.set("v.previousSubscription" , subscription);
			}
 			else{
 				component.set("v.upgradeSubscription" , subscription);
 			}
        }
    },
})