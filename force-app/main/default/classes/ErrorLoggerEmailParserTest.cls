@isTest
public class ErrorLoggerEmailParserTest {

    //Test Method for main class
    
    static testMethod void testinBoundEmail()
    {
        // create a new email and envelope object
      
        
          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            
              string Id;
        string username;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     lastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser00016@amamama.com',
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
            Id =u.id;
            username =u.name;
           
       
        
        // setup the data for the email
        
        email.subject = 'Test Job Applicant';
        email.fromAddress = 'someaddress@email.com';
        email.htmlBody='Current User: '+u.lastname+ '('+'Start time:'+string.valueof(system.today()) +'Duration'+'Name: '+'Testing'+'\n';
        system.debug( email.htmlBody);
        //email.plainTextBody ='By user/organization:'+id+'/n Operation:Tesing Error logger testing +\n email body\n2225256325\nTitle+Apex script unhandled trigger exception by user/organization:/';
       // email.plainTextBody ='Operation:Tesing Error logger'+'';
       // email.subject= 'Test Apex governor limit';
       /*Error_Logger__c er =new Error_Logger__c();
        er.Brief_Description__c ='test';
        er.Component_Name__c= 'Unknown';
        er.Input__c='Unknown';
        insert er;*/
         //email.plainTextBody ='This is just a test email for test class . Client:Test@gmail.com';
       // email.subject ='Apex governor limit';
        //email.
        
        // add an Binary attachment
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            // add an Text atatchment
            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfiletwo.txt';
        attachment.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            // call the email service class and test it with the data in the testMethod
            ErrorLoggerEmailParser  testInbound=new ErrorLoggerEmailParser ();
        testInbound.handleInboundEmail(email, env);
        
        // create a Error Logger data
        Error_Logger__c mailLogger= new Error_Logger__c();	
        mailLogger.Error_Message__c ='Test';
        mailLogger.Brief_Description__c='subject';                           
        mailLogger.Component_Name__c='Test Component';
        mailLogger.Component_Type__c='Unknown';
        mailLogger.Input__c='Unknown';
        mailLogger.Object_Name__c='Unknown';
        mailLogger.Status__c='Open';               
        insert mailLogger;
        
        system.debug('Error Logger ===>' +mailLogger);
        
        } 
        
    }
    
      
    static testMethod void testInBoundEmailParser()
    {
        // create a new email and envelope object
      
        
          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            
              string Id;
        string username;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     lastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser00025@amamama.com',
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
            Id =u.id;
            username =u.name;
           
       
        
        // setup the data for the email
        
        email.subject = 'Test Job Applicant';
        email.fromAddress = 'someaddress@email.com';
        //email.htmlBody='Current User: '+u.lastname+ '('+'Start time:'+string.valueof(system.today()) +'Duration'+'Name: '+'Testing'+'\n';
        //system.debug( email.htmlBody);
        email.plainTextBody ='By user/organization:'+id+'/n Operation: '+'Tesing Error logger testing' +'\n email body\n2225256325\nTitle'+'Apex script unhandled trigger exception by user/organization:/';
       // email.plainTextBody ='Operation:Tesing Error logger'+'';
       email.subject= 'Test Apex governor limit';
       /*Error_Logger__c er =new Error_Logger__c();
        er.Brief_Description__c ='test';
        er.Component_Name__c= 'Unknown';
        er.Input__c='Unknown';
        insert er;*/
         //email.plainTextBody ='This is just a test email for test class . Client:Test@gmail.com';
       // email.subject ='Apex governor limit';
        //email.
        
        // add an Binary attachment
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            // add an Text atatchment
            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfiletwo.txt';
        attachment.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            // call the email service class and test it with the data in the testMethod
            ErrorLoggerEmailParser  testInbound=new ErrorLoggerEmailParser ();
        testInbound.handleInboundEmail(email, env);
        
        // create a Error Logger data
        Error_Logger__c mailLogger= new Error_Logger__c();	
        mailLogger.Error_Message__c ='Test';
        mailLogger.Brief_Description__c='subject';                           
        mailLogger.Component_Name__c='Test Component';
        mailLogger.Component_Type__c='Unknown';
        mailLogger.Input__c='Unknown';
        mailLogger.Object_Name__c='Unknown';
        mailLogger.Status__c='Open';               
        insert mailLogger;
        
        system.debug('Error Logger ===>' +mailLogger);
        
        } 
        
    }
    
        
    static testMethod void testInBoundEmailParsers()
    {
        // create a new email and envelope object
      
        
          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            
              string Id;
        string username;
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     lastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser00034@amamama.com',
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
            Id =u.id;
            username =u.name;
           
       
        
        // setup the data for the email
        
        email.subject = 'Test Job ';
        email.fromAddress = 'someaddress@email.com';
        //email.htmlBody='Current User: '+u.lastname+ '('+'Start time:'+string.valueof(system.today()) +'Duration'+'Name: '+'Testing'+'\n';
        //system.debug( email.htmlBody);
        email.plainTextBody ='Apex script unhandled trigger exception by user/organization: '+u.id+'/'+'OpportunityTrigger: '+'Process builder'+'\n';
       //email.plainTextBody ='Apex script unhandled trigger exception by user/organization: '+u.id +'/';
       email.subject= 'Test ';
       /*Error_Logger__c er =new Error_Logger__c();
        er.Brief_Description__c ='test';
        er.Component_Name__c= 'Unknown';
        er.Input__c='Unknown';
        insert er;*/
         //email.plainTextBody ='This is just a test email for test class . Client:Test@gmail.com';
       // email.subject ='Apex governor limit';
        //email.
        
        // add an Binary attachment
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            // add an Text atatchment
            
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfiletwo.txt';
        attachment.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            // call the email service class and test it with the data in the testMethod
            ErrorLoggerEmailParser  testInbound=new ErrorLoggerEmailParser ();
        testInbound.handleInboundEmail(email, env);
        
        // create a Error Logger data
        Error_Logger__c mailLogger= new Error_Logger__c();	
        mailLogger.Error_Message__c ='Test';
        mailLogger.Brief_Description__c='subject';                           
        mailLogger.Component_Name__c='Test Component';
        mailLogger.Component_Type__c='Unknown';
        mailLogger.Input__c='Unknown';
        mailLogger.Object_Name__c='Unknown';
        mailLogger.Status__c='Open';               
        insert mailLogger;
        
        system.debug('Error Logger ===>' +mailLogger);
        
        } 
        
    }


    
}