({
    onScriptsLoaded : function(component, event, helper) { 
		console.log('Scripts loaded');
	},
    
	doInit : function(component, event , helper){
        helper.doInit(component);
    },
        
    onCountryChange :function(component, event , helper){
        helper.loadStates(component);
    },
    
    processAccount : function(component, event , helper){
        helper.processAccount(component , event); 
    },
    
    goToProduct : function(component, event , helper){
        helper.navigateToCommunityPage("/product-detail");
    },
    
    updateCartCompany : function(component, event, helper){
        //console.log("ssCompanyInfo updateCartCompany");
        var cart = event.getParam("userCart");
        //cart.transactionType = "Buy";
        //console.log("ssCompany Info updateCartCompany cart transaction type="+cart.transactionType);
        component.set("v.cart" , cart);
        component.set("v.cartId" , cart.cartId);
    },
    
    
    
})