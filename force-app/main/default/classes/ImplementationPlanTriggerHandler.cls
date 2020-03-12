/**************************************************************************************************
*** Class Name                  : ImplementationPlanTriggerHandler
*** Author                 	    : RahimShariff
*** Class Created Date          : 29/10/2019
*		
**************************************************************************************************/

public class ImplementationPlanTriggerHandler {
    public static void setDefaults(List<Implementation_Plan__c> plans) {
        Map<Id, Implementation_Plan_Template__c> templates = new Map<Id, Implementation_Plan_Template__c>();
        for (Implementation_Plan__c ip : plans) {
            templates.put(ip.Implementation_Plan_Template__c, null);
        }
        templates = new Map<Id, Implementation_Plan_Template__c>([select Id, Name from Implementation_Plan_Template__c where Id in :templates.keySet()]);
        for (Implementation_Plan__c ip : plans) {
            if (templates.containsKey(ip.Implementation_Plan_Template__c)) {
                ip.Name = templates.get(ip.Implementation_Plan_Template__c).Name;
            }
        }
    }
    public static void spawnTasks(List<Implementation_Plan__c> plans) {
        Map<Id, Implementation_Plan_Template__c> templates = new Map<Id, Implementation_Plan_Template__c>();
        for (Implementation_Plan__c ip : plans) {
            templates.put(ip.Implementation_Plan_Template__c, null);
        }
        if (templates.isEmpty()) return;

        templates = new Map<Id, Implementation_Plan_Template__c>([select Id, (select Id, Name, OwnerId, Revenue_Recognition__c, Sequence__c, Dependency__c, Task_Description__c, Task_Duration__c from Implementation_Task_Template__r) from Implementation_Plan_Template__c where Id in :templates.keySet()]);

        Map<Id, Map<Id, Implementation_Task__c>> tasksByPlan = new Map<Id, Map<Id, Implementation_Task__c>>();
        List<Implementation_Task__c> newTasksToInsert = new List<Implementation_Task__c>();
        Map<Id, Implementation_Task_Template__c> allTaskTemplates = new Map<Id, Implementation_Task_Template__c>();
        for (Implementation_Plan__c ip : plans) {
            Implementation_Plan_Template__c ipt = templates.get(ip.Implementation_Plan_Template__c);
            if (ipt == null) continue;

            tasksByPlan.put(ip.Id, new Map<Id, Implementation_Task__c>());
            for (Implementation_Task_Template__c itt : ipt.Implementation_Task_Template__r) {
                allTaskTemplates.put(itt.Id, itt);
                Implementation_Task__c it = new Implementation_Task__c(
                    Name = itt.Name,
                    OwnerId = itt.OwnerId,
                    Sequence__c = itt.Sequence__c,
                    Task_Duration__c = itt.Task_Duration__c,
                    Implementation_Plan__c = ip.Id,
                    Implementation_Task_Template__c = itt.Id,
                    Revenue_Recognition__c = itt.Revenue_Recognition__c,
                    Task_Description__c = itt.Task_Description__c
                );
                newTasksToInsert.add(it);
                tasksByPlan.get(ip.Id).put(itt.Id, it);
            }
        }
        if (newTasksToInsert.isEmpty()) return;

        insert newTasksToInsert;

        // now go through the tasks by plan and update dependencies
        List<Implementation_Task__c> tasksToUpdate = new list<Implementation_Task__c>();
        for (Map<Id, Implementation_Task__c> tasks : tasksByPlan.values()) {
            // if the task has a dependency, find the task that was created by that dependency and update it on the task as well
            for (Implementation_Task__c t : tasks.values()) {
                Id dependentTaskTemplate = allTaskTemplates.get(t.Implementation_Task_Template__c).Dependency__c;

                // see which task was created by that template
                Implementation_Task__c dependentTask = tasks.get(dependentTaskTemplate);
                if (dependentTask != null) {
                    tasksToUpdate.add(new Implementation_Task__c(
                        Id = t.Id,
                        Task_Dependency__c = dependentTask.Id
                    ));
                }
            }
        }
        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
    }
    public static void copyFilesFromTemplate(List<Implementation_Plan__c> plans) {
        set<Id> templateIds = new set<Id>();
        for (Implementation_Plan__c ip : plans) {
            if (ip.Implementation_Plan_Template__c != null) {
                templateIds.add(ip.Implementation_Plan_Template__c);
            }
        }
        if (!templateIds.isEmpty()) {
            list<ContentDocumentLink> newCdls = new list<ContentDocumentLink>();
            for (ContentDocumentLink cdl : [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :templateIds]){
                for (Implementation_Plan__c ip : plans) {
                    if (ip.Implementation_Plan_Template__c == cdl.LinkedEntityId) {
                        newCdls.add(new ContentDocumentLink(
                            LinkedEntityId = ip.Id,
                            ShareType = 'V',
                            ContentDocumentId = cdl.ContentDocumentId
                        ));
                    }
                }
            }
            if (!newCdls.isEmpty()) insert newCdls;
        }
    }
}