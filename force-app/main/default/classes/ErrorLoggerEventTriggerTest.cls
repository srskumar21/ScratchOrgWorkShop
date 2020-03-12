@isTest
public class ErrorLoggerEventTriggerTest {
    static testmethod void eventTriggerTest(){
        
        
        
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
              Error_Logger_Event__e errLoggerEvent =new Error_Logger_Event__e();
        errLoggerEvent.Component_Name__c ='Test';
        errLoggerEvent.Brief_Description__c ='Error Message';
        //errLoggerEvent.CreatedDate =system.today();
       // errLoggerEvent.User_ID__c ='1234ttew';
        errLoggerEvent.Object_Name__c ='Account';
        errLoggerEvent.Severity__c ='Test';
        errLoggerEvent.Error_Message__c ='test';
       errLoggerEvent.Input__c ='UnKnown';
        errLoggerEvent.TransactionDateTime__c =system.today();
        errLoggerEvent.User_ID__c=u.id;
            
         Test.startTest();
          Database.SaveResult sr = EventBus.publish(errLoggerEvent);

        EventBus.publish(errLoggerEvent);
        
        test.stopTest();
        }
      
   
    }

}