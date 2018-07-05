global class SSTaxModel  extends SSBaseModel {
    
    global String country {get; set;}
    global Decimal taxAmount {get; set;}
    global Decimal taxRate {get; set;}
    global Decimal taxableAmount {get; set;}
    global Decimal totalAmount {get; set;}

}