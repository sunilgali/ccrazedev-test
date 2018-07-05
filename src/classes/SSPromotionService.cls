global class SSPromotionService {
	
	global static List<SSPromoModel>  getAllPromotions(String storefrontName){
		return SSPromotionHelper.getAllPromotions(storefrontName);
	}
	
	global static List<SSPromoModel>  getAllPromotionsForProduct(String storefrontName , String productSKU){
		return SSPromotionHelper.getAllPromotionsForProduct(storefrontName , productSKU);
	}

	global static List<SSPromoModel> getActiveProductPromotions(String productSKU){
		return SSPromotionHelper.getActivePromotionsForProduct(productSKU);
	}
	
	global static SSPromoModel getPromotion(String promoCode){
		return SSPromotionHelper.getPromotion(promoCode);
	}
}