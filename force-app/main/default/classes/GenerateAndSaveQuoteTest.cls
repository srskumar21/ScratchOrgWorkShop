/**************************************************************************************************
*** Class Name                : GenerateAndSaveQuoteTest
*** Author                 	  : Vinay
*** Class Created Date        : 29/07/2019
*		
**************************************************************************************************/
@istest
private class GenerateAndSaveQuoteTest {
    private static testmethod void test() {
        
        Keystore__c key = new Keystore__c();
        key.name = '111111';
        insert key;
        
        Account ac = new Account(Name = 'test');
        insert ac;
        
        Opportunity opp = new Opportunity(Name = 'test', StageName = 'Draft', CloseDate = System.today(), AccountId = ac.Id);
        insert opp;
        
        Quote q = new Quote(Name = 'test', OpportunityId = opp.Id);
        insert q;
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion_1;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        
        
      
        ContentDocumentLink DocLink = new ContentDocumentLink(LinkedEntityId = q.Id, ContentDocumentId=documents[0].ID,ShareType ='I');
        Insert DocLink;
        
        Test.setCurrentPage(Page.GenerateAndSaveQuote);
        ApexPages.currentPage().getparameters().put('id', q.Id);
        GenerateAndSaveQuote gsq = new GenerateAndSaveQuote(new ApexPages.StandardController(q));
        gsq.init();
    }
}