({
    doInit : function(component, event, helper) {
        console.log('In bIlling cmp : '+component.get('v.storefrontName'));
        var CSJson='{ "paymentgateways": { "Active":"cybersource","cybersource": {  "username": "", "password": "", "serviceURL": "","merchantId":"","transactionkey": "", "billingengine":""}}}';
        component.set('v.CSJson',CSJson);
        
        var PPJson='{ "paymentgateways": { "Active":"paypal", "paypal": { "Client ID": "","Secret": "", "Token URL": "","service URL": "","signature": "", "billingengine":""}}}';
        component.set('v.PPJson',PPJson);
        
        var ZuoraJson='{ "paymentgateways": { "Active":"Zuora","Zuora": {  "username": "", "password": "", "serviceURL": "", "billingengine":""}}}';
        component.set('v.ZuoraJson',ZuoraJson);
        
        var CustomJson='{ "paymentgateways": { "Active": "Custom" }}';
        component.set('v.CustomJson',CustomJson);
        
        //  helper.getStorefront(component, event);
        if(component.get('v.storefrontName') !=''){
            helper.getBillingandPaymentConfig(component, event);
        }
    },
    
    onStorefrontSelected : function(component, event, helper) {
        var storefrontName=event.getParam("Storefrontname");
        console.log('storefrontName : '+storefrontName);
        if(storefrontName!=''){
            component.set('v.storefrontName',storefrontName);
            helper.getBillingandPaymentConfig(component, event);
        }
    },
    onclickSavebutton : function(component, event, helper) {
        helper.saveBillingandPaymentConfig(component, event);
    }
})