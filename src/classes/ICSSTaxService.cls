global interface ICSSTaxService
{
   double calculateTax(String taxCode, Decimal subTotal, CSSAddressModel billingAddress);
}