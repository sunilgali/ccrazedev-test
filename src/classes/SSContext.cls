global class SSContext {
    
    public String storefront;
    public String portalUserName;
    public String userLocale;
    public String userCurrency;
    
    private final String defaultStorefront = 'DefaultStore';
   // private final String defaultPortalUser = 'Microsoft Site Guest User';
    private final String defaultPortalUser = 'Default Store';
    private final String defaultUserLocale = 'en_US';
    private final String defaultUserCurrency = 'USD';
    
    global SSContext() {
        this.storefront = defaultStorefront;
        this.portalUserName = defaultPortalUser;
        this.userLocale = defaultUserLocale;
        this.userCurrency = defaultUserCurrency;
        
    }
    
    global SSContext(String storefront, String portalUserName, String userLocale, String userCurrency) {
        this.storefront = storefront;
        this.portalUserName = portalUserName;
        this.userLocale = userLocale;
        this.userCurrency = userCurrency;
    }
    
    global SSContext(String userLocale, String userCurrency) {
        this.storefront = defaultStorefront;
        this.portalUserName = defaultPortalUser;
        this.userLocale = userLocale;
        this.userCurrency = userCurrency;
    }
    
    global ccrz.ccContext getCCContextForAnonymousUser()  {
         system.debug('>>>>');
        ccrz.ccContext ctx = new ccrz.ccContext();
        /*
ctx.storefront = 'DefaultStore';
ctx.portalUserId = '00524000005FMzCAAW';
ctx.userLocale = 'en_GB';
//ctx.userCurrency = 'GBP';
ccrz.cc_CallContext.initContext(ctx);
*/
        system.debug('>>>>'+this.storefront);
        ctx.storefront = this.storefront;
        
        system.debug('>>>>'+this.portalUserName);
        system.debug('>>>>'+this.storefront);
        
        List<User> lstUser = [SELECT ID, NAME from USER where name =: this.portalUserName];
        User user = null;
        if(lstUser!=null && lstUser.size()>0)
        {
            user = lstUser[0];
        }
        else {
            //throw new TetrisCCContextException('Invalid User Context. Unable to establish context for ' + this.portalUserName);
        }
        ctx.portalUserId = user.Id;
        validateSupportedLocales();     
        ctx.userLocale = this.userLocale;
        
        //ctx.userCurrency = userCurrency;
        ccrz.cc_CallContext.initContext(ctx);
        
        return ctx;   
    }
    
     global ccrz.ccContext getCCContextForAnonymousUser(String storefront, String portalUserName, String userLocale)  {
         system.debug('>>>>');
        ccrz.ccContext ctx = new ccrz.ccContext();
        /*
ctx.storefront = 'DefaultStore';
ctx.portalUserId = '00524000005FMzCAAW';
ctx.userLocale = 'en_GB';
//ctx.userCurrency = 'GBP';
ccrz.cc_CallContext.initContext(ctx);
*/
        system.debug('>>>>'+storefront);
        ctx.storefront = storefront;
        
        system.debug('>>>>'+portalUserName);
        system.debug('>>>>'+storefront);
        
        List<User> lstUser = [SELECT ID, NAME from USER where name =: portalUserName];
        User user = null;
        if(lstUser!=null && lstUser.size()>0)
        {
            user = lstUser[0];
        }
        else {
            //throw new TetrisCCContextException('Invalid User Context. Unable to establish context for ' + this.portalUserName);
        }
        ctx.portalUserId = user.Id;
        validateSupportedLocales();     
        ctx.userLocale = this.userLocale;
        
        //ctx.userCurrency = userCurrency;
        ccrz.cc_CallContext.initContext(ctx);
        
        return ctx;   
    }
 
    global Boolean validateSupportedLocales() {
        Map<String, Object> supportedLocales = getSupportedLocalesAndCurrencies();
        if (supportedLocales.containsKey(this.userLocale)) {
            String supportedCurrency = (String)supportedLocales.get(this.userLocale);
            if (!supportedCurrency.equalsIgnoreCase(this.userCurrency)) {
                //throw new TetrisCCContextException('Invalid or unsupported Currency. Unable to establish context for Locale ' + this.userLocale);                                    
            }
        }
        else {
            //throw new TetrisCCContextException('Invalid or unsupported Locale. Unable to establish context for Locale ' + this.userLocale);            
        }
        return true;
    }
    
    global Map<String,Object> getCCApiVersion() {
        Map<String,Object> ccMap = new Map<String,Object>();
        System.debug('entered');
        ccMap.put(ccrz.ccApi.API_VERSION, 7);
        System.debug('entered1');
        return ccMap;
    }
    
    
    global Map<String, Object> getSupportedLocalesAndCurrencies() {
        Map<String, Object> localeMap = new Map<String, Object>();
        localeMap.put('en_GB', 'GBP');
        localeMap.put('en_IE', 'EUR');
        localeMap.put('en_US', 'USD');
        localeMap.put('fr', 'EUR');
        localeMap.put('de', 'EUR');
        localeMap.put('es', 'EUR');
        localeMap.put('en_CA', 'CAD');
        return localeMap;
    }
    
}