public class jstring
{

   public static string jsonstring()
   {
      string strfinal = '';
      
     strfinal += '{';
  strfinal += '"clientReferenceInformation": { ';
   strfinal += ' "code": "TC50171_3"';
 strfinal += ' },';
  strfinal += '"processingInformation": {';
 strfinal += '   "commerceIndicator": "internet" ';
  strfinal += '},';
  strfinal += '"aggregatorInformation": {';
   strfinal += ' "subMerchant": {';
   strfinal += '   "cardAcceptorID": "1234567890",';
   strfinal += '   "country": "US",';
   strfinal += '   "phoneNumber": "650-432-0000",';
   strfinal += '   "address1": "900 Metro Center",';
   strfinal += '   "postalCode": "94404-2775",';
   strfinal += '   "locality": "Foster City",';
     strfinal += ' "name": "Visa Inc",';
   strfinal += '   "administrativeArea": "CA",';
    strfinal += '  "region": "PEN",';
   strfinal += '   "email": "test@cybs.com"';
   strfinal += ' },';
   strfinal += ' "name": "V-Internatio",';
   strfinal += ' "aggregatorID": "123456789"';
  strfinal += '},';
  strfinal += '"orderInformation": {';
    strfinal += '"billTo": {';
   strfinal += '   "country": "US",';
   strfinal += '   "lastName": "VDP",';
   strfinal += '   "address2": "Address 2",';
   strfinal += '   "address1": "201 S. Division St.",';
      strfinal += '"postalCode": "48104-2201",';
    strfinal += '  "locality": "Ann Arbor",';
    strfinal += '  "administrativeArea": "MI",';
    strfinal += '  "firstName": "RTS",';
     strfinal += ' "phoneNumber": "999999999",';
   strfinal += '   "district": "MI",';
    strfinal += '  "buildingNumber": "123",';
    strfinal += '  "company": "Visa",';
    strfinal += '  "email": "test@cybs.com"';
   strfinal += ' },';
   strfinal += ' "amountDetails": {';
    strfinal += '  "totalAmount": "102.21",';
    strfinal += '  "currency": "USD"';
    strfinal += '}';
  strfinal += '},';
  strfinal += '"paymentInformation": {';
  strfinal += '  "card": {';
  strfinal += '    "expirationYear": "2031",';
  strfinal += '    "number": "5555555555554444",';
  strfinal += '    "securityCode": "123",';
  strfinal += '    "expirationMonth": "12",';
  strfinal += '    "type": "002"';
  strfinal += '  }';
  strfinal += '}';
strfinal += '}';
      
      return strfinal;
   }
}