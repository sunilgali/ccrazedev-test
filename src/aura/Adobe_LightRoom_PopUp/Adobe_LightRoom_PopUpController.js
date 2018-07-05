({
	handleAdobeBuyLightroom : function(component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({ 
       "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOLIGHT&storefront=Adobe&quantity=1&transactionType=Buy&isTier=true" 
    }).fire();
	},
    handleAdobeTryLightroom: function(component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({ 
       "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOLIGHT&storefront=Adobe&quantity=1&transactionType=Buy&isTier=true" 
    }).fire();
	},
})