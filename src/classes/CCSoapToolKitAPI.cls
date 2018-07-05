global class CCSoapToolKitAPI{
    
    global static String getCCSoapXMLBody(Map<String, String> params){ 
    
        string strxml ='';
        strxml +=  '<?xml version="1.0" encoding="UTF-8"?>';
        strxml +=  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        strxml +=  '<soapenv:Header>';
        strxml +=  '  <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        strxml +=  '   <wsse:UsernameToken>';
        strxml +=  '     <wsse:Username>'+params.get('userName')+'</wsse:Username>';
        strxml +=  '     <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+params.get('password')+'</wsse:Password>';
        strxml +=  '   </wsse:UsernameToken>';
        strxml +=  ' </wsse:Security>';
        strxml +=  ' </soapenv:Header>';
        strxml +=  '<soapenv:Body>';
        strxml +=  '  <requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.129">';
        strxml +=  '    <merchantID>'+ params.get('merchantId') + '</merchantID>';
        strxml +=  '   <merchantReferenceCode>'+ params.get('mRefernceCode') +'</merchantReferenceCode>';
        strxml +=  '  <billTo>';
        strxml +=  '  <firstName>'+params.get('firstName')+'</firstName>';
        strxml +=  '  <lastName>'+params.get('lastName')+'</lastName>';
        strxml +=  ' <street1>'+params.get('street')+'</street1>';
        strxml +=  '  <city>'+params.get('city')+'</city>';
        strxml +=  '  <state>'+params.get('state')+'</state>';
        strxml +=  '  <postalCode>'+params.get('postalCode')+'</postalCode>';
        strxml +=  ' <country>'+params.get('country')+'</country>';
        strxml +=  '  <email>'+params.get('email')+'</email>';
        strxml +=  '</billTo>';
        //List 
        strxml +=  ' <item id="0">';
        strxml +=  '   <unitPrice>5.00</unitPrice>';
        strxml +=  '   <quantity>1</quantity>';
        strxml +=  ' </item>';
        strxml +=  ' <item id="1">';
        strxml +=  '  <unitPrice>10.00</unitPrice>';
        strxml +=  '  <quantity>2</quantity>';
        strxml +=  ' </item>';
        strxml +=  ' <purchaseTotals>';
        strxml +=  '   <currency>'+params.get('currency')+'</currency>';
        strxml +=  ' </purchaseTotals>';
        strxml +=  ' <card>';
        strxml +=  '   <accountNumber>'+params.get('cardNumber')+'</accountNumber>';
        strxml +=  '  <expirationMonth>'+params.get('expMonth')+'</expirationMonth>';
        strxml +=  '  <expirationYear>'+params.get('expYear')+'</expirationYear>';
        strxml +=  '   <cardType>'+params.get('cardType')+'</cardType>';
        strxml +=  '</card>';
        if(params.get('recuringSubscription') != null && params.get('recuringSubscription') == 'YES'){
            strxml +=  ' <recurringSubscriptionInfo>';
            strxml +=  '<amount>'+params.get('subAmount')+'</amount>';
            strxml +=  '<numberOfPayments>'+params.get('subNoOfPayments')+'</numberOfPayments>';
            strxml +=  '<automaticRenew>'+params.get('subAutoRenew')+'</automaticRenew>';
            strxml +=  '<frequency>'+params.get('subFrequency')+'</frequency>';
            strxml +=  '<startDate>'+params.get('subStartDate')+'20180721</startDate>';
            strxml +=  '</recurringSubscriptionInfo>';
            strxml +=  '<paySubscriptionCreateService run="true"/>';
        }
        else{
            strxml +=  ' <ccAuthService run="true"/>';
        }
        
        strxml +=  ' </requestMessage>';
        strxml +=  ' </soapenv:Body>';
        strxml +=  '</soapenv:Envelope>';
       
       return strxml;
    }

    public static string ccSOAPAPI()
    { 
    
        string strxml ='';
        strxml +=  '<?xml version="1.0" encoding="UTF-8"?>';
        strxml +=  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        strxml +=  '<soapenv:Header>';
        strxml +=  '  <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
        strxml +=  '   <wsse:UsernameToken>';
        strxml +=  '     <wsse:Username>rajapatnaik</wsse:Username>';
        strxml +=  '     <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">3lkqoBOGvN3jMlz3Nr8Mm7mUyehS89BUGuQKJKEJTvM5wc9Cs1z/3AItl/9qGtTkCr01/ehgAUULa5wmKhKT4i9lPOGlT2uoBfaDJdNWMtFnKgFsPbTvent+y/UrFXY1KrQJM7WmLzg30DW1itIoXCcrXL6WRUfHbi37RSkUKt9r0Xp+OTqML+ly9zzf2C/O+36WJ+c8MFYC0I20u6b/flyZyZXh9da6PESVioAvTJJqvgP19h8FdYxLrr55zy/eSPFUkKGs5zG9IOoom1j04ixFQcOjg54wZmmXVviuIhGoTZtfMy8tHLrigOqJWEemF4zIQZ7bjN4pQ3z/qczIFQ==</wsse:Password>';
        strxml +=  '   </wsse:UsernameToken>';
        strxml +=  ' </wsse:Security>';
        strxml +=  ' </soapenv:Header>';
        strxml +=  '<soapenv:Body>';
        strxml +=  '  <requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.129">';
        strxml +=  '    <merchantID>rajapatnaik</merchantID>';
        strxml +=  '   <merchantReferenceCode>MRC-1230</merchantReferenceCode>';
        strxml +=  '  <billTo>';
        strxml +=  '  <firstName>Raja</firstName>';
        strxml +=  '  <lastName>Patnaik</lastName>';
        strxml +=  ' <street1>1295 Charleston Road</street1>';
        strxml +=  '  <city>Mountain View</city>';
        strxml +=  '  <state>CA</state>';
        strxml +=  '  <postalCode>94043</postalCode>';
        strxml +=  ' <country>US</country>';
        strxml +=  '  <email>rpatnaik@docmation.com</email>';
        strxml +=  '</billTo>';
        strxml +=  ' <item id="0">';
        strxml +=  '   <unitPrice>59.00</unitPrice>';
        strxml +=  '   <quantity>1</quantity>';
        strxml +=  ' </item>';
        strxml +=  ' <item id="1">';
        strxml +=  '  <unitPrice>10.00</unitPrice>';
        strxml +=  '  <quantity>2</quantity>';
        strxml +=  ' </item>';
        strxml +=  ' <purchaseTotals>';
        strxml +=  '   <currency>USD</currency>';
        strxml +=  ' <grandTotalAmount>989</grandTotalAmount>';
        strxml +=  ' </purchaseTotals>';
        strxml +=  ' <card>';
        strxml +=  '   <accountNumber>4111111111111111</accountNumber>';
        strxml +=  '  <expirationMonth>11</expirationMonth>';
        strxml +=  '  <expirationYear>2020</expirationYear>';
        strxml +=  '   <cardType>001</cardType>';
        strxml +=  '</card>';
        strxml +=  ' <ccAuthService run="true"/>';
        /*
        strxml +=  ' <recurringSubscriptionInfo>';
        strxml +=  '<amount>500.00</amount>';
        strxml +=  '<numberOfPayments>4</numberOfPayments>';
        strxml +=  '<automaticRenew>false</automaticRenew>';
        strxml +=  '<frequency>monthly</frequency>';
        strxml +=  '<startDate>20180721</startDate>';
        strxml +=  '</recurringSubscriptionInfo>';
        strxml +=  '<paySubscriptionCreateService run="true"/>';
        */
        
        strxml +=  ' </requestMessage>';
        strxml +=  ' </soapenv:Body>';
        strxml +=  '</soapenv:Envelope>';
       
       return strxml;
    }

}