global class CSSCart {

    global static final String COUPON_RULE_TYPE_GENERAL = 'General';
    global static final String COUPON_RULE_TYPE_CART_TOTAL = 'CartTotal';
    global static final String COUPON_TYPE_ABSOLUTE = 'Absolute';
    global static final String COUPON_TYPE_PERCENTAGE = 'Percentage';
    global static final String COUPON_TYPE_PRICE = 'Price';
    global static final String DEFAULT_STORE = 'DefaultStore';
    
    global static final String CART_STATUS_OPEN = 'Open';
    global static final String CART_STATUS_PROVISION_PENDING = 'Provision Pending';
    global static final String CART_STATUS_ACCOUNT_CREATED = 'Account Created';
    global static final String CART_STATUS_PRODUCT_PROVISIONED = 'Product Provisioned';
    global static final String CART_STATUS_CLOSED = 'Closed';
    global static final String CART_STATUS_ABANDONED = 'Abandoned';
    
    global static final String CART_VALIDATION_STATUS_VALIDATED = 'CartAuthUserValidated';

    global static final String CART_TRANSACTION_TYPE_CONVERT = 'convert';
    global static final String CART_TRANSACTION_TYPE_BUY = 'buy';
    global static final String CART_TRANSACTION_TYPE_TRIAL = 'trial';
    global static final String CART_TRANSACTION_TYPE_CROSSSELL = 'cross sell';
    global static final String CART_TRANSACTION_TYPE_UPSELL = 'upsell';
    global static final String CART_TRANSACTION_TYPE_UPGRADE = 'upgrade';
    global static final String CART_TRANSACTION_TYPE_DOWNGRADE = 'downgrade';
    
    global static final Decimal CART_IE_TAX_RATE = 0.23;
    global static final Decimal CART_GB_TAX_RATE = 0.20;

}