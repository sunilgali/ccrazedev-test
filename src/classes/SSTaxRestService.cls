@RestResource(urlMapping='/SSTaxRestService')
global class SSTaxRestService {



     @Httppost
     global static Decimal applyTax(String cartId, String taxCode,String vatNumber,SSAddressModel billingAddress){

      Decimal amount = 0.0;
      
      try
      {
       amount = SSCartHelper.applyTax(cartId,taxCode,vatNumber,billingAddress);
      }
      catch (Exception ex) {
       
      }
      return amount;
   }
}