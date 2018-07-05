({
	doInit : function(component) {
		var action = component.get("c.getProductDetails");
        action.setParams({"productSKU" : component.get("v.productSKU")});
        action.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var product = response.getReturnValue();
                component.set("v.product" , product);
            }
            else{
                console.log("Error getting product details");
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.createCart");
        action.setParams({"productSKU" : component.get("v.productSKU")});
        action.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var product = response.getReturnValue();
                component.set("v.cart" , cart);
            }
            else{
                console.log("Error getting product details");
            }
        });
        $A.enqueueAction(action);
	},
    
    
})