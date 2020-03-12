/**************************************************************************************************
*** Test Class Name             : OpportunityLineItemTriggerHandlerTest	 
*** Author                 	    : Sujana M
*** Class Created Date        : 11/20/2019
*		
**************************************************************************************************/
@istest
private class OpportunityLineItemTriggerHandlerTest {
    static testmethod void test(){
        Opportunity opp = new Opportunity(Name = 'test', StageName = 'Draft', CloseDate = System.today());
        insert opp;

        Product2 prod = new Product2(Name = 'test');
        insert prod;

        PricebookEntry pbe = new PricebookEntry(IsActive = true, UnitPrice = 1, Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id);
        insert pbe;

        Test.startTest();

        try {
	        insert new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 1, TotalPrice = 3, PricebookEntryId = pbe.Id);
            System.assert(false, 'This should have failed due to a validation error since price was overridden');
        } catch(Exception ex) {
        }

        insert new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 1, TotalPrice = 1, PricebookEntryId = pbe.Id);
    }
}