/**
* @author Vikram Datla, Docmation
* @creationDate August 12, 2017
*
* @description Helper class with a list of Cart Related Exceptions.This is used in TETRIS R2.
*
* Modification Log
* ------------------------------------------------------------------------------------------------------------
* 1.0 - August 12, 2017 - Vikram Datla
*       Created the initial version of Class with a list of cart related Exceptions.
* ------------------------------------------------------------------------------------------------------------
*/
global class SSCartException extends Exception {
    
    global Static final String EXCEPTION_INVALID_BUNDLE_SKU = 'EXCEPTION_CART_INVALID_BUNDLE_SKU';
    global Static final String EXCEPTION_INVALID_PRODUCT_SKU = 'EXCEPTION_CART_INVALID_PRODUCT_SKU';
    global Static final String EXCEPTION_INVALID_CART_ID = 'EXCEPTION_CART_INVALID_CART_ID';
    global Static final String EXCEPTION_INVALID_CONTACT_ID = 'EXCEPTION_CART_INVALID_CONTACT_ID';
    global Static final String EXCEPTION_INVALID_ACCOUNT_ID = 'EXCEPTION_CART_INVALID_ACCOUNT_ID';
    global Static final String EXCEPTION_EMPTY_CART_REMOVE_FAILED = 'EXCEPTION_CART_EMPTY_CART_REMOVE_FAILED';
    global Static final String EXCEPTION_INVALID_COUPON = 'EXCEPTION_CART_INVALID_COUPON_CODE';
    global Static final String EXCEPTION_EXPIRED_COUPON = 'EXCEPTION_CART_EXPIRED_COUPON_CODE';
    global Static final String EXCEPTION_INVALID_AMOUNT_FOR_COUPON = 'EXCEPTION_CART_INVALID_AMOUNT_FOR_COUPON';
    global Static final String EXCEPTION_PRODUCT_COUPON_LIMIT = 'EXCEPTION_CART_PRODUCT_COUPON_LIMIT';
    global Static final String EXCEPTION_CART_COUPON_LIMIT = 'EXCEPTION_CART_CART_COUPON_LIMIT';
    global Static final String EXCEPTION_COUPON_NOT_APPLIED = 'EXCEPTION_CART_COUPON_NOT_APPLIED';
    
    global Static final String EXCEPTION_CREATE_CART = 'EXCEPTION_CART_CREATE_CART';
    global Static final String EXCEPTION_APPLY_COUPON = 'EXCEPTION_CART_APPLY_COUPON';
    global Static final String EXCEPTION_UPDATE_CART = 'EXCEPTION_CART_UPDATE_CART';
    global Static final String EXCEPTION_ADD_TO_CART = 'EXCEPTION_CART_ADD_TO_CART';
    global Static final String EXCEPTION_REMOVE_FROM_CART = 'EXCEPTION_CART_REMOVE_FROM_CART';
    
    global Static final String EXCEPTION_CREATE_SUBSCRIPTION_FROM_CART = 'EXCEPTION_CART_CREATE_SUBSCRIPTION_FROM_CART';
    
    global Static final String EXCEPTION_INVALID_TAX_CLASS = 'EXCEPTION_INVALID_TAX_CLASS';
    global Static final String EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS = 'EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS';
    global Static final String EXCEPTION_NO_CONFIG_RECORD_FOUND = 'EXCEPTION_NO_CONFIG_RECORD_FOUND';
    
}