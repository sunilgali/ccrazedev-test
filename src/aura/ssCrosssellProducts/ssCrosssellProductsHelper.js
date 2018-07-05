({
	doInit : function(component) {
        var cartId = this.getNavigateParameter("cartId");
        var productSKU = this.getNavigateParameter("cartId");
        
        if(productSKU){
            console.log("productSKU = "+component.get("v.productSKU"));
            var action = component.set("c.getCrossSellProducts" , productSKU);
            action.setParams({"productSKU": productSKU});
            component.set("v.isSpin",true);
            action.setCallback(this , function(response){
                var state = response.getState();
                if( state === "SUCCESS"){
                    var crosssell = response.getReturnValue();
                    component.set("v.crossSellProducts" , crosssell);
                } 
                else if (state === "ERROR") {
                    console.log("Error");
                }
                component.set("v.isSpin",false);
                //this.hideSpinner();
            });
            $A.enqueueAction(action);
    	}
	},
    
})