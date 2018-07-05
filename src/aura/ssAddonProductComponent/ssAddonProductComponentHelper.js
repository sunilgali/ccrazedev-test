({
	doInit : function(component) {
		var action = component.get("c.getAddonProducts");
        action.setParams({"productSKU" : component.get("v.productSKU")});
        action.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var addonProducts = response.getReturnValue();
                component.set("v.addonProducts" , addonProducts);
            }
            else{
                console.log("Error getting addon products");
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getMaintenance");
        action.setParams({"productSKU" : component.get("v.productSKU")});
        action.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var maintainenceProducts = response.getReturnValue();
                component.set("v.maintainenceProducts" , maintainenceProducts);
            }
            else{
                console.log("Error getting maintenance");
            }
        });
        $A.enqueueAction(action);
	},
})