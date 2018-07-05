({
    onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
        component.set("v.monthOptions", monthOptions());
        component.set("v.yearOptions", yearOptions());
	},
    
    doInit : function(component, event , helper){
        helper.initializeData(component);
    },
    
    handlePayment : function(component, event , helper){
        var paymentId = event.getParam("paymentId");
        component.set("v.paymentId" , paymentId);
        //console.debug("paymentId = "+paymentId);
    },
    
    onCountryChange :function(component, event , helper){
        helper.loadStates(component);
    },
    
	checkPayment : function(component, event, helper) {
        component.set("v.isSpin",true);
        var pay = component.get("v.payment");
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
            paymethod: "card",
            cardType: "001",//pay.cardType,
            cardHolderName: pay.cardHolderName,
            cardNumber: "4111111111111111",//pay.cardNumber,
            expirationDate: "11-2022",//pay.expirationMonth+"-"+pay.expirationYear,
            securityCode: "022",//pay.securityCode,
            street: pay.street,
            city: pay.city,
            country: "US",//pay.country,
            email: "sgali@docmation.com",//pay.email,
            phone: "4704473148",//pay.phone,
            postalCode: pay.postalCode,
            state: pay.state,
            recipientPage: vfOrigin+recipientPage
        }
        paymentWindow.postMessage( payload, vfOrigin);
        

        /*console.log(component.find("vfFrame"));
        alert(component.find("vfFrame").getElements());
        alert(component.find("vfFrame").getElement().contentWindow);
         //var vfWindow = component.find("vfFrame").getElement().contentWindow;
		//alert(component.find("vfFrame").getElement().contentWindow.getElementById("profile_id").value);
        //alert(vfWindow);
        alert(component.find("reference_number"));
		console.log($('vfFrame').contents().find('#profile_id'));
		alert($('vfFrame').contents().find('#reference_number'));
        alert($('vfFrame').contents().find('#reference_number').val());
        var allValid = true;*/
        /*var allValid = component.find('ccInfo').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
         }, true);
        */
        
         /*if (allValid) {
             var pay = component.get("v.payment");
             //alert(component.get("v.payment.cardHolderName"));
             //alert(pay);
             var action = component.get("c.validatePayment");
             //action.setParams({"paymentModel" : pay});
             action.setParams({"paymentModel": JSON.stringify(pay)});
             action.setCallback(this , function(response){
                 var state = response.getState();
                 if (state === "SUCCESS") {
                    var paymentId = response.getReturnValue();
                 	alert(paymentId);
                 }
                 else {
                     console.log("Failed with state: " + state);
                     alert(state);
                 }
                 
             });
             $A.enqueueAction(action);
             
         } else {
             //alert('Please update the invalid form entries and try again.');
         }*/
	}
})