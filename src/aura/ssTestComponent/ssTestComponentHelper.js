({
	initializePaymentData : function(component) {
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
                component.set("v.countryOptions" , countries);

                /* Below needed for Silent Post.
                var cData = map['cybersourceMetadata'];
                component.set("v.vfHost" , cData.Target_URL__c);
                component.set("v.recipientPage" , cData.Recipient_Page__c);
                component.set("v.lgHost" , cData.Source_URL__c);
                component.set("v.formAction" , cData.Endpoint_URL__c);
                component.set("v.secretKey" , cData.Client_Secret__c + cData.Client_Secret_1__c);
                component.set("v.profileId" , cData.Profile_Id__c);
                component.set("v.accessKey" , cData.Access_Key__c);
                component.set("v.transactionType" , cData.Authorization__c);   
                component.set("v.paymentMehtod" , cData.Payment_Method__c);
                
                var pEvent = $A.get("e.c:ssSCPaymentEvent");
                
                window.addEventListener("message", function(event) {
                    var vfOrigin = component.get("v.vfHost");
                    if (event.origin !== vfOrigin) {
                        return;
                    }
                    if(event.data && event.data !== '{}'){
                        var jsonOut = JSON.parse(event.data);
						var reasonCode = jsonOut["reason_code"];
                        if(reasonCode === "100"){
                            component.set("v.paymentId" , jsonOut["payment_token"]);
                        	pEvent.setParam("paymentId" , jsonOut["payment_token"]);
                        	pEvent.fire();
                        }
                        else{
                            //console.log("Error "+jsonOut);
                            
                            component.set("v.errorMessage" , jsonOut["message"] + " "+jsonOut["invalid_fields"]);
                        }
                        component.find( "vfFrame" ).getElement().src= component.get("v.vfHost") + component.get("v.recipientPage");
                    }
                    component.set("v.isSpin",false);
                }, false);*/
            }
        });
        $A.enqueueAction(action);
	},
    
    loadStates : function(component){
        var countryCode = component.get("v.payment").country;
        var states = [];
        if(countryCode != null && countryCode.length >0){
            console.log("load states");
            component.set("v.isSpin",true);
            var action = component.get("c.getPayStates");
            action.setParams({"countryCode" : component.get("v.payment").country});
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var mapStates =  response.getReturnValue();
                    for(var key in mapStates){
                        states.push({value:key, label:mapStates[key]});
                    }
                    component.set("v.stateOptions" , states);
                }
                component.set("v.isSpin",false);
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.stateOptions" , states);
        }
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
        //alert("card type = "+component.get("v.cardType"));
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