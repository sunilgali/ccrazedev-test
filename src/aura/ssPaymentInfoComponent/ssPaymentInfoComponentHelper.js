({
	initializePaymentData : function(component) {
        var cartId = component.get("v.cartId");
        console.log("cart id in payment = "+cartId);
		var action = component.get("c.getPayamentInitialData");
        action.setCallback(this , function(response){
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var map = response.getReturnValue();
                component.set("v.payment" , map['payment']);
                var mapCountries =  map['countries'];
                var countries = [];
                for(var key in mapCountries){
                	countries.push({value:key, label:mapCountries[key]});
                }
                component.set("v.pCountryOptions" , countries);
            }
        });
        $A.enqueueAction(action);
	},
    
    loadPayStates : function(component){
        var countryCode = component.get("v.payment").country;
        /*var countryCode = "";
        if(component.find("sspCountry")){
           countryCode = component.find("sspCountry").get("v.value");
    	}*/
        var states = [];
        if(countryCode && countryCode != null && countryCode.length >0){
            console.log("load states");
            //component.set("v.ispSpin",true);
            component.set("v.showSpinner",true); 
            //$A.util.removeClass(component.find('paySpinner'), "slds-hide");
            var action = component.get("c.getPayStates");
            action.setParams({"countryCode" : countryCode});
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var mapStates =  response.getReturnValue();
                    for(var key in mapStates){
                        states.push({value:key, label:mapStates[key]});
                    }
                    component.set("v.pStateOptions" , states);
                }
                //component.set("v.ispSpin",false);
                component.set("v.showSpinner",false); 
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.pStateOptions" , states);
        }
	},
    
    validatePayment : function(component , event){
        var payment = component.get("v.payment");
        
    },
    
    updateSubscriptionSummary : function(component , event){
    	var cartId = component.get("v.cartId");
        var payment = component.get("v.payment");
        payment.cardType = component.get("v.cardType");
        //component.set("v.ispSpin" , true);
        component.set("v.showSpinner", true); 
        console.log("showing spinner......");
        var allValid = component.find('ccInfo').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
         }, true);
                
        if(component.find("billCompanyAddress").get("v.checked")){
            payment.email = component.get("v.compEmail"); 
            payment.phone = component.get("v.compPhone");
            payment.street = component.get("v.compAddress"); 
            payment.country = component.get("v.compCountry");
            payment.state = component.get("v.compState");
            payment.city = component.get("v.compCity");
            payment.postalCode = component.get("v.compPostal");
            console.log("using company address....");
        }
        else{
            allValid = component.find('ssInfo').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
             }, true);
        }
        
        console.log(allValid);
        //first validate payment info then fire the event.
        if(allValid){
            
            console.log("firing payment event "+payment);
        	
            console.log("ssPaymentInfoEvent = "+sEvent);
            console.log("payment.city = "+payment.city);
            
            /*var sEvent = $A.get("e.c:ssPaymentInfoEvent");
        	sEvent.setParams({"paymentInfoComplete" : true , "paymentInfo" : payment});
        	sEvent.fire();
            */
            
            var sEvent = $A.get("e.c:ssNewPaymentEvent");
            sEvent.setParams({"paymentcomplete": true , "newPayment":payment});
            sEvent.fire();
            console.log("fired the new event");
        }
        component.set("v.showSpinner",false); 
    },
    
    setCardType : function(component){
        var payment = component.get("v.payment");
        var cardNumber = payment.cardNumber;
        var cardType1 = {value: "" , label: ""};
        if(cardNumber && cardNumber.length > 0){
            var cardType = getCardType(cardNumber);
            if(cardType && cardType != "undefined" && cardType.label && cardType.label.length > 0){
                cardType1 = cardType;
            }
    	}
        component.set("v.cardType" , cardType1.label); 
        component.set("v.cardTypeNumber" , cardType1.value); 
    },
      
    onSubscriptionItemUpdated : function(component, event , helper){
        var subscriptionItemId = event.getParam("subscriptionItemId");
        console.log("got the subscription id in paymentInfo from the sub event "+subscriptionItemId);
        component.set("v.subscriptionItemId" , subscriptionItemId);
    },
    
    validatePaymentSilentPost : function(component){
    	component.set("v.isSpin" , true);
        var pay = component.get("v.payment");
        pay.cardType = component.get("v.cardTypeNumber");
        var vfOrigin = component.get("v.vfHost");
        var recipientPage = component.get("v.recipientPage");
        var paymentWindow = component.find( "vfFrame" ).getElement().contentWindow;
        var payload = {
            transactionType: component.get("v.transactionType"),
            referenceNumber: new Date().getTime(),
            transactionUUID: Math.floor(Math.random() * 100000000),
            secretKey: component.get("v.secretKey"),
            formAction: component.get("v.formAction"),
            accessKey: component.get("v.accessKey"),
            profileId: component.get("v.profileId"),
            currency: "USD",
            amount: "5",
            paymethod: component.get("v.paymentMehtod"),
            cardType: pay.cardType,
            cardHolderName: pay.cardHolderName,
            cardNumber: pay.cardNumber,
            expirationDate: pay.expirationMonth+"-"+pay.expirationYear,
            securityCode: pay.securityCode,
            street: pay.street,
            city: pay.city,
            country: pay.country,
            email: pay.email,
            phone: pay.phone,
            postalCode: pay.postalCode,
            state: pay.state,
            recipientPage: vfOrigin+recipientPage
        }
        paymentWindow.postMessage( payload, vfOrigin);
	},
    
    validatePaymentSOAP : function(component){
        component.set("v.paymentId" , "");
        component.set("v.errorMessage" , "");
        component.set("v.isSpin" , true);
        var payment = component.get("v.payment");
        payment.cardType = component.get("v.cardTypeNumber");
    	var action = component.get("c.validatePayment");
        action.setParams({"paymentModel" : JSON.stringify(component.get("v.payment"))});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var payId = response.getReturnValue();
                if(payId !== null && payId.length > 0){
                    component.set("v.paymentId" , payId);
                    var pAction = $A.get("e.c:ssSCPaymentEvent");
                    pAction.setParams({"paymentId" : payId});
                    pAction.fire();
                }
                else{
                    component.set("v.errorMessage" , "Payment details are not correct.");
                }
            }
            component.set("v.isSpin" , false);
        });
        $A.enqueueAction(action);
	}
    
})