public class ccPaypalController {
    
    
    @AuraEnabled
    public static String paypalRedirect(Integer amount,string cartId , String subscriptionItemId){
        
        system.debug('ccPaypalController - cartId : '+cartId);
        system.debug('ccPaypalController - subscriptionItemId : '+subscriptionItemId);
        //cartId='99ss';
        String relativeURL=site.getBaseUrl();
        String tokenString;
        String approval_link;
        String payment_id;
        String access_token;
        String uname = 'AQr4I4_osNAv4EBGAobp4_01lzYnNE__E-6YDab4gdyP1OQCp6xeuHv8TsTyyhbdfswCHls8Rb7Snfph';
        String pwd = 'EMzhM0rNFyTtqpyvQ-3uLQMrs-J0pUaOuaYkN6q0aLTM9Zdfb7ThukPW95UspjtEoMARsMcLYP6-FgIm';
        
        
        String cancel_url=relativeURL+'/s/cart-listing';
        String returnurl = '';
        if(subscriptionItemId != null){
        	returnurl = relativeURL +'/s/success?cartId='+cartId+'&subscriptionItemId='+subscriptionItemId;
        }
        else{
            returnurl = relativeURL +'/s/success?cartId='+cartId;
        }
        
        // List<Pay_Pal__mdt> val=[SELECT Client_ID__c,Secret__c FROM Pay_Pal__mdt]; 
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.sandbox.paypal.com/v1/oauth2/token');
        request.setMethod('POST');
        Blob headerValue = Blob.valueOf(uname + ':' + pwd);
        String authorizationHeader = 'Basic '+EncodingUtil.base64Encode(headerValue);
        
        // system.debug('val[0].Client_ID__c : '+val[0].Client_ID__c);
        //  system.debug('val[0].Secret__c : '+val[0].Secret__c);
        
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type','x-www-form-urlencoded'); 
        request.setBody('grant_type=client_credentials');
        HttpResponse response = http.send(request);
        
        System.debug('staus code '+response.getStatusCode());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('result '+results);
            access_token = (String)results.get('access_token');
            System.debug('Access token '+access_token);
        }
        
        
        request.setEndpoint('https://api.sandbox.paypal.com/v1/payments/payment');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization','Bearer '+access_token);
        request.setBody('{"transactions": [{"amount": {"total":"'+amount+'","currency":"USD"}}],"payer": {"payment_method":"paypal"},"intent":"sale","redirect_urls": {"cancel_url":"'+cancel_url+'","return_url":"'+returnurl+'"}}');
        HttpResponse resp = http.send(request);
        
        system.debug('resp 2 :'+resp.getStatusCode());
        
        if (resp.getStatusCode() == 201) {
            System.debug('In else '+resp.getBody());
            Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            System.debug('Result '+results);
            List<Object> result=(List<Object>)results.get('links');
            String payId=JSON.serialize(results.get('id'));
            
            payment_id=payId.substringBetween('\"','\"');
            for(Object obj:result) {
                String str=JSON.serialize(obj);
                if(str.contains('approval_url')){
                    approval_link=str.substringBetween('href\":\"','\"');
                    tokenString= str.substringBetween('token=','"}');
                }
            }
        }
        return approval_link;
    }        
}