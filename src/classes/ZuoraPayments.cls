public class ZuoraPayments{
    public payments[] payments;
    public boolean success;
    public class payments {
        public String id;   //50355df054a53a422499bf00bf32658b
        public String accountId;    //50355df0ef71f8eab9a8f0d14f06885b
        public String accountNumber;    //A00000014
        public String accountName;  //Ringo
        public String type; //External
        public String effectiveDate;    //2015-12-17
        public String paymentNumber;    //P-00000095
        public String paymentMethodId;  //50355df09adbd77e5944f5b7f9f521b4
        public Double amount;   //9808.26
        public paidInvoices[] paidInvoices;
        public gatewayTransactionNumber gatewayTransactionNumber;
        public String status;   //Processed
    }
    public class paidInvoices {
        public String invoiceId;    //50355df057a72aa1323018d962f73fc3
        public String invoiceNumber;    //INV00000100
        public Double appliedPaymentAmount; //9808.26
    }
    public class gatewayTransactionNumber {
    }
    public static ZuoraPayments parse(String json){
        return (ZuoraPayments) System.JSON.deserialize(json, ZuoraPayments.class);
    }
    
    }