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
    
    /*doCartUpdated : function(component , event , helper){
        var cart = event.getParam("userCart");
        console.log("cart id in doUpdate cart "+cart.cartId);
        component.set("cartId" , cart.cartId);
    },*/
    
    onSubscriptionItemUpdated : function(component, event , helper){
        helper.onSubscriptionItemUpdated(component, event);
    },
    
    handlePayment : function(component, event , helper){
        var paymentId = event.getParam("paymentId");
        console.log("paymentId = "+paymentId);
    },
    
    onCardNumberChange:function(component, event , helper){
        helper.setCardType(component);
    },
    
    onPayCountryChange :function(component, event , helper){
        var countryCode = component.get("v.payment").country;
        if(countryCode && countryCode != null && countryCode.length >0){
            helper.loadPayStates(component);
        }
    },
    
    creditOptionClicked : function(component , event , helper){
        if(event.getSource().get("v.checked")){
            component.find("paypalOption").set("v.checked" , false);
        }
    },
    
    paypalOptionClicked: function(component , event , helper){
        if(event.getSource().get("v.checked")){
            component.find("creditOption").set("v.checked" , false);
        }
        component.set('v.paypalflag',true);
    },
    
    showHideAddress : function(component , event , helper){
        var showAddress = "false";
        if(event.getSource().get("v.checked")){
            showAddress = false;
        }
        else{
            showAddress = true;
        }
        component.set("v.showAddress" , showAddress);
        console.log(component.get("v.showAddress"));
    },
    
    doAddress : function(component , event , helper){
        var params = event.getParam('arguments');
		//console.log(params);
        if(params){
            var addressDetails = params.addressDetails;
            component.set("v.compEmail" ,addressDetails[0]);
            component.set("v.compPhone" ,addressDetails[1]);
            component.set("v.compAddress" ,addressDetails[2]);
            component.set("v.compCountry" ,addressDetails[3]);
            component.set("v.compState" ,addressDetails[4]);
            component.set("v.compCity" ,addressDetails[5]);
            component.set("v.compPostal", addressDetails[6]);
            component.set("v.contactId", addressDetails[7]);
            
        }
    },
    
    /*startSubscription : function(component , event , helper){
        helper.startSubscription(component, event);
    },*/
                    
                    updateSubscriptionSummary : function(component , event , helper){
                        helper.updateSubscriptionSummary(component, event);
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