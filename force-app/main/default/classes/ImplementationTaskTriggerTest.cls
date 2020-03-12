/**************************************************************************************************
*** Test Class Name             : ImplementationTaskTriggerTest
*** Author                 	    : Sreenath Dhanireddy
*** Class Created Date        : 29/07/2019
*		
**************************************************************************************************/
@istest
private class ImplementationTaskTriggerTest {
    private static testmethod void test() {
        Implementation_Plan_Template__c tpl = new Implementation_Plan_Template__c();
        insert tpl;

		ContentVersion cv = new ContentVersion(Title = 'test', PathOnClient = 'test.txt', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
    	insert cv;

        insert new ContentDocumentLink(LinkedEntityId = tpl.Id, ShareType = 'V', ContentDocumentId = [select id from contentdocument limit 1].id);

        Implementation_Task_Template__c ttl = new Implementation_Task_Template__c(Sequence__c = 1, Implementation_Plan_Template__c = tpl.Id);
        insert ttl;

        Implementation_Task_Template__c ttl2 = new Implementation_Task_Template__c(Sequence__c = 2, Implementation_Plan_Template__c = tpl.Id, Dependency__c = ttl.Id);
        insert ttl2;

        try {
        	insert new Implementation_Task_Template__c(Sequence__c = 2, Implementation_Plan_Template__c = tpl.Id, Dependency__c = ttl.Id);
            System.assert(false, 'This should have failed since it was a dupe sequence');
        } catch(Exception ex) {
            // good
        }

        insert new ContentDocumentLink(LinkedEntityId = ttl.Id, ShareType = 'V', ContentDocumentId = [select id from contentdocument limit 1].id);

        Implementation_Plan__c ip = new Implementation_Plan__c(Implementation_Plan_Template__c = tpl.Id, Total_Tasks__c = 1, Completed_Tasks__c = 0);
        insert ip;

        list<Implementation_Task__c> tasks = [select id, Sequence__c, Implementation_Plan__c from implementation_task__c];
        tasks[0].Status__c = 'Complete';

        try {
        	insert new Implementation_Task__c(Sequence__c = tasks[0].Sequence__c, Implementation_Plan__c = tasks[0].Implementation_Plan__c);
            System.assert(false, 'This should have failed since it was a dupe sequence');
        } catch(Exception ex) {
            // good
        }

        update tasks;

        System.assert([select Id from implementation_task__c where Task_Dependency__c != null].size() == 1);

        delete tasks;
        undelete tasks;
    }
}