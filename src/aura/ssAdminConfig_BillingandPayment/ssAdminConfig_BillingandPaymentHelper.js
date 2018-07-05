({
    getBillingandPaymentConfig : function(component, event) {
        console.log(component.get('v.storefrontName'));
        var action = component.get("c.getBillingandPymentConfig");
        action.setParams({ 
            storeFront  : component.get('v.storefrontName'),
            configId    : component.get('v.configId')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               if (state === "SUCCESS") 
                               {
                                   if(result.new == 'new'){
                                       console.log('in new');
                                   }
                                   else
                                   {
                                       console.log('in result :'+JSON.stringify(result));
                                       component.set('v.configId',result.Id);
                                       var BillingJson=result.Storefront_Config_JSON__c;
                                       component.set('v.BilingPymentJson',BillingJson);
                                       this.populateConfig(component, event,BillingJson);
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in getting getTaxConfig:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    populateConfig : function(component, event,BillingJson) {
        BillingJson=JSON.parse(BillingJson);
        BillingJson=BillingJson.paymentgateways;
        
        var active=BillingJson.Active;
        console.log('active :'+active);
        if(active == 'Zuora'){
            var ZuoraConfig=BillingJson.Zuora; 
            component.set('v.BillingengineValue',ZuoraConfig.billingengine);
            component.set('v.PaymentGatewayValue','Zuora payment pages');
            component.set('v.ZuoraServiceURL',ZuoraConfig.serviceURL);
            component.set('v.ZuoraUsername',ZuoraConfig.username);
            component.set('v.ZuoraPassword',ZuoraConfig.password);
        }
        else if(active == 'cybersource'){
            var cybersourceConfig=BillingJson.cybersource; 
            component.set('v.BillingengineValue',cybersourceConfig.billingengine);
            component.set('v.PaymentGatewayValue','Cyber Source');
            component.set('v.CSusername',cybersourceConfig.username);
            component.set('v.CSpassword',cybersourceConfig.password);
            component.set('v.CSserviceURL',cybersourceConfig.serviceURL);
            component.set('v.CSmerchantId',cybersourceConfig.merchantId);
            component.set('v.CStransactionkey',cybersourceConfig.transactionkey);
        }
            else if(active == 'paypal'){
                var paypalConfig=BillingJson.paypal; 
                component.set('v.BillingengineValue',paypalConfig.billingengine);
                component.set('v.PaymentGatewayValue','Paypal');
                component.set('v.PPClientID',paypalConfig['Client ID']);
                component.set('v.PPSecret',paypalConfig.Secret);
                component.set('v.PPTokenURL',paypalConfig['Token URL']);
                component.set('v.PPserviceURL',paypalConfig['service URL']);
                component.set('v.ppsignature',paypalConfig.signature);
            }
                else{
                    
                }
        
    },
    saveBillingandPaymentConfig : function(component, event) {
        var PaymentGatewayValue=component.get('v.PaymentGatewayValue');
        var billingengine=component.get('v.BillingengineValue');
        
        if(PaymentGatewayValue =='Cyber Source'){
            
            var allValid = this.isComponentValid(component.find("CSusername"))
            && this.isComponentValid(component.find("CSpassword"))
            && this.isComponentValid(component.find("CSserviceURL"))  
            && this.isComponentValid(component.find("CSmerchantId"))
            && this.isComponentValid(component.find("CStransactionkey"))
            && this.isComponentValid(component.find("BillingengineValue"))
            console.log(allValid);
            
            if(allValid){
                
                var CSusername       =component.get('v.CSusername');
                var CSpassword       =component.get('v.CSpassword');
                var CSserviceURL     =component.get('v.CSserviceURL');
                var CSmerchantId     =component.get('v.CSmerchantId');
                var CStransactionkey =component.get('v.CStransactionkey');
                
                //Copy values to temp
                var Json=JSON.parse(component.get('v.CSJson'));
                var CSJsontemp=Json.paymentgateways;
                var CSJsontemp2=CSJsontemp.cybersource;
                
                console.log(CSJsontemp2);
                
                //Copy values 
                CSJsontemp2.username = CSusername;
                CSJsontemp2.password  = CSpassword;
                CSJsontemp2.serviceURL  = CSserviceURL;
                CSJsontemp2.merchantId  = CSmerchantId;
                CSJsontemp2.transactionkey  = CStransactionkey;
                CSJsontemp2.billingengine  = billingengine;
                
                
                //copy back new values from temp
                CSJsontemp.cybersource=CSJsontemp2;
                Json.paymentgateways=CSJsontemp;
                Json=JSON.stringify(Json);
                this.save(component, event,Json);
            }
        }
        
        else if(PaymentGatewayValue =='Paypal'){
            
            var allValid = this.isComponentValid(component.find("PPClientID"))
            && this.isComponentValid(component.find("PPSecret"))
            && this.isComponentValid(component.find("PPTokenURL"))
            && this.isComponentValid(component.find("PPserviceURL"))   
            && this.isComponentValid(component.find("ppsignature"))   
            && this.isComponentValid(component.find("BillingengineValue"))
            console.log(allValid);
            
            if(allValid){
                
                var PPClientID    = component.get('v.PPClientID');
                var PPSecret      = component.get('v.PPSecret');
                var PPTokenURL    = component.get('v.PPTokenURL');
                var PPserviceURL  = component.get('v.PPserviceURL');
                var ppsignature   = component.get('v.ppsignature');
                
                //Copy values to temp
                var Json=JSON.parse(component.get('v.PPJson'));
                var PPJsontemp=Json.paymentgateways;
                var PPJsontemp2=PPJsontemp.paypal;
                
                //Copy values 
                PPJsontemp2['Client ID']  = PPClientID;
                PPJsontemp2.Secret        = PPSecret;
                PPJsontemp2['Token URL']  = PPTokenURL;
                PPJsontemp2['service URL']= PPserviceURL;
                PPJsontemp2.signature     = ppsignature;
                PPJsontemp2.billingengine     = billingengine;
                
                //copy back new values from temp
                PPJsontemp.paypal=PPJsontemp2;
                Json.paymentgateways=PPJsontemp;
                Json=JSON.stringify(Json);
                console.log('PPJson :'+Json);
                this.save(component, event,Json);
            }
        }
            else if(PaymentGatewayValue =='Zuora payment pages'){
                
                var allValid = this.isComponentValid(component.find("ZuoraServiceURL"))
                && this.isComponentValid(component.find("ZuoraUsername"))
                && this.isComponentValid(component.find("ZuoraPassword"))
                && this.isComponentValid(component.find("BillingengineValue"))
                console.log(allValid);
                
                if(allValid){
                    var ZuoraServiceURL  = component.get('v.ZuoraServiceURL');
                    var ZuoraUsername    = component.get('v.ZuoraUsername');
                    var ZuoraPassword    = component.get('v.ZuoraPassword');
                    
                    //Copy values to temp
                    var Json=JSON.parse(component.get('v.ZuoraJson'));
                    var ZuoraJsontemp=Json.paymentgateways;
                    var ZuoraJsontemp2=ZuoraJsontemp.Zuora;
                    
                    //Copy values 
                    ZuoraJsontemp2.username      = ZuoraUsername;
                    ZuoraJsontemp2.password    = ZuoraPassword;
                    ZuoraJsontemp2.serviceURL   = ZuoraServiceURL;
                    ZuoraJsontemp2.billingengine     = billingengine;
                    
                    //copy back new values from temp
                    ZuoraJsontemp.Zuora=ZuoraJsontemp2;
                    Json.paymentgateways=ZuoraJsontemp;
                    Json=JSON.stringify(Json);
                    console.log('PPJson :'+Json);
                    this.save(component, event,Json); 
                }
            }
    },
    save : function(component, event, Json) {
        var action = component.get("c.saveBillingandPymentConfig");
        action.setParams({ 
            storeFront : component.get('v.storefrontName'),
            BillingJson       : Json,
            configId   : component.get('v.configId')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue()
                               if (state === "SUCCESS") 
                               {
                                   if(result==true) {
                                       component.set('v.Banner',true);
                                       
                                       setTimeout(
                                           $A.getCallback(function() {
                                               $A.get('e.force:refreshView').fire();
                                           }), 1500
                                       );
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in saving Config:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
        
    },
    isComponentValid : function(cmp){
        cmp.showHelpMessageIfInvalid();
        console.log('in isComponentValid :'+cmp.get('v.validity').valid)
        return cmp.get('v.validity').valid;
        
    },
    
})