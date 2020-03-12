/**************************************************************************************************
*** Test Class Name             : ImplementationPlanTriggerTest
*** Author                 	    : Rahim Shariff
*** Class Created Date          : 29/10/2019
*		
**************************************************************************************************/
@istest
private class ImplementationPlanTriggerTest {
    private static testmethod void test() {
        Implementation_Plan_Template__c tpl = new Implementation_Plan_Template__c(Name = 'test1');
        insert tpl;

		ContentVersion cv = new ContentVersion(Title = 'test', PathOnClient = 'test.txt', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
    	insert cv;

        insert new ContentDocumentLink(LinkedEntityId = tpl.Id, ShareType = 'V', ContentDocumentId = [select id from contentdocument limit 1].id);

        Implementation_Task_Template__c ttl = new Implementation_Task_Template__c(Sequence__c = 1, Implementation_Plan_Template__c = tpl.Id);
        insert ttl;

        insert new ContentDocumentLink(LinkedEntityId = ttl.Id, ShareType = 'V', ContentDocumentId = [select id from contentdocument limit 1].id);

        Implementation_Plan__c ip = new Implementation_Plan__c(Implementation_Plan_Template__c = tpl.Id);
        insert ip;

        ip = [select Name, Total_Tasks__c, Completed_Tasks__c, Actual_Go_Live_Date__c from Implementation_Plan__c where Id = :ip.Id];
        System.assert(ip.Completed_Tasks__c == 0);
        System.assert(ip.Actual_Go_Live_Date__c == null);

        Implementation_Task__c it = [select Id from Implementation_Task__c limit 1];
        it.Status__c = 'Complete';
        it.Revenue_Recognition__c = 'Software Go-Live Date';
        update it;

        ip = [select Name, Total_Tasks__c, Completed_Tasks__c, Actual_Go_Live_Date__c from Implementation_Plan__c where Id = :ip.Id];
        System.assert(ip.Name == tpl.Name);
        System.assert(ip.Total_Tasks__c > 0);
        System.assert(ip.Completed_Tasks__c == 1);
        System.assert(ip.Actual_Go_Live_Date__c != null);
    }
}