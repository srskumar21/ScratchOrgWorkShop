/*****************************************************************************************************************
*** Class Name               :  QuotePdf
*** Class Description        :  
*** Author                   :  Santosh Kumar
*** Class Created Date       :  9/10/2019
*       Modified Date        : Rahim 
*       Modified By          : CCRM-3607
******************************************************************************************************************/
public class QuotePdf {
    public String now { get {
        return System.now().format();
    } }
    public List<QuoteLineGroup> groups { get; private set; }

    public QuotePdf(ApexPages.StandardController std) {
        groups = new list<QuoteLineGroup>();
        QuoteLineGroup qlg = null;
        //Start of CCRM-3607
        for (QuoteLineItem qli : [select id, Quantity, UnitPrice, Discount, TotalPrice, Subtotal, Product2.Name, Experlogix_Description__c, experlogix_category__c, Experlogix_Avatax__c from QuoteLineItem where QuoteId = :std.getRecord().Id order by experlogix_category_sequence_no__c, experlogix_category__c, experlogix_optionid_sequence_no__c]) {
        //End of CCRM-3607
            if (qlg == null || qlg.header != qli.experlogix_category__c ) {
                qlg = new QuoteLineGroup(qli.experlogix_category__c);
                groups.add(qlg);
            }
            qlg.lineItems.add(qli);
        }
    }
    public class QuoteLineGroup {
        public String header { get; private set; }
        public List<QuoteLineItem> lineItems { get; private set; }
        public Decimal subtotal { get {
            Decimal ret = 0;
            for (QuoteLineItem qli : lineItems) ret += qli.TotalPrice;
            return ret;
        } }
        public QuoteLineGroup(String header) {
            this.header = header;
            lineItems = new List<QuoteLineItem>();
        }
    }
}