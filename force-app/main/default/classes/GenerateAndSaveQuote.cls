/**************************************************************************************************
*** Class Name                : GenerateAndSaveQuote
*** Author                 	  : Vinay
*** Class Created Date        : 29/07/2019
*		
**************************************************************************************************/
public class GenerateAndSaveQuote {
    Id quoteId;
    public Boolean generated { get; private set; }
    public GenerateAndSaveQuote(ApexPages.StandardController std) {
        quoteId = std.getRecord().Id;
    }
    public void init() {
        generated = false;
        Savepoint sp = Database.setSavepoint();
        try {
            PageReference px = Page.QuotePdf;
            px.getParameters().put('id', quoteId);
            Blob bl = Test.isRunningTest() ? Blob.valueOf('test') : px.getContentAsPdf();

            String qn = [select name from quote where Id = :quoteId].Name;

            set<string> currentAttachNames = new set<String>();
            for (ContentDocumentLink cdl : [select contentdocument.title from contentdocumentlink where linkedentityid = :quoteId]) {
                currentAttachNames.add(cdl.contentdocument.title);
            }

            Integer num = 1;
            String nn = qn + '_V' + num;
            while (currentAttachNames.contains(nn)) {
                num++;
                nn = qn + '_V' + num;
            }

            // insert the content document
			ContentVersion cv = new ContentVersion(
                ContentLocation = 'S',
                PathOnClient = nn + '.pdf',
                Title = nn,
                VersionData = bl
            );
            insert cv;

            // insert the content document link
            Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

			/*insert new ContentDocumentLink(
                ContentDocumentId = cdId,
                LinkedEntityid = quoteId,
                ShareType = 'I'
                //Visibility = 'InternalUsers'
            );*/

			insert new QuoteDocument(
                Document = bl,
                ContentVersionDocumentId = cv.Id,
                QuoteId = quoteId
            );

            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Quote generated'));
            generated = true;
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
        }
    }
}