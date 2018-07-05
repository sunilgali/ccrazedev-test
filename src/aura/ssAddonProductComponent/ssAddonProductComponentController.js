({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    updatePrice : function(component, event, helper){
        var tPrice = component.find('addonProdSelect').reduce(function (retPrice, inputCmp) {
            var innerPrice = parseFloat(inputCmp.get("v.value"));
            if(innerPrice){
            	retPrice = retPrice + innerPrice;
        	}
            return retPrice ;
         }, 0);
        component.set("v.addonProductsPrice" , tPrice);
        var event = component.getEvent("ssTermPrice");
        event.fire();
    }
})