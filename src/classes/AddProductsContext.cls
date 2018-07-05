public with sharing class AddProductsContext {
        public QuoteModel quote;
        public ProductModel[] products;
        public Integer groupKey;
        public final Boolean ignoreCalculate = true; //Must be hardcoded to true
    
        public AddProductsContext(QuoteModel quote, ProductModel[] products, Integer groupKey) {
            this.quote = quote;
            this.products = products;
            this.groupKey = groupKey;
        }
    }