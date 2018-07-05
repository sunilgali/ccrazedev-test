//
// 
//

public class pricingInfoclass {

    public class Tiers {
        public Integer q;
        public Integer p;
    }

    public List<Tiers> tiers;
    //public String pT;

    
    public static pricingInfoclass parse(String json) {
        return (pricingInfoclass) System.JSON.deserialize(json, pricingInfoclass.class);
    }
}