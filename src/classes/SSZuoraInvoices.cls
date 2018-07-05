global class SSZuoraInvoices
{
   
   public static HttpRequest zuoraHeaderRequest(string strZuoraMetaDataName,string strAccountId)
   {
       
       Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,
       Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = : strZuoraMetaDataName];
       //= 'ZuoraGetInvoices'];                                                                
      
        HttpRequest req = new HttpRequest();
        req.setMethod(zuoraQueryCalloutConfig[0].HTTP_Method__c);
        req.setEndpoint(zuoraQueryCalloutConfig[0].Endpoint_URL__c+strAccountId);
        
        req.setHeader('content-type', 'application/json');
        req.setHeader('apiAccessKeyId', zuoraQueryCalloutConfig[0].Username__c);
        req.setHeader('apiSecretAccessKey', zuoraQueryCalloutConfig[0].Password__c);
        req.setHeader('zuora-version',zuoraQueryCalloutConfig[0].Version__c);
            
        return req;    
   }
   public static Boolean getZuoraInvoicesByAccount(string strAccountId)
   {
        
        // strAccountId can be Zuora Account number or account ID
            
        Http http = new Http();
       
        try {
            
             HTTPResponse res = null;
           
             res = http.send(zuoraHeaderRequest('ZuoraGetInvoices',strAccountId)); 
                
             string sZuoraResponse = res.getBody(); // Invoices are returned in reverse chronological order by updatedDate.
             
             system.debug('>>>>>>>json '+sZuoraResponse);
               
               // Deserialize the list of invoices from the JSON string.
                 sZuoraResponse = '[' + sZuoraResponse + ']';
                 
                 List<ZuoraInvoices> deserializedInvoices =

                (List<ZuoraInvoices>)JSON.deserialize(sZuoraResponse,List<ZuoraInvoices>.class);
                
                //System.debug('deserializedInvoices '+deserializedInvoices);
                
                
                for(ZuoraInvoices obj : deserializedInvoices)
                {
                    
                    System.debug('Main Data '+obj);
                    
                    for(ZuoraInvoices.Invoices inv : obj.invoices)
                    { 
                       
                       System.debug('Invoice Data '+inv);
                       
                        
                        for(ZuoraInvoices.InvoiceItems invItem : inv.invoiceItems)
                        {
                           System.debug('Invoice Item Data '+ invItem);
                        }
                        
                    
                    }
                 
                }
          
              }
            catch(System.CalloutException e){
            System.debug('Callout exception ' + e.getMessage());
            
          
  
           } 
          
     return true;
   }

}