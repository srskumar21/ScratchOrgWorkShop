/**************************************************************************************************
*** Class Name             : ArchieveScheduler
*** Class Description      : This Schedule Class Runs as per day and it will delete the Records 
                              from ArchiveErrorLogger Object based on Expiration Date.
*** Author                 : Hanumanth Reddy
*** Class Created Date     : 30/07/2019
*            Modified Date  :
*            Modified By    :
**************************************************************************************************/

public class ArchieveScheduler implements Schedulable{
    
    list<Archive_Error_Logger__c> Archivelist = new list<Archive_Error_Logger__c>();
    public void execute(System.SchedulableContext sc){
        
       Archivelist =[Select id from Archive_Error_Logger__c Where Expiration_Date__c =:System.today()];
       delete Archivelist;


    }
}