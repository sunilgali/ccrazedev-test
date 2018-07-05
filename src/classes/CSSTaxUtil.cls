/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Util to Make a Avalara Rest Call and the Tax.
*

*/
global class CSSTaxUtil {
    
    global static CSSTaxModel calculateTax(String taxServiceUrl, String userName, String password, 
                       String companyCode, String customerCode, String taxCode, 
                       Decimal amount, String postalCode, String country) {
                           
        HttpRequest req = CSSTaxUtil.getTaxServiceRequestHeader(taxServiceUrl, userName, password);
        String body = CSSTaxUtil.getTaxServiceRequestBody( companyCode,  customerCode,  taxCode, 
                        amount,  postalCode,  country);
        req.setBody(body); 
        System.debug('Setting request body' + body);
        CSSTaxModel tax = new CSSTaxModel();
                           
        Http http = new Http();
        try {
            HTTPResponse res = null;
            if (!Test.isRunningtest())
                {
                    res = http.send(req); 
                }else{
                    res = new HTTPResponse();
                    Integer statusCode = 201;
                    res.setBody('{"totalTaxable":10.0,"rate":2.0,"totalTax":2.0,"country":"GB"}');
                    res.setStatus('Success');
                    res.setStatusCode(statusCode);
                }  
            System.debug('STATUS_CODE:'+res.getStatusCode());
            System.debug('Response body ' + res.getBody());
            Integer statusCode = res.getStatusCode();
            if (statusCode == 201) {
                String avaResponse = res.getBody();
                JSONParser parser = JSON.createParser(avaResponse);
                 while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('totalTaxable')) {
                            tax.taxableAmount = Decimal.valueOf(tokenValue);
                         }
                         if (tokenName.equals('rate')) {
                            tax.taxRate = Decimal.valueOf(tokenValue);
                         }
                         if (tokenName.equals('totalTax')) {
                            tax.taxAmount = Decimal.valueOf(tokenValue);
                         }
                         if (tokenName.equals('country')) {
                            tax.country = tokenValue;
                         }
                     }
                }
            }
            else {
                System.debug('Error retrieving Tax ' + statusCode);
                System.debug('Error retrieving Tax response ' + res.getBody());
                throw new CSSTaxException(SSTaxException.EXCEPTION_TAX_SERVICE_ERROR);
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new CSSTaxException(SSTaxException.EXCEPTION_TAX_CALLOUT);
        }  
                           /*
        if ((tax.taxableAmount != null) && (tax.taxAmount != null)) {
            tax.totalAmount = tax.taxAmount + tax.taxableAmount;                                              
        }
*/
        return tax;
    }
    
    global static HttpRequest getTaxServiceRequestHeader(String taxServiceUrl, String userName, String password) {
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('Setting auth header ' + authorizationHeader);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(taxServiceUrl);
        System.debug('Setting request header');      
        req.setHeader('Authorization', authorizationHeader);
        return req;        
    }
    
    public static String getTaxServiceRequestBody(String companyCode, String customerCode, String taxCode, 
                       Decimal amount, String postalCode, String country) {
        String body = '';
        body += '{  ';   
        body += '"businessIdentificationNo":"", '; 
        body += '"companyCode": "' + companyCode + '",   ';
        body += '"date":"' +  System.now() + '",    ';
        body += '"customerCode": "' + customerCode + '",   ';
        body += '"lines":   [       ';
        body += '       {    ';
        body += '           "taxCode" :"' + taxCode + '",';   
        body += '           "quantity": 1,    ';
        body += '           "amount": ' + amount;
        body += '       }       ';
        body += '   ],     ';
        body += '"addresses":  {            ';
        body += '   "singleLocation": {            ';
        body += '       "country": "' + country + '"';
        if (!String.isBlank(postalCode)) {
            body += '       ,"postalCode": "' + postalCode + '"';                        
        }
        body += '   }     ';
        body += '}      ';
        body += '}';
        return body;
    }

}