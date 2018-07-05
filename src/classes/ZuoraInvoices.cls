public class ZuoraInvoices {

    public List<Invoices> invoices;
    public Boolean success;

    public class InvoiceFiles {
        public String id;
        public Long versionNumber;
        public String pdfFileUrl;
    }

    public class InvoiceItems {
        public String id;
        public String subscriptionName;
        public String subscriptionId;
        public String serviceStartDate;
        public String serviceEndDate;
        public Double chargeAmount;
        public String chargeDescription;
        public String chargeName;
        public String chargeId;
        public String productName;
        public Double quantity;
        public Double taxAmount;
        public String unitOfMeasure;
        public String chargeDate;
        public String chargeType;
        public String processingType;
    }

    public class Invoices {
        public String id;
        public String accountId;
        public String accountNumber;
        public String accountName;
        public String invoiceDate;
        public String invoiceNumber;
        public String dueDate;
        public String invoiceTargetDate;
        public Double amount;
        public Double balance;
        public Double creditBalanceAdjustmentAmount;
        public String createdBy;
        public String status;
        public String body;
        public List<InvoiceItems> invoiceItems;
        public List<InvoiceFiles> invoiceFiles;
    }

    
    public static ZuoraInvoices parse(String json) {
        return (ZuoraInvoices) System.JSON.deserialize(json, ZuoraInvoices.class);
    }
}