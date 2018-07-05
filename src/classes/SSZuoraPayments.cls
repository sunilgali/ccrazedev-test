global class SSZuoraPayments
{

   public static Boolean getZuoraPaymentsByAccount(string strAccountId)
   {
        //ZuoraGetPayments   
        // strAccountId can be Zuora Account number or account ID
            
        Http http = new Http();
       
       try {
                  HTTPResponse res = null;
            
                  res = http.send(SSZuoraInvoices.zuoraHeaderRequest('ZuoraGetPayments',strAccountId)); // Payments are returned in reverse chronological order by updatedDate.
                
                  string strZuoraResponse = res.getBody();
                
                  system.debug('>>>>>>>json'+strZuoraResponse);
               
               
               // Deserialize the list of invoices from the JSON string.
                 strZuoraResponse = '[' + strZuoraResponse + ']';
                 List<ZuoraPayments> deserializedPayments =

                (List<ZuoraPayments>)JSON.deserialize(strZuoraResponse,List<ZuoraPayments>.class);
                
                System.debug('deserializedPayments '+deserializedPayments);
                
                 
                for(ZuoraPayments obj : deserializedPayments)
                {
                    
                    System.debug('Main Data '+obj);
                    
                    for(ZuoraPayments.payments inv : obj.payments)
                    { 
                       
                       System.debug('Payments '+inv);
                       
                        
                        for(ZuoraPayments.paidInvoices invItem : inv.paidInvoices)
                        {
                           System.debug('Paid Invoice Data '+ invItem);
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