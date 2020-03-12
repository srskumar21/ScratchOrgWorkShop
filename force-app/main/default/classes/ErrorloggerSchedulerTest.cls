@isTest
public class ErrorloggerSchedulerTest {
   
   @isTest static void errorLoggerRecrdDeleteTest(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
       
        	 UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        	 insert r;
        
        	 User u = new User(
     		 ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id
        );
            insert u;
            
        Error_Logger__c errorLoggr =new Error_Logger__c();
        errorLoggr.Component_Type__c ='Unknown';
        errorLoggr.Component_Name__c ='Testing_for_Error_Logger';
        errorloggr.Archival_Date__c =system.today();
        errorloggr.Object_Name__c ='Unknown';
        errorloggr.Status__c ='open';
        errorloggr.Resolution__c ='';
        insert errorloggr;
        }

        
        Test.startTest();
        ErrorloggerScheduler  errorLoggerShcdlr =new ErrorloggerScheduler();
        String sch = '0 0 1 1 * ?';
        system.schedule('Test Territory Check', sch, errorLoggerShcdlr);
 
        Test.stopTest();
        
    }
}