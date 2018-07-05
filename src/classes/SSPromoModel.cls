global class SSPromoModel {

    global Id promotionId {get;set;}
    global String promotionName {get;set;}
    global String targetProductSKU {get;set;}
    global String couponCode {get;set;}
    global Date startDate {get;set;}    
    global Date endDate {get;set;}  
    global String promoType {get;set;}
    global Decimal promoValue {get;set;}
    global Integer promoDuration {get;set;}
    global String promoPeriod {get;set;}
    global List<String> storefront {get;set;}
    global String shortDescription {get; set;}
    global String longDescription {get; set;}
    global Boolean enabled {get; set;}

}