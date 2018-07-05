({
	handleAdobeTryPhotoshop : function(component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({ 
       "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOPHOTO&storefront=Adobe&quantity=1&transactionType=Buy&isTier=true" 
    }).fire();
	},
    handleAdobeBuyPhotoshop: function(component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({ 
       "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOPHOTO&storefront=Adobe&quantity=1&transactionType=Buy&isTier=true" 
    }).fire();
	},
})