({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    updatePrice : function(component, event , helper){
		helper.processAddonProducts(component , event);
        
        var pSource = event.getSource();
        var sName = pSource.getLocalId();
        console.log("sName = "+sName);
        if(sName == "addOnTermPlanSelect"){
            var btns = component.find("addOnTermPlanSelect");
            [].concat(btns).forEach(btn =>{
                $A.util.removeClass(btn, "btn-selected");
            }); 
            $A.util.addClass(pSource, "btn-selected");
        }
    },
    
    updateCart : function(component , event , helper){
        var cart = event.getParam("userCart");
        console.log("related product info updating cart "+cart.totalAmount);
        component.set("v.cart" , cart);
        //component.set("v.cartId" , cart.cartId);
    }
    
})