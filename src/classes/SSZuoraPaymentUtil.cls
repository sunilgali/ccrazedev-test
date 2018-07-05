global class SSZuoraPaymentUtil {
    
    //pageType=Credit Card
   	//pageType=ACH

   	@RemoteAction
    global static SSPaymentModel fetchPaymentMethods(String paymentMethod)
    {
        return createZuoraHostedPaymentPageToken(paymentMethod);
    }
    
    global static SSPaymentModel createZuoraHostedPaymentPageToken(String paymentMethod) {
        SSPaymentModel hostedPaymentModel;
        try {
            List<SSZuoraPaymentUtil.Hostedpages>  lstHostedPageId = retriveHostedPaymentPageIds();
            for(SSZuoraPaymentUtil.Hostedpages hostedPage : lstHostedPageId)
            {
                if(hostedPage.pageType!=null && hostedPage.pageType.equalsignorecase(paymentMethod))
                {
                    hostedPaymentModel = generatePaymentToken(hostedPage.pageId);
                }
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
      	system.debug('--------hostedPaymentModel--------'+hostedPaymentModel);
      	return hostedPaymentModel;                                                                   
    }
    
    global static SSPaymentModel generatePaymentToken(String pageId){

        SSPaymentModel paymentModelConfig = new SSPaymentModel();
        try
        {
            Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, 
                                                                Username__c,Password__c, HTTP_Method__c,Content_Type__c,
                                                                Version__c,OAuth_Endpoint_URL__c FROM Callout_Configuration__mdt 
                                                               	where QualifiedApiName = 'ZuoraPaymentPageToken'];                                                                

      		HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, 
                                                                    zuoraQueryCalloutConfig[0].Username__c, 
                                                                    zuoraQueryCalloutConfig[0].Password__c,
                                                                    zuoraQueryCalloutConfig[0].Version__c,
                                                                    zuoraQueryCalloutConfig[0].HTTP_Method__c);
        	String body = createPaymentRequestBody(pageId,zuoraQueryCalloutConfig[0].OAuth_Endpoint_URL__c,
                                                   zuoraQueryCalloutConfig[0].HTTP_Method__c);  
     		System.debug('body'+body);                                              
      		req.setBody(body); 
            
      		Http http = new Http();
            HTTPResponse res = null;
            if (!Test.isRunningtest())
            {
                res = http.send(req); 
         	}else{
                
            }
            Integer statusCode = res.getStatusCode();
           	System.debug('statusCode'+statusCode);
            if (statusCode == 200) 
            {
                Map<String,Object> mapJsonParsed = (Map<String,Object>)Json.deserializeUntyped(res.getBody());
                system.debug('------mapJsonParsed-----'+mapJsonParsed);
                if(mapJsonParsed!=null)
                {
                    paymentModelConfig.zTenantID = (String)mapJsonParsed.get('tenantId');
                    paymentModelConfig.zSignature = (String)mapJsonParsed.get('signature');
                    paymentModelConfig.zToken = (String)mapJsonParsed.get('token');
                    paymentModelConfig.zKey = (String)mapJsonParsed.get('key');
                    paymentModelConfig.zURL = zuoraQueryCalloutConfig[0].OAuth_Endpoint_URL__c;
                    paymentModelConfig.paymentPageId = pageId;
				}
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
        system.debug('-------paymentModelConfig------'+paymentModelConfig);
        return paymentModelConfig;
    }
    
    global static List<SSZuoraPaymentUtil.Hostedpages> retriveHostedPaymentPageIds() {
        List<SSZuoraPaymentUtil.Hostedpages> lstHostedPagesObject = new List<SSZuoraPaymentUtil.Hostedpages>();
        try {
     		Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, 
                                                                Username__c,Password__c, HTTP_Method__c,Content_Type__c,
                                                                Version__c FROM Callout_Configuration__mdt where 
                                                                QualifiedApiName = 'ZuoraHostedPaymentPages'];                                                                

      		HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, 
                                                                    zuoraQueryCalloutConfig[0].Username__c, 
                                                                    zuoraQueryCalloutConfig[0].Password__c,
                                                                    zuoraQueryCalloutConfig[0].Version__c,
                                                                    zuoraQueryCalloutConfig[0].HTTP_Method__c);
      		Http http = new Http();
            HTTPResponse res = null;
            if (!Test.isRunningtest())
            {
                res = http.send(req); 
         	}else{
                
            }  
            Integer statusCode = res.getStatusCode();
           	System.debug('statusCode'+statusCode);
            if (statusCode == 200) {
                Map<String,Object> mapJsonParsed = (Map<String,Object>)Json.deserializeUntyped(res.getBody());
                system.debug('------mapJsonParsed-----'+mapJsonParsed);
                if(mapJsonParsed!=null)
                {
                    for(Object obj : mapJsonParsed.values())
                    {
                        system.debug('------obj-----'+obj);
                        if(obj instanceof List<Object>)
                        {
                            system.debug('------came inside -----');
                            List<Object> lstData = (List<Object>)obj;
                            system.debug('------came lstData -----'+lstData);
                            if(lstData!=null && lstData.size()>0)
                            {
                                for(Object objMap : lstData )
                                {
                                    Map<String,Object> mp_StrObj = (Map<string,Object>)objMap;
                                    SSZuoraPaymentUtil.Hostedpages hostedPageModel = new SSZuoraPaymentUtil.Hostedpages();
                                    hostedPageModel.pageId = (String)mp_StrObj.get('pageId');
                                    hostedPageModel.pageName = (String)mp_StrObj.get('pageName');
                                    hostedPageModel.pageType = (String)mp_StrObj.get('pageType');
                                    hostedPageModel.pageVersion = (Double)mp_StrObj.get('pageVersion');
                                    system.debug('>>>>>>>>>>>>'+mp_StrObj.get('pageId'));
                                    system.debug('>>>>>>>>>>>>'+ mp_StrObj.get('pageName'));
                                    system.debug('>>>>>>>>>>>>'+ mp_StrObj.get('pageVersion'));
                                    lstHostedPagesObject.add(hostedPageModel);
                                }
                            }
                    	}
                    }
				}
            } 
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
         	throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
      	System.debug('lstHostedPagesObject>>>>>>>>>>'+lstHostedPagesObject) ;                                                        
      	return lstHostedPagesObject;                                                                   
    }
    
    global static String createPaymentRequestBody(String pageId, String uri,String method) {
   		JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject(); 
  		gen.writeStringField('pageId',pageId);
        gen.writeStringField('uri',uri);  
        gen.writeStringField('method',method);                       
  		gen.writeEndObject();                                                                   
  		String jsonS = gen.getAsString();
  		return jsonS;                                           
      }
    
    global List<Hostedpages> hostedpages;
	global Boolean success;
    
	global class Hostedpages {
        global String pageId{set;get;}
		global String pageName{set;get;}
		global String pageType{set;get;}
		global Double pageVersion{set;get;}
	}
}