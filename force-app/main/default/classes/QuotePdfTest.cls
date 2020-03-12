/**************************************************************************************************
*** Test Class Name             : QuotePdfTest
*** Author                 	    : Santosh Kumar
*** Trigger Created Date        : 29/07/2019
*		
**************************************************************************************************/
@istest
private class QuotePdfTest {
    private static testmethod void test() {
        Keystore__c key = new Keystore__c();
        key.name = '111111';
        insert key;
        
       /* Account ac = new Account(Name = 'test');
        insert ac;*/
        Account ac =TestDataFactory.testData();

        Opportunity opp = new Opportunity(Name = 'test',LeadSource = 'Sales',Lead_Sub_Source__c = 'Inbound', StageName = 'Draft', CloseDate = System.today(), AccountId = ac.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert opp;

        Quote q = new Quote(Name = 'test', OpportunityId = opp.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert q;
        
        Product2 p = new Product2(IsActive = true, Name = 'test');
        insert p;
        
        PricebookEntry pe = new PricebookEntry(IsActive = true, Pricebook2Id = test.getStandardPricebookId(), UnitPrice = 1, Product2Id = p.Id);
        insert pe;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 1, Product2Id = p.Id);
        insert qli;

        Test.setCurrentPage(Page.QuotePdf);
        ApexPages.currentPage().getparameters().put('id', q.Id);
        QuotePdf gsq = new QuotePdf(new ApexPages.StandardController(q));
        String s = gsq.now;
        Decimal d = gsq.groups[0].subtotal;
    }
}