public class ccPaypal {
    
    
    private String amount='500';
    public String access_token;
    public String tokenString;
    public String approval_link{get;set;}
    private String payment_id;
    public cacheObj cacheObjec;
    String cachedRate;
    
    String uname = 'AQr4I4_osNAv4EBGAobp4_01lzYnNE__E-6YDab4gdyP1OQCp6xeuHv8TsTyyhbdfswCHls8Rb7Snfph';
    String pwd = 'EMzhM0rNFyTtqpyvQ-3uLQMrs-J0pUaOuaYkN6q0aLTM9Zdfb7ThukPW95UspjtEoMARsMcLYP6-FgIm';
    
    
    
    public void paypalRedirect(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.sandbox.paypal.com/v1/oauth2/token');
        request.setMethod('POST');
        
        Blob headerValue = Blob.valueOf(uname + ':' + pwd);
        String authorizationHeader = 'Basic '+EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type','x-www-form-urlencoded'); 
        request.setBody('grant_type=client_credentials');
        HttpResponse response = http.send(request);
        
        System.debug('111 staus code '+response.getStatusCode());
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('111 result '+results);
            access_token = (String)results.get('access_token');
            System.debug('111 Access token '+access_token);
        }
        
        request.setEndpoint('https://api.sandbox.paypal.com/v1/payments/payment');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization','Bearer '+access_token);
        request.setBody('{"transactions": [{"amount": {"total":"'+amount+'","currency":"USD"}}],"payer": {"payment_method":"paypal"},"intent":"sale","redirect_urls": {"cancel_url":"https://ccrazedev-developer-edition.na78.force.com/Coke/ccrz__HomePage","return_url":"https://ccrazedev-developer-edition.na78.force.com/Coke/ccrz__HomePage"}}');
        HttpResponse resp = http.send(request);
        System.debug('111 In else '+resp.getBody());
        System.debug('111 In else '+resp.getStatusCode());
        if (resp.getStatusCode() == 201) {
            System.debug('111 In else '+resp.getBody());
            Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            System.debug('111 Result '+results);
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
        system.debug('payment_id : '+payment_id);
        
        /*
Cache.OrgPartition orgPart = Cache.Org.getPartition('local.myPartition');

cacheObjec.firstName = first_name;
cacheObjec.lastName = last_name;
cacheObjec.contactEmail = email;
cacheObjec.amount = recurring_donation;
cacheObjec.access_token = access_token;
String key=tokenString.substring(3);
System.debug('cacheObjec.firstName '+cacheObjec.firstName);


orgPart.put(key, '0.91');

if(Cache.Org.contains(key)){
System.debug('In if');
cachedRate = (String)orgPart.get('DollarToEuroRate');  
}

System.debug('cachedRate '+cachedRate);
System.debug('End');
}        

public void cacheClear()
{
tokenString=ApexPages.currentPage().getParameters().get('token');
if(tokenString != null)
{
String token=tokenString.substring(3);
if(Cache.Session.remove(token))
System.debug('Cache is removed');
else
System.debug('Cache is not removed');
}*/
        
    }   
}