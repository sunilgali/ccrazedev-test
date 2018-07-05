({
	doInit : function(component) {
        
        var cartId = this.getNavigateParameter("cartId");
        var subscriptionItemId = this.getNavigateParameter("subscriptionItemId");
        
        console.log("ssCompanyInfoComapneyInfo cartId from URL..." + cartId);
        //cartId = "ef994577-47d1-44dc-bec6-b6e151435a70";
        if(cartId){
            component.set("v.subscriptionItemId" , subscriptionItemId);
            var action = component.get("c.populateInitialData");
            action.setParams({"cartId" : cartId});
            //alert(cartId);
            //component.set("v.isSpin" , true);
            component.set("v.showSpinner",true); 
            action.setCallback(this , function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var map = response.getReturnValue()
                    var cart = map['cart'];

                    console.log("ssCompanyInfo transaction type = "+cart.transactionType);
                    component.set("v.cart" , cart);
                    
                    if(subscriptionItemId){
                        var subEvent = $A.get("e.c:ssSubscriptionItemEvent");
                        subEvent.setParams({"subscriptionItemId" : subscriptionItemId});
                        subEvent.fire();
                    }
                    
                    var cEvent = $A.get("e.c:ssCartEvent");
                    cEvent.setParams({"userCart" : cart});
                    cEvent.fire();
                    
                    var account = map['account'];
                    component.set("v.account" , account);
                    console.log(account.accountId);
                    console.log(account.billingContact);
                    console.log(account.billingContact.contactId);
                    
                    var mapCountries =  map['countries'];
                    var countries = [];
                    for(var key in mapCountries){
                        countries.push({value:key, label:mapCountries[key]});
                    }
                    component.set("v.countryOptions" , countries);
                    console.log("countries..."+countries);
                }
                else{
                    console.log("Error loading countries...");
                }
                //component.set("v.isSpin" , false);
                component.set("v.showSpinner",false); 
            });
            $A.enqueueAction(action);
        }
	},
    
    loadStates : function(component){
        var countryCode = component.find("ssCountry").get("v.value");
        var states = [];
        if(countryCode != null && countryCode.length >0){
            console.log("load states");
            //component.set("v.isSpin",true);
            component.set("v.showSpinner",true); 
            var action = component.get("c.getStates");
            action.setParams({"countryCode" : countryCode});
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var mapStates =  response.getReturnValue();
                    for(var key in mapStates){
                        states.push({value:key, label:mapStates[key]});
                    }
                    component.set("v.stateOptions" , states);
                }
                else{
                    console.log("Error loading states...");
                }
                //component.set("v.isSpin",false);
                component.set("v.showSpinner",false); 
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.stateOptions" , states);
        }
	},
    
    
    processAccount : function(component , event){
        var cart = component.get("v.cart");
        var account = component.get("v.account");
        var cName = component.find("ssCompName").get("v.value");
        var fName = component.find("ssFName").get("v.value");
        var lName = component.find("ssLName").get("v.value");
        var email = component.find("ssEmail").get("v.value");
        var phone = component.find("ssPhone").get("v.value"); 
        
        var address = component.find("ssAddress") ? component.find("ssAddress").get("v.value") : "";
        var country = component.find("ssCountry") ? component.find("ssCountry").get("v.value") : "";
        var state = component.find("ssState") ? component.find("ssState").get("v.value") : "";
        var city = component.find("ssCity") ? component.find("ssCity").get("v.value") : "";
        var postalCode = component.find("ssPostalCode") ? component.find("ssPostalCode").get("v.value") : "";
        if(cart){
            if(cart.transactionType == 'Buy'){
                if(cName != null && cName.length > 0 && fName != null  && fName.length > 0 && lName != null 
                   && lName.length > 0 && email != null && email.length > 0 && phone != null 
                   && phone.length > 0  && address != null && address.length > 0 
                   && country != null && country.length > 0 && state != null && state.length > 0
                   && city != null && city.length > 0 && postalCode != null && postalCode.length > 0)
                {
                    var allValid = this.isComponentValid(component.find("ssCompName"))
                        && this.isComponentValid(component.find("ssFName"))
                        && this.isComponentValid(component.find("ssLName"))                                             
                        &&  this.isComponentValid(component.find("ssEmail"))
                        && this.isComponentValid(component.find("ssPhone"))
                        && this.isComponentValid(component.find("ssAddress"))
                        && this.isComponentValid(component.find("ssCountry"))                                             
                        &&  this.isComponentValid(component.find("ssState"))
                        && this.isComponentValid(component.find("ssCity"))
                        && this.isComponentValid(component.find("ssPostalCode"));
                    console.log(allValid);
                    if(allValid){
                        var contact = account == null ? null : account.billingContact;
                       	var payload ={
                           "cartId": cart.cartId,
                           "accountId": account == null ? "" : account.accountId,
                           "contactId": contact == null ? "" : contact.contactId,
                           "transactionType": cart.transactionType,
                           "companyName": cName,
                           "firstName": fName,
                           "lastName": lName,
                           "email": email,
                           "phone": phone,
                           "address": address,
                           "country": country,
                           "state": state,
                           "city": city,
                           "postalCode": postalCode
                        }
                       
                        console.log(JSON.stringify(payload));
                        var cAddress = [];
                        cAddress.push(email);
                        cAddress.push(phone);
                        cAddress.push(address);
                        cAddress.push(country);
                        cAddress.push(state);
                        cAddress.push(city);
                        cAddress.push(postalCode);
                        
                        this.executeAction(component , payload , cAddress);
                    }
                }     
            }
            else{
                if(cName != null && cName.length > 0 && fName != null  && fName.length > 0 
                    && lName != null  && lName.length > 0 && email != null && email.length > 0 && phone != null  
                    && phone.length > 0){
                    var allValid = this.isComponentValid(component.find("ssCompName"))
                        && this.isComponentValid(component.find("ssFName"))
                        && this.isComponentValid(component.find("ssLName"))                                             
                        &&  this.isComponentValid(component.find("ssEmail"))
                        && this.isComponentValid(component.find("ssPhone"));
                    console.log(allValid);
                    var contact = account == null ? null : account.billingContact;
                   	if(allValid){                                      
                       var payload ={
                            "cartId" : cart.cartId,
                            "transactionType" : cart.transactionType,
                            "accountId": account == null ? "" : account.accountId,
                            "contactId": contact == null ? "" : contact.contactId,
                            "companyName" :cName,
                            "firstName" :fName,
                            "lastName" :lName,
                            "email" :email,
                            "phone" :phone
                        }
                        this.executeAction(component , payload , null);
                    }
                }     
            }
        }
    },
    
    isComponentValid : function(cmp){
        cmp.showHelpMessageIfInvalid();
        return cmp.get('v.validity').valid;
    },
    
    executeAction : function(component , payload , cAddress){
        console.log("executing execute action");
        var cart = component.get("v.cart");
        
        var action = component.get("c.createAccount");
        action.setParams({"jsonStr" : JSON.stringify(payload)});
        //component.set("v.isSpin" , true);
        component.set("v.showSpinner",true); 
        
        action.setCallback(this , function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //console.log(response.getReturnValue()); 
                var result = response.getReturnValue();
                console.log("accountId = "+result.accountId);
                console.log("contactId = "+result.contactId);
                console.log("oppurtunityId = "+result.opportunityId);
                component.set("v.isPaymentVisible" , true);
                console.log('cAddress = '+cAddress);
                /*if(cAddress){
                    cAddress.push(result.contactId);
                    var payComp = component.find("pComponent");
                    payComp.addressMethod(cAddress);
                }*/
                console.log(component.get("v.isPaymentVisible"));
                var tType = cart.transactionType;
                console.log("tType = "+tType);
                if(tType && tType.toLowerCase() == "buy"){
                	$A.util.removeClass(component.find("paymentComponent"), "slds-hide");
                    /*var paymentInfo = {}
                    paymentInfo.city = payload.city; 
                    paymentInfo.streetAddress = payload.address; 
                    paymentInfo.state = payload.state; 
                    paymentInfo.country = payload.country; 
                    paymentInfo.postalCode = payload.postalCode;
                    var sEvent = $A.get("e.c:ssPaymentInfoEvent");
                    sEvent.setParams({"paymentInfo" : paymentInfo});
                    sEvent.fire();*/
                }
                else{
                    console.log("hide the spinner....");
                    component.set("v.showSpinner",false); 
                    var paymentInfo = {}
                    paymentInfo.city = payload.city; 
                    paymentInfo.streetAddress = payload.address; 
                    paymentInfo.state = payload.state; 
                    paymentInfo.country = payload.country; 
                    paymentInfo.postalCode = payload.postalCode;
                    var sEvent = $A.get("e.c:ssPaymentInfoEvent");
                    sEvent.setParams({"paymentInfoComplete" : true, "paymentInfo":paymentInfo});
                    sEvent.fire();
                }
            }					 
            else{
                console.log("Error while creating account.");
            }
            console.log("hide the spinner....");
            component.set("v.showSpinner",false); 
            //component.set("v.isSpin" , false);
        });
        $A.enqueueAction(action);
    },
})