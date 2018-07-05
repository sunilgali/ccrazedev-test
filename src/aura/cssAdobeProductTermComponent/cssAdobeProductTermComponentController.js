({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
        
    },
        
    kitSelectionChanged : function(component, event ,helper){
        helper.processDynamicKitItem(component , event);
    },
    
    termChanged : function(component , event , helper){
        helper.processTermChanged(component , event);
    },
    
    tierQuantityChanged : function(component , event , helper){
        helper.processQuantityChanged(component , event);
    },
    
    simpleQuantityChanged : function(component , event , helper){
        helper.processQuantityChanged(component , event);
    },
    
    updateCart : function(component , event , helper){
        var cart = event.getParam("userCart");
        console.log("product info updating cart "+cart.totalAmount);
        var selectedTerm = component.get("v.selectedTerm");
        console.log("selectedTerm = "+selectedTerm);
        var mainProducts = [];
        var dynamicAmount = 0;
        var bProducts = [];
		var isDynamicKit;
        
        if(cart && cart.cartItems && cart.cartItems.length > 1){
            var cItems = cart.cartItems;
            cItems.forEach(cartItem => {
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
                    cItems.forEach(cartItem => {
                        if(cartItem.parentSku && cartItem.parentSku.length > 0
                        && mProduct.Sku == cartItem.parentSku){
                            console.log("found bundle component "+cartItem.Sku);
                            bProducts.push(cartItem);
                    		isDynamicKit = true;
                    		dynamicAmount += cartItem.subAmount;
                        } 
                    });
                });
            }	
        }
        /*if(mainProducts[0]){
            selectedSubTerm = mainProducts[0].subscriptionFrequency; 
            selectedSubtermType =  mainProducts[0].subscriptionTermType;
            console.log("selectedSubTerm = "+selectedSubTerm +" selectedSubtermType = "+selectedSubtermType);
            console.log("dynamicAmount  = "+dynamicAmount);
        } */
        console.log("isDynamic  = "+isDynamicKit);
        if(isDynamicKit){
            component.set("v.isDynamicKit" , isDynamicKit);
            component.set("v.dynamicAmount" , dynamicAmount);
        }
        else{
            component.set("v.isDynamicKit" , false);
            component.set("v.dynamicAmount" , 0);        
        }
        cart.subscriptionTermType = selectedTerm;
        
        //component.set("v.cartId" , cart.cartId);
        
        //btn-selected
        var btns = component.find("productTermSelect");
                    [].concat(btns).forEach(btn =>{
                    console.log(btn.get("v.label") +"-----"+selectedTerm);
                    if(btn.get("v.label").includes(selectedTerm)){
                    console.log("adding selected classs to button");
                    	$A.util.addClass(btn, "btn-selected");
                	}
                    else{
                    console.log("removing selected classs to button");
                    	$A.util.removeClass(btn, "btn-selected");
                	}
                }); 
         component.set("v.cart" , cart);
    },
})