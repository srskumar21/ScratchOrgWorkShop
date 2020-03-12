/**************************************************************************************************
*** Trigger Name           : ErrorloggerScheduler
*** Class Description      : This class is invoked by the ErrorloggerScheduler by passing the list 
                             of Records which will be archived under ArchivalErrorLogger and deleted
                             from ErrorLogger.
*** Author                 : Coreflex Solutions
*** Class Created Date     : 
*** Configurable Parameters:
*        End Point URL     :
*        Custom Labels Used:
*        Custom Object Used: 
*** Change Management      :
*        Change #          : 
*        Change Description:
*        Modified Date     :
*        Modified By       :
**************************************************************************************************/
global class ErrorloggerScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
 List<Error_Logger__c> errorLoggerRecordsList = [SELECT Id, Name, Component_Type__c, Component_Name__c, 
                                                        Closed_Date__c, Brief_Description__c, Object_Name__c, Input__c, 
                                                        Severity__c, Status__c,  Error_Message__c, User_Name__c,
                                                        User_ID__c, TransactionDateTime__c, Supervisor__c 
                                                        FROM Error_Logger__c where Archival_Date__c =:system.today()];
            
       if(errorLoggerRecordsList.size()>0){
           ErrorloggerSchedulerHelper.moveRecordsToArchieve(errorLoggerRecordsList);
       }   
}
}