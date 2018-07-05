({
	handleClick : function(component, event, helper) {
         $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Spica/s/add-product-to-cart?productSKU=SPICAKIT&storefront=Spica&quantity=1&transactionType=Buy&isBundle=true" 
        }).fire();
		
	}
})