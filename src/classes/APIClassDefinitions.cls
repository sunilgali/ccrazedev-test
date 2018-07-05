/** 
 * Created by jfeingold on 7/15/16. 
 */ 
 
/** 
 * Created by jfeingold on 7/15/16. 
 */ 
public with sharing class APIClassDefinitions { 
    public with sharing class ProductModel { 
        /** 
         * The record that this product model represents. 
         */ 
        public Product2 record {get; private set;} 
        /** 
         * Provides a source for SBQQ__QuoteLine__c.SBQQ__UpgradedAsset__c 
         */ 
        public Id upgradedAssetId {get; set;} 
        /** 
         * The symbol for the currency in use 
         */ 
        public String currencySymbol {get; private set;} 
        /** 
         * The ISO code for the currency in use 
         */ 
        public String currencyCode {get; private set;} 
        /** 
         * Allows for Product Features to be sorted by category 
         */ 
        public String[] featureCategories {get; private set;} 
        /** 
         * A list of all available options on this product 
         */ 
        public OptionModel[] options {get; private set;} 
        /** 
         * All features present on this product 
         */ 
        public FeatureModel[] features {get; private set;} 
        /** 
         * An object representing this product's current configuration 
         */ 
        public ConfigurationModel configuration {get; private set;} 
        /** 
         * A list of all configuration attributes available on this product 
         */ 
        public ConfigAttributeModel[] configurationAttributes {get; private set;} 
        /** 
         * A list of all configuration attributes this product inherits from ancestor products 
         */ 
        public ConfigAttributeModel[] inheritedConfigurationAttributes {get; private set;} 
        /** 
         * Constraints on this product 
         */ 
        public ConstraintModel[] constraints; 
    } 
 
    public class ConstraintModel { 
        
        
        //public OptionConstraint__c record; 
        public Boolean priorOptionExists; 
    } 
 
    public class OptionModel { 
        //public ProductOption__c record; 
        public Map<String,String> externalConfigurationData; 
        public Boolean configurable; 
        public Boolean configurationRequired; 
        public Boolean quantityEditable; 
        public Boolean priceEditable; 
        public Decimal productQuantityScale; 
        public Boolean priorOptionExists; 
        public Set<Id> dependentIds; 
        public Map<String,Set<Id>> controllingGroups; 
        public Map<String,Set<Id>> exclusionGroups; 
        public String reconfigureDimensionWarning; 
        public Boolean hasDimension; 
        public Boolean isUpgrade; 
        public String dynamicOptionKey; 
    } 
 
    public class ConfigAttributeModel { 
        public String name; 
        public String targetFieldName; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__TargetField__c 
        public Decimal displayOrder; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__DisplayOrder__c 
        public String columnOrder; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ColumnOrder__c 
        public Boolean required; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Required__c 
        public Id featureId; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Feature__c 
        public String position; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Position__c 
        public Boolean appliedImmediately; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__AppliedImmediately__c 
        public Boolean applyToProductOptions; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ApplyToProductOptions__c 
        public Boolean autoSelect; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__AutoSelect__c 
        public String[] shownValues; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__ShownValues__c 
        public String[] hiddenValues; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__HiddenValues__c 
        public Boolean hidden; // Corresponds directly to SBQQ__ConfigurationAttribute__c.SBQQ__Hidden__c 
        public String noSuchFieldName; // If no field with the target name exists, the target name is stored here. 
        public Id myId; // Corresponds directly to SBQQ__ConfigurationAttribute__c.Id 
    } 
 
    public class FeatureModel { 
        //public ProductFeature__c record; 
        public String instructionsText; 
        public Boolean containsUpgrades; 
    } 
 
    public class ConfigurationModel { 
        public Id configuredProductId; 
        public Id optionId; 
        //public ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount 
        //public ProductOption__c configurationData; 
        //public ProductOption__c inheritedConfigurationData; 
        public ConfigurationModel[] optionConfigurations; 
        public Boolean configured; 
        public Boolean changedByProductActions; 
        public Boolean isDynamicOption; 
        public Boolean isUpgrade; 
        public Set<Id> disabledOptionIds; 
        public Set<Id> hiddenOptionIds; 
        public Decimal listPrice; 
        public Boolean priceEditable; 
        public String[] validationMessages; 
        public String dynamicOptionKey; 
    } 
 
    public with sharing class QuoteModel { 
        /** 
         * The record represented by this model 
         */ 
        public SBQQ__Quote__c record; 
        /** 
         * The lines contained in this quote 
         */ 
        public QuoteLineModel[] lineItems; 
        /** 
         * The groups contained in this quote 
         */ 
        public QuoteLineGroupModel[] lineItemGroups; 
 
        /** 
         * The next key that will be used for new groups or lines. 
         * To ensure uniqueness of keys, this value should never be changed to a lower value. 
         */ 
        public Integer nextKey; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ApplyAdditionalDiscountLast__c 
         */ 
        public Boolean applyAdditionalDiscountLast; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ApplyPartnerDiscountFirst__c 
         */ 
        public Boolean applyPartnerDiscountFirst; 
        /** 
         * Corresponds to the 'magic field', SBQQ__Quote__c.ChannelDiscountsOffList__c 
         */ 
        public Boolean channelDiscountsOffList; 
        /** 
         * SBQQ__Quote__c.SBQQ__CustomerAmount__c is a Roll-up Summary Field, so its accuracy can only be guaranteed 
         * after a quote is persisted. As such, its current value is stored here until then. 
         */ 
        public Decimal customerTotal; 
        /** 
         * SBQQ__Quote__c.SBQQ__NetAmount__c is a Roll-up Summary Field, so its accuracy can only be guaranteed 
         * after a quote is persisted. As such, its current value is stored here until then. 
         */ 
        public Decimal netTotal; 
        /** 
         * The Net Total for all non-multidimensional quote lines. 
         */ 
        public Decimal netNonSegmentTotal; 
    } 
 
    public with sharing class QuoteLineModel { 
        /** 
         * The record represented by this model. 
         */ 
        public SBQQ__QuoteLine__c record; 
        /** 
         * Corresponds to the 'magic field', SBQQ__QuoteLine__c.ProrateAmountDiscount__c. 
         */ 
        public Boolean amountDiscountProrated; 
        /** 
         * The unique key of this line's group, if this line is part of a grouped quote. 
         */ 
        public Integer parentGroupKey; 
        /** 
         * The unique key of this line's parent, if this line is part of a bundle. 
         */ 
        public Integer parentItemKey; 
        /** 
         * Each quote line and group has a key that is unique against all other keys on the same quote. 
         */ 
        public Integer key; 
        /** 
         * True if this line is an MDQ segment that can be uplifted from a previous segment. 
         */ 
        public Boolean upliftable; 
        /** 
         * Indicates the configuration type of the product this line represents. 
         */ 
        public String configurationType; 
        /** 
         * Indicates the configuration event of the product this line represents. 
         */ 
        public String configurationEvent; 
        /** 
         * If true, this line cannot be reconfigured. 
         */ 
        public Boolean reconfigurationDisabled; 
        /** 
         * If true, this line's description cannot be changed. 
         */ 
        public Boolean descriptionLocked; 
        /** 
         * If true, this line's quantity cannot be changed. 
         */ 
        public Boolean productQuantityEditable; 
        /** 
         * The number of decimal places to which this line's quantity shall be rounded. 
         */ 
        public Decimal productQuantityScale; 
        /** 
         * The type of MDQ dimension this line represents. 
         */ 
        public String dimensionType; 
        /** 
         * If true, the underlying product can be represented as a Multi-dimensional line. 
         */ 
        public Boolean productHasDimensions; 
        /** 
         * The unit price towards which this quote line will be discounted. 
         */ 
        public Decimal targetCustomerAmount; 
        /** 
         * The customer amount towards which this quote line will be discounted. 
         */ 
        public Decimal targetCustomerTotal; 
        /** 
         * The net total towards which this quote line will be discounted. 
         */ 
    } 
 
    public with sharing class QuoteLineGroupModel { 
        /** 
         * The record represented by this model. 
         */ 
        public SBQQ__QuoteLineGroup__c record; 
 
        /** 
         * The Net Total for all non-multidimensional quote lines. 
         */ 
        public Decimal netNonSegmentTotal; 
        /** 
         * Each quote line and group has a key that is unique against all other keys on the same quote. 
         */ 
        public Integer key; 
    } 
}