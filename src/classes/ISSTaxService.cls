/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Interface to Calculate tax.
*

*/
global interface ISSTaxService
{
   
   double calculateTax(String cartId, String taxCode,Decimal subTotal,
   String vatNumber,SSAddressModel billingAddress);
   
  
   
}