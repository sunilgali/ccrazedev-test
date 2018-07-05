({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    updateCartPrice : function(component, event, helper){
        //var price = 0.0;
        //var cart = component.get("v.cart");
        
        var cart = event.getParam("userCart");
        //alert("Inside and cart = "+cart);
        //alert("Inside and cart = "+cart.cartType);
        //alert("Inside and price = "+cart.totalAmount);
        component.set("v.totalPrice" , cart.totalAmount);
        /*if(product.isTierPriced){
            product.price.forEach(sProd =>{
                    sProd.tierPriceList.forEach(tier =>{
                        //console.log(sProd.tierDescription);
                        if(tier.selected == true){
                            if(tier.quantity && tier.listPrice)
                                price = Math.round(tier.quantity*tier.listPrice*100)/100;
                        }
                    });
            });
        }
		//alert("Price = "+price);
        
        var pPrice = parseFloat(component.find("productInfo").get("v.productPrice"));
        if(!pPrice) pPrice = 0.0;
        var pAddonPrice = parseFloat(component.find("addonProducts").get("v.relatedProductsPrice"));
        if(!pAddonPrice) pAddonPrice = 0.0;
        var pMaintPrice = parseFloat(component.find("productMaintenance").get("v.relatedProductsPrice"));
        if(!pMaintPrice) pMaintPrice = 0.0;
        component.set("v.totalPrice" , price + pPrice + pAddonPrice + pMaintPrice);
        //component.set("v.totalPrice" , price);
        */
    },
    
})