global class SSSubscriptionRegradeModel  extends SSBaseModel {
    //global TetrisProvisionResponseModel provisionResponse;
    global String tetrisSubscriptionId;
    global String slcsSubscriptionId;
    global String zuoraSubscriptionId;
    global String zuoraAccountId;
    global String zuoraAccountZuoraId;
    global String cartId;
    global Boolean zuoraSubscriptionUpdate;
    global Boolean isCrossSell {get; set;}

    
    global SSSubscriptionModel parentSubscription {get; set;}
}