global class SSZuoraRequestsUtil {
      global static HttpRequest getZuoraRequestHeader(String zuoraServiceUrl, String userName, String password,String zuoraVersion,String httpMethod) {
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndpoint(zuoraServiceUrl);
        System.debug('Setting request header');  
        req.setHeader('content-type', 'application/json');
        req.setHeader('apiAccessKeyId', userName);
        req.setHeader('apiSecretAccessKey', password);
        req.setHeader('zuora-version',zuoraVersion);
        return req;        
    }
    
     global Static String getzuoraQueryRequestBody(String zQuery){
    JSONGenerator gen = JSON.createGenerator(true);    
	gen.writeStartObject();
    gen.writeStringField('queryString', zQuery);    
    gen.writeEndObject();                                                                   
    String jsonS = gen.getAsString();
    return jsonS;           
    }
    
   global static String getCreateSubscriptionRequestBody(String zuoraAccountId, DateTime subscriptionStartDate,String termType,Integer initialTerm,String termPeriodType,
                                                  Boolean autoRenew,List<SSZuoraUtil.ProductRatePlanJSON> productInfoLst) {
   JSONGenerator gen = JSON.createGenerator(true);    
	
  gen.writeStartObject(); 
  gen.writeStringField('termType',termType);                                                     
  If (termType.equalsIgnoreCase('termed')) {  //Zuora Has TERMED and EVERGREEN subscriptions. Define at the CC subscription Level?
  gen.writeNumberField('initialTerm',initialTerm);
  System.debug('termPeriodType'+termPeriodType.removeEnd('ly'));   
  gen.writeStringField('initialTermPeriodType',termPeriodType.removeEnd('ly'));
  gen.writeBooleanField('autoRenew', autoRenew);     
  If (autoRenew == false) {                                                                
  gen.writeNumberField('renewalTerm', 0);  
    } else{
  gen.writeNumberField('renewalTerm', initialTerm);
 }
 gen.writeStringField('renewalTermPeriodType',termPeriodType.removeEnd('ly'));    
  } 
  gen.writeDateTimeField('contractEffectiveDate', subscriptionStartDate); 
  gen.writeStringField('accountKey', zuoraAccountId);                                                     
  gen.writeStringField('notes', 'Test Subscription');
  gen.writeObjectField('subscribeToRatePlans',productInfoLst);//have to fetch the Product Info                                                					                                                              
  gen.writeBooleanField('invoice',false);                                                                 
  gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  return jsonS;                                           
      }
    
    global static String getCreateAccountRequestBody(SSAccountModel account, SSContactModel contact, String currencyCode, String locale, String paymentReferenceID,
                                                             SSPaymentDetailsModel paymentDetails) {
       System.debug('#####account details in Zuora Request Util'+account);                           
    JSONGenerator gen = JSON.createGenerator(true);    
	
	gen.writeStartObject();      
	gen.writeStringField('name', account.accountName);
    gen.writeStringField('crmId', account.accountId);                                                               
	gen.writeStringField('currency', currencyCode);
    gen.writeNumberField('billCycleDay', 0);
    gen.writeBooleanField('autoPay', true); 
    gen.writeStringField('batch', 'Batch1'); 
    gen.writeStringField('paymentTerm','Due Upon Receipt'); 
  //gen.writeStringField('invoiceTemplateId',''); //If not passed will be deafulted to Zuora Invoice Template
  //gen.writeStringField ('communicationProfileId',''); //If not passed will be deafulted to Zuora Invoice Template                                                            
  //gen.writeStringField('taxCompanyCode',taxCompanyCode); // Needs to be passed as input parameter
  //gen.writeStringField('taxExemptStatus','Yes');  //  get it from the cartModel                                                         
  //gen.writeStringField('taxExemptCertificateID', vatNumber); get it from the cartModel//when flowVars.accountResponse.vatNumber == null otherwise flowVars.accountResponse.vatNumber
 // gen.writeStringField('VATId',vatNumber);// when flowVars.accountResponse.vatNumber == null otherwise flowVars.accountResponse.vatNumber,                                                                                                                                                                                  
  gen.writeFieldName('billToContact');
  gen.writeStartObject();
   gen.writeStringField('address1',contact.address.streetAddress);                                                               
  gen.writeStringField('city', contact.address.city);
  gen.writeStringField('country', contact.address.country);
  gen.writeStringField('firstName', contact.firstName);
  gen.writeStringField('lastName', contact.lastName);
  if  (!String.IsBlank(contact.address.state)) {                                                            
  gen.writeStringField('state', contact.address.state);
      }
  gen.writeStringField('zipCode', contact.address.postalCode);
  gen.writeStringField('workEmail', contact.email);
  If (!String.IsBlank(contact.phone)){                                                              
  gen.writeStringField('workPhone', contact.phone);  
   }
 // gen.writeStringField('county', ''); 						                                                              
  gen.writeEndObject(); 
 // Optional SoldToContact                                                                  
  gen.writeFieldName('soldToContact');
  gen.writeStartObject();
  gen.writeStringField('address1',contact.address.streetAddress);
  gen.writeStringField('city', contact.address.city);
  gen.writeStringField('country', contact.address.country);  
 gen.writeStringField('firstName', contact.firstName);
  gen.writeStringField('lastName', contact.lastName);
    if  (!String.IsBlank(contact.address.state)) {                                                               
  gen.writeStringField('state', contact.address.state);
    }
  gen.writeStringField('zipCode', contact.address.postalCode);
  gen.writeStringField('workEmail', contact.email); 
  If (!String.IsBlank(contact.phone)){                                                                 
  gen.writeStringField('workPhone', contact.phone);
  }
  gen.writeEndObject();                                                                 
 // gen.writeStringField('county', ''); 
  if (!String.IsBlank(paymentReferenceID)) {
  gen.writeStringField('hpmCreditCardPaymentMethodId', paymentReferenceID);    
  }	
  else {                                                                  
  gen.writeFieldName('creditCard');
  gen.writeStartObject(); 
  gen.writeStringField('cardType', paymentDetails.cardType);
  gen.writeNumberField('expirationMonth',paymentDetails.expirationMonth);
  gen.writeStringField('securityCode',paymentDetails.securityCode);
  gen.writeStringField('cardNumber',paymentDetails.cardNumber);                                                                 
  gen.writeNumberField('expirationYear',paymentDetails.expirationYear);
  //Optional CardHolder Info, If not Provide takes the billTo Contact                                                                 
  gen.writeFieldName('cardHolderInfo');
  gen.writeStartObject();
 gen.writeStringField('cardHolderName',paymentDetails.cardHolderName);
  gen.writeStringField('addressLine1',paymentDetails.street); 
  //gen.writeStringField('addressLine2', '');                                                                 
  gen.writeStringField('city', paymentDetails.city);
  gen.writeStringField('state', paymentDetails.state);
  gen.writeStringField('zipCode', paymentDetails.postalCode);                                                                 
  gen.writeStringField('country', paymentDetails.country);
    If (!String.IsBlank(paymentDetails.email)){     
  gen.writeStringField('email', paymentDetails.email); 
    }
  If (!String.IsBlank(paymentDetails.phone)){      
  gen.writeStringField('phone', paymentDetails.phone); 
  }
  gen.writeEndObject();   
  gen.writeEndObject();
  }                                                                
  gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  System.debug('Create Account Request Body'+jsonS);                                                               
  return jsonS;                                                                 
    } 
    
global static String getCancelSubscriptionRequestBody(String cancellationPolicy,DateTime cancellationDate){
    JSONGenerator gen = JSON.createGenerator(true);    
	gen.writeStartObject();
        If (cancellationPolicy.equalsIgnoreCase('EndOfLastInvoicePeriod')){
      gen.writeStringField('cancellationPolicy', 'EndOfLastInvoicePeriod'); 
      gen.writeBooleanField('invoice', false);          
            } else If(cancellationPolicy.equalsIgnoreCase('SpecificDate')) {
     gen.writeStringField('cancellationPolicy','SpecificDate' );
     gen.writeDateField('cancellationEffectiveDate', System.today());
     gen.writeBooleanField('invoice', false);     
        }
    gen.writeEndObject();                                                                   
    String jsonS = gen.getAsString();
    return jsonS;           
    }  
    
  global static String getRegradeSubscriptionRequestBody(String termType,Integer initialTerm,String termPeriodType,
                                                  Boolean autoRenew,List<SSZuoraRegradeUtil.ProductRegradeRatePlanJSON> productInfoLst,List<SSZuoraRegradeUtil.RatePlanJSON> ratePlanInfoLst) {
   JSONGenerator gen = JSON.createGenerator(true);    
	
  gen.writeStartObject(); 
  gen.writeStringField('termType',termType);                                                     
  If (termType.equalsIgnoreCase('termed')) {  //Zuora Has TERMED and EVERGREEN subscriptions. Define at the CC subscription Level?
  gen.writeNumberField('initialTerm',initialTerm);
  System.debug('termPeriodType'+termPeriodType.removeEnd('ly'));   
  gen.writeStringField('initialTermPeriodType',termPeriodType.removeEnd('ly'));
  gen.writeBooleanField('autoRenew', autoRenew);     
  If (autoRenew == false) {                                                                
  gen.writeNumberField('renewalTerm', 0);  
    } else{
  gen.writeNumberField('renewalTerm', initialTerm);
 }
 gen.writeStringField('renewalTermPeriodType',termPeriodType.removeEnd('ly'));    
  } 
 // gen.writeDateTimeField('contractEffectiveDate', subscriptionStartDate); 
 // gen.writeStringField('accountKey', zuoraAccountId);                                                     
  gen.writeStringField('notes', 'Upgraded Subscription'); //Do we need this? 
  gen.writeObjectField('add',productInfoLst);//have to fetch the Product Info  
  gen.writeObjectField('remove',ratePlanInfoLst);                                                    
  gen.writeBooleanField('invoice',false);                                                                 
  gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  return jsonS;                                           
      }


    
  global Static String generateInvoicesRequestBody(String billingAccountId)
  { 
      JSONGenerator gen = JSON.createGenerator(true);    
	
  gen.writeStartObject(); 
  gen.writeStringField('accountKey',billingAccountId); 
   gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  return jsonS;          
  }
    

}