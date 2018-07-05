global class SSSubscription {
    global final static String SUBSCRIPTION_STATUS_ACTIVE = 'Active';
    global final static String SUBSCRIPTION_STATUS_INACTIVE = 'Inactive';
    global final static String SUBSCRIPTION_STATUS_UPSELL = 'Upsell';
    global final static String SUBSCRIPTION_STATUS_UPGRADED = 'Upgraded';
    global final static String SUBSCRIPTION_STATUS_DOWNGRADED = 'Downgraded';
    global final static String SUBSCRIPTION_STATUS_CONVERTED = 'Converted';
    global final static String SUBSCRIPTION_STATUS_EXPIRED = 'Expired';
    global final static String SUBSCRIPTION_STATUS_CANCELLATION_SCHEDULED = 'Cancellation Scheduled';
    global final static String SUBSCRIPTION_STATUS_CANCELLATION_COMPLETED = 'Cancellation Completed';
    global final static String SUBSCRIPTION_STATUS_SUSPENDED = 'Suspended';    
    //to be removed
    global final static String SUBSCRIPTION_STATUS_CANCELLED = 'Cancelled';

    global final static String SUBSCRIPTION_REGRADE_TYPE_CROSSSELL = 'Cross Sell';
    global final static String SUBSCRIPTION_REGRADE_TYPE_UPSELL = 'Upsell';
    global final static String SUBSCRIPTION_REGRADE_TYPE_UPGRADE = 'Upgrade';
    global final static String SUBSCRIPTION_REGRADE_TYPE_DOWNGRADE = 'Downgrade';    

    global final static String SUBSCRIPTION_EVENT_NEW = 'New';
    global final static String SUBSCRIPTION_EVENT_CANCEL = 'Cancel';
    global final static String SUBSCRIPTION_EVENT_SUSPEND = 'Suspend';
    global final static String SUBSCRIPTION_EVENT_REACTIVATE = 'Reactivate';
    global final static String SUBSCRIPTION_EVENT_FAILED_PAY_FIRST = 'Failed Payment - First Attempt';
    global final static String SUBSCRIPTION_EVENT_FAILED_PAY_SECOND = 'Failed Payment - Second Attempt';
    global final static String SUBSCRIPTION_EVENT_CROSS_SELL = 'Cross Sell';
    global final static String SUBSCRIPTION_EVENT_EXPIRE = 'Expire';
    global final static String SUBSCRIPTION_EVENT_UPSELL = 'Upsell';
    global final static String SUBSCRIPTION_EVENT_UPGRADE = 'Upgrade';
    global final static String SUBSCRIPTION_EVENT_DOWNGRADE = 'Downgrade';
    global final static String SUBSCRIPTION_EVENT_CONVERT = 'Convert';
    global final static String SUBSCRIPTION_EVENT_REMOVE_PRODUCT = 'Remove Product';
    global final static String SUBSCRIPTION_EVENT_RESUME = 'Resume';
    
    global final static String SUBSCRIPTION_TERM_EVERGREEN = '2099-12-31 00:00:00';

    global final static String SLCS_CHANNEL_PLATFORM = 'Tetris';
    
    global final static String STOREFRONT_DEFAULT = 'DefaultStore';
    global final static String STOREFRONT_DEFAULT_USER_NAME = 'Storefront Community Site Guest User';
    global final static String TAX_DEFAULT_COMPANY_CODE = 'SGSUS';
    global final static String TAX_DEFAULT_CUSTOMER_CODE = 'Sage';
    //Identity Provider Default
    global final static String IDP_DEFAULT='SageID';

}