/**************************************************************************************************
*** Class Name             : ArchieveErrorLoggerTrigger
*** Class Description      : This trigger is used to add days to the archive Expiration field from Custom Labels.
                              When Archive Record is Created
*** Author                 : Hanumanth Reddy
*** Class Created Date     : 30/07/2019
*            Modified Date  :
*            Modified By    :
**************************************************************************************************/
trigger ArchieveErrorLoggerTrigger on Archive_Error_Logger__c (before insert) {
    
    for(Archive_Error_Logger__c archErrorLogger :trigger.new){
        integer days =integer.valueof(System.Label.Expiration_Date);
        archErrorLogger.Expiration_Date__c = System.today().addDays(days);//+label.Expiration_Date;
        system.debug(archErrorLogger.Expiration_Date__c);
        
    }
    
    
}