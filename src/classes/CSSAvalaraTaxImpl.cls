global class CSSAvalaraTaxImpl  implements ICSSTaxService { 

                       
	global double calculateTax(String taxCode, Decimal subTotal, CSSAddressModel billingAddress){
   
   		Double taxAmount = 0;
   		System.debug('CSSAvalaraTaxImpl: calculateTax: enter');
   		CSSTaxModel tax = new CSSTaxModel();
   
       Callout_Configuration__mdt[] avaCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
       , Content_Type__c,Company_Code__c,Customer_Code__c FROM Callout_Configuration__mdt where QualifiedApiName = : Label.TaxService];
   
   		if(!avaCalloutConfig.IsEmpty())
   		{
     		tax = CSSTaxUtil.calculateTax(avaCalloutConfig[0].Endpoint_URL__c, avaCalloutConfig[0].Username__c, avaCalloutConfig[0].Password__c, 
		     avaCalloutConfig[0].Company_Code__c,billingAddress.country,avaCalloutConfig[0].Customer_Code__c,subTotal,billingAddress.postalCode,billingAddress.country);
   		}   
   
   		System.debug('CSSAvalaraTaxImpl: calculateTax: tax ' + tax);
   		System.debug('CSSAvalaraTaxImpl: calculateTax: taxAmount ' + tax.taxAmount);
   		return tax.taxAmount;
   }

}