({
    doInit : function(component, event, helper) {
        
        var url_string = window.location.href;
        var url = new URL(url_string);
        
        component.set('v.PayerID',url.searchParams.get("PayerID"));
        component.set('v.paymentId',url.searchParams.get("paymentId"));
        component.set('v.token',url.searchParams.get("token"));
        component.set('v.cartId',url.searchParams.get("cartId"));
    }
})