({
	updateShowProduct : function(component, event, helper) {
        
		var showProduct = event.getParam("showProduct");
        var cartId = event.getParam("cartId");
        component.set("v.cartId" , cartId);
        component.set("v.showProduct" , showProduct);
	}
})