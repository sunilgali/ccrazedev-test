/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Implementation class to Calculatetax.
*

*/
global class CCSSAvalaraImpl implements ISSTaxService { 

                       
global double calculateTax(String cartId,String taxCode,Decimal subTotal,
   String vatNumber,SSAddressModel billingAddress){
   
   Double taxAmount = 0;
    
   
   system.debug('>>>>>>> Inside Imlp Class');
   
   
   SSTaxModel tax = new SSTaxModel();
   
   Callout_Configuration__mdt[] avaCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Company_Code__c,Customer_Code__c FROM Callout_Configuration__mdt where QualifiedApiName = : Label.TaxService];
   
   if(!avaCalloutConfig.IsEmpty())
   {
   
     tax = SSTaxUtil.calculateTax(avaCalloutConfig[0].Endpoint_URL__c, avaCalloutConfig[0].Username__c, avaCalloutConfig[0].Password__c, 
     avaCalloutConfig[0].Company_Code__c,billingAddress.country,avaCalloutConfig[0].Customer_Code__c,subTotal,billingAddress.postalCode,billingAddress.country);
      
   }   
   
   system.debug('>>>>>>>'+tax);
   
   system.debug('>>>>>>>'+tax.taxAmount);
    
   return tax.taxAmount;
   }

}