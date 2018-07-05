global class SSPromotionHelper {
    
    global static List<SSPromoModel> getAllPromotions(String storefrontName){
		List<ccrz__E_Coupon__c> couponList = [select id, ccrz__CouponName__c,ccrz__TargetProduct__r.ccrz__SKU__c,  ccrz__CouponCode__c, ccrz__StartDate__c,
		ccrz__EndDate__c,ccrz__CouponType__c,ccrz__DiscountAmount__c,Period__c, ccrz__Storefront__c, Short_Description__c, Long_Description__c,ccrz__Enabled__c
			from ccrz__E_Coupon__c where ccrz__Storefront__c includes(:storefrontName) and ccrz__Enabled__c = true];
		return populatePromotions(couponList);
	}
	
	global static List<SSPromoModel> getAllPromotionsForProduct(String storefrontName , String productSKU){
		List<ccrz__E_Coupon__c> couponList = [select id, ccrz__CouponName__c,ccrz__TargetProduct__r.ccrz__SKU__c,  ccrz__CouponCode__c, ccrz__StartDate__c,
		ccrz__EndDate__c,ccrz__CouponType__c,ccrz__DiscountAmount__c,Period__c, ccrz__Storefront__c, Short_Description__c, Long_Description__c,ccrz__Enabled__c
			from ccrz__E_Coupon__c where ccrz__Storefront__c includes(:storefrontName) and ccrz__TargetProduct__r.ccrz__SKU__c =:productSKU and ccrz__Enabled__c = true];
		return populatePromotions(couponList);
	}
	
	global static List<SSPromoModel> getActivePromotionsForProduct(String productSKU){
		List<ccrz__E_Coupon__c> couponList = [select id, ccrz__CouponName__c,ccrz__TargetProduct__r.ccrz__SKU__c, ccrz__CouponCode__c, ccrz__StartDate__c,
		ccrz__EndDate__c,ccrz__CouponType__c,ccrz__DiscountAmount__c,Period__c, ccrz__Storefront__c, Short_Description__c, Long_Description__c,ccrz__Enabled__c
			from ccrz__E_Coupon__c where ccrz__TargetProduct__r.ccrz__SKU__c =:productSKU and ccrz__Enabled__c = true];
		return populatePromotions(couponList);
	}
	
	global static SSPromoModel getPromotion(String promoCode){
		List<ccrz__E_Coupon__c> couponList = [select id, ccrz__CouponName__c,ccrz__TargetProduct__r.ccrz__SKU__c, ccrz__CouponCode__c, ccrz__StartDate__c,
		ccrz__EndDate__c,ccrz__CouponType__c,ccrz__DiscountAmount__c,Period__c, ccrz__Storefront__c, Short_Description__c, Long_Description__c,ccrz__Enabled__c
			from ccrz__E_Coupon__c where ccrz__CouponCode__c =:promoCode and ccrz__Enabled__c = true];
		List<SSPromoModel> promoList =  populatePromotions(couponList);
		return promoList.size() > 0 ? promoList[0] : new SSPromoModel();
	}
	
	private static List<SSPromoModel> populatePromotions(List<ccrz__E_Coupon__c> coupons){
		List<SSPromoModel> promoList = new List<SSPromoModel>();
		if(coupons != null && coupons.size() > 0){
			for(ccrz__E_Coupon__c coupon : coupons){
				SSPromoModel promotion = new SSPromoModel();
	    		promotion.promotionId = coupon.Id;
	            promotion.promotionName = coupon.ccrz__CouponName__c;
	            promotion.targetProductSKU = coupon.ccrz__TargetProduct__r.ccrz__SKU__c;
	            promotion.couponCode = coupon.ccrz__CouponCode__c;
	            promotion.startDate = coupon.ccrz__StartDate__c;
	            promotion.endDate = coupon.ccrz__EndDate__c;
	            promotion.promoType = coupon.ccrz__CouponType__c;
	            promotion.promoValue = coupon.ccrz__DiscountAmount__c;
	            promotion.promoDuration = coupon.ccrz__StartDate__c.daysbetween(coupon.ccrz__EndDate__c);
	            promotion.promoPeriod = coupon.Period__c;
	            promotion.storefront = coupon.ccrz__Storefront__c.split(';');
	            promotion.shortDescription = coupon.Short_Description__c;
	            promotion.longDescription = coupon.Long_Description__c;
	            promotion.enabled = coupon.ccrz__Enabled__c;
				promoList.add(promotion);
	        } 
		}
        return promoList;
	}

}