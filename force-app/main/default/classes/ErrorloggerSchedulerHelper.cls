/**************************************************************************************************
*** Trigger Name           : ErrorloggerSchedulerHelper
*** Class Description      : This Class fetches all the records whose archieval date is current date move into Archive from error.
                             This class is invoked by a scheduler class ErrorloggerScheduleClass logger
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
public class ErrorloggerSchedulerHelper {
    
/**************************************************************************************************
*** Method Name             : moveRecordsToArchieve
*** Method Description      : This method removes the record from error logger and archieves it.
**********************************************************************************************************/
public static void moveRecordsToArchieve( List<Error_Logger__c> errorLoggerRecordsList){
        list<Archive_Error_Logger__c> archiveList = new list<Archive_Error_Logger__c>();
            for(Error_Logger__c errLogRecord : errorLoggerRecordsList){
                Archive_Error_Logger__c archieveRec = new Archive_Error_Logger__c();
                archieveRec.name = errLogRecord.Name;
                archieveRec.Brief_Description__c = errLogRecord.Brief_Description__c;
                archieveRec.Close_Date__c = errLogRecord.Closed_Date__c;
                archieveRec.Component_Name__c = errLogRecord.Component_Name__c;
                archieveRec.Component_Type__c = errLogRecord.Component_Type__c;
                archieveRec.Error_Message__c = errLogRecord.Error_Message__c;
                archieveRec.Input__c = errLogRecord.Input__c;
                archieveRec.Object_Name__c = errLogRecord.Object_Name__c;
                archieveRec.Severity__c = errLogRecord.Severity__c;
                archieveRec.Status__c = errLogRecord.Status__c;
                archieveRec.Transaction_Date__c = errLogRecord.TransactionDateTime__c;
                archieveRec.User_ID__c = errLogRecord.User_ID__c;
                archieveRec.User_Name__c = errLogRecord.User_Name__c;
                archiveList.add(archieveRec);
            }	
            if(archiveList.size()>0){
            insert archiveList;
            delete errorLoggerRecordsList;
            }
        
        
    }
   
}