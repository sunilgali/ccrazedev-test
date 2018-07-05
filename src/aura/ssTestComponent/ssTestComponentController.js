({
    onPayScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
        component.set("v.monthOptions", monthOptions());
        component.set("v.yearOptions", yearOptions());
        component.set("v.creditCardOptions", creditCardOptions());
	},
    
    doInit : function(component, event , helper){
        helper.initializePaymentData(component);
    },
    
    handlePayment : function(component, event , helper){
        var paymentId = event.getParam("paymentId");
        console.log("paymentId = "+paymentId);
    },
    
    onCardNumberChange:function(component, event , helper){
        helper.setCardType(component);
    },
    
    onPayCountryChange :function(component, event , helper){
        helper.loadStates(component);
    },
    
	checkPayment : function(component, event, helper) {
        component.set("v.errorMessage" , "");
         var allValid = component.find('ccInfo').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
         }, true);
        if(allValid){
            helper.validatePaymentSOAP(component);
        }
	}
})