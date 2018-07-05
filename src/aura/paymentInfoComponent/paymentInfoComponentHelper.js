({
	initializeData : function(component) {
		var action = component.get("c.getInitialData");
        action.setCallback(this , function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var map = response.getReturnValue();
                component.set("v.payment" , map['payment']);
                
                var mapCountries =  map['countries'];
                var countries = [];
                for(var key in mapCountries){
                    alert(key);
                	countries.push({value:key, label:mapCountries[key]});
                }
                component.set("v.countryOptions" , countries);

                var cData = map['cybersourceMetadata'];
                component.set("v.vfHost" , cData.Target_URL__c);
                component.set("v.recipientPage" , cData.Recipient_Page__c);
                component.set("v.lgHost" , cData.Source_URL__c);
                component.set("v.formAction" , cData.Endpoint_URL__c);
                component.set("v.secretKey" , cData.Client_Secret__c + cData.Client_Secret_1__c);
                component.set("v.profileId" , cData.Profile_Id__c);
                component.set("v.accessKey" , cData.Access_Key__c);
                component.set("v.transactionType" , cData.Authorization__c);                         
                var pEvent = $A.get("e.c:ssSCPaymentEvent");
                var iframeCmp = component.find( "vfFrame" ).getElement();
                //alert("pEvent = "+pEvent);
                window.addEventListener("message", function(event) {
                    var vfOrigin = component.get("v.vfHost");
                    if (event.origin !== vfOrigin) {
                        return;
                    }
                    if(event.data && event.data !== '{}'){
                        var jsonOut = JSON.parse(event.data);
                        /*for(var i in jsonOut) { 
                            console.log(i);
                            console.log(jsonOut[i]);
                        }*/
                                        
                        alert("payment_token = "+jsonOut["payment_token"]);
                        pEvent.setParam("paymentId" , jsonOut["payment_token"]);
                        pEvent.fire();
                        
                        component.find( "vfFrame" ).getElement().src= component.get("v.vfHost") + component.get("v.recipientPage");
    
                    }
                    //component.find( "vfFrame" ).getElement().src= component.get("v.vfHost") + component.get("v.recipientPage");
                    component.set("v.isSpin",false);
                }, false);
            }
        });
        $A.enqueueAction(action);
	},
    
    loadStates : function(component){
        component.set("v.isSpin",true);
    	var action = component.get("c.getStates");
        //alert(component.get("v.payment").country);
    	action.setParams({"countryCode" : component.get("v.payment").country});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var mapStates =  response.getReturnValue();
                var states = [];
                for(var key in mapStates){
                 	states.push({value:key, label:mapStates[key]});
                }
                component.set("v.stateOptions" , states);
            }
            component.set("v.isSpin",false);
        });
        $A.enqueueAction(action);
	}
    
})