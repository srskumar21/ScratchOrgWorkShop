@isTest(SeeAllData=true)
public class RHX_TEST_QuoteLineItem {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM QuoteLineItem LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new QuoteLineItem()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}