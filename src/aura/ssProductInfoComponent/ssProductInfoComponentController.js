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
        component.set("v.cart" , cart);
        //component.set("v.cartId" , cart.cartId);
    },
})