({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
        /*var userContext = sessionStorage.getItem("userContext");
        alert("UserContext = "+userContext);
        if(!userContext){
        	sessionStorage.setItem("userContext", "Test Token!!!!!!");
        }*/
		helper.doInit(component);
	},
    
    navigateNext : function(component , event, helper){
        
        /*var cEvent = $A.get("e.c:ssProductEvent");
        cEvent.setParams({"showProduct" : false , "cartId" : component.get("v.cartId")});
        cEvent.fire();
        */
        
        
        /*var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ssCompanyInfoComponent",
            componentAttributes: {
            	cartId : component.get('v.cartId')
            }
        });
        evt.fire();*/
        var cartId = component.get('v.cartId');
        
        /*var urlEvent = $A.get('e.force:navigateToURL');
        var params = {
            'url': '/cart-listing?cartId='+cartId,
            'cartId': component.get('v.cartId')
        };
        if (urlEvent) {
            urlEvent.setParams(params);
            urlEvent.fire();
        }*/
        console.log("Inside navigateToComponenrt firing base componet redirect");
		helper.navigateToCommunityPage("/cart-listing?cartId="+cartId , false);        
    },
     
    updateCartPrice : function(component, event, helper){
        var cart = event.getParam("userCart");
        component.set("v.cart" , cart);
        component.set("v.cartId" , cart.cartId);
        component.set("v.totalPrice" , cart.totalAmount);
    },
    
    applyCoupon : function(component, event , helper){
        helper.applyCoupon(component , event);
    },
    
    showModal : function(component, event , helper){
        component.set("v.showModal" , true);
    },
    
    closeModal : function(component, event , helper){
        component.set("v.showModal" , false);
    },
    

    handleShowModal: function(component, event, helper) {
        component.find('overlayLib').showCustomModal({
        	header: "Modal header section",
        	body: "Content of Modal window",
        	showCloseButton: true
        });
    },

})