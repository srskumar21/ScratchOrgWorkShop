/**************************************************************************************************
*** Test Class Name             : OpportunityTriggerTest
*** Author                 	    : Sreenath Dhanireddy
*** Class Created Date        	: 29/07/2019
*		
**************************************************************************************************/
@isTest
public class OpportunityTriggerTest {
    
    static testmethod void updateOpportunityPriceBookTest(){
        
        Account acc =TestDataFactory.testData();
        
        Map<ID,string> accMap = new Map<ID,string>();
        accMap.put(acc.ID, acc.BillingCountry);
        
        Pricebook2 pb2 = new Pricebook2(Name = 'GSS AU', IsActive = True);
        insert pb2;
    
        Line_Of_Business__c lob = new Line_Of_Business__c(Name = 'GSS Test', Line_of_Business__c = 'GSS');
        insert lob;
       
        List<Opportunity_Pricebook__c> oppPbList = new List<Opportunity_Pricebook__c>();
        Opportunity_Pricebook__c oppPbAU = new Opportunity_Pricebook__c();
        oppPbAU.Name = 'Australia';
        oppPbAU.Currency_Code__c = 'AUD';
        oppPbAU.Line_Of_Business_Type__c = 'GSS';
        oppPbAU.Price_Book__c = 'GSS AU';
        insert oppPbAU;
        oppPbList.add(oppPbAU);
        
        Opportunity_Pricebook__c oppPbNZ = new Opportunity_Pricebook__c();
        oppPbNZ.Name = 'New Zealand';
        oppPbNZ.Currency_Code__c = 'NZD';
        oppPbNZ.Line_Of_Business_Type__c = 'GSS';
        oppPbNZ.Price_Book__c = 'GSS NZ';
        insert oppPbNZ;
        oppPbList.add(oppPbNZ);
	
        Map<ID,string> lobMap = new Map<ID,string>();
        lobMap.put(lob.ID, lob.Line_of_Business__c);
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@cfs.com',
            Username = 'puser000@cfs.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        VIOpportunity__c viOpp = new VIOpportunity__c();
        viOpp.SetupOwnerId = user.id;
        insert viOpp;
        
        string recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Opportunity').getRecordTypeId();
        
        List<Opportunity> oppList =new List<opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountID = acc.ID;
        opp.CurrencyIsoCode = 'AUD';
        opp.Name = 'Covertus Opportunity';
        opp.Pricebook2ID = pb2.ID;
        opp.Line_of_Business__c = lob.ID;
        opp.CloseDate =  system.today();
        opp.StageName = 'Qualification';
        opp.LeadSource = 'Sales';
        opp.Lead_Sub_Source__c = 'Inbound';
        opp.Type = 'New Customer';
        opp.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        opp.OwnerId = viOpp.SetupOwnerId;
        insert opp;
        oppList.add(opp);
       
    }
    
    static testmethod void updateOpportunityPriceBookWithCountryTest(){
        
        Keystore__c key = new Keystore__c();
        key.Name = '0000000';
        insert key;
        
        Account acc =TestDataFactory.testData();
        
        Account accAsia = new Account();
        accAsia.Name = 'Asia';
        accAsia.BillingCountry = 'Australia';
        accAsia.Company_Region__c = 'APAC';
        accAsia.Covetrus_Customer_Number__c = '12345';
        
        Map<ID,string> accMap = new Map<ID,string>();
        accMap.put(acc.ID, acc.BillingCountry);
        
        Pricebook2 pb2 = new Pricebook2(Name = 'GSS AU', IsActive = True);
        insert pb2;
        
        Pricebook2 pricebook2Asia = new Pricebook2(Name = 'GSS Asia', IsActive = True);
        insert pricebook2Asia;

        List<Opportunity_Pricebook__c> oppPbList = new List<Opportunity_Pricebook__c>();
        Opportunity_Pricebook__c oppPbAU = new Opportunity_Pricebook__c();
        oppPbAU.Name = 'Australia';
        oppPbAU.Currency_Code__c = 'AUD';
        oppPbAU.Line_Of_Business_Type__c = 'GSS';
        oppPbAU.Price_Book__c = 'GSS AU';
        insert oppPbAU;
        oppPbList.add(oppPbAU);
        
        Opportunity_Pricebook__c oppPbNZ = new Opportunity_Pricebook__c();
        oppPbNZ.Name = 'New Zealand';
        oppPbNZ.Currency_Code__c = 'NZD';
        oppPbNZ.Line_Of_Business_Type__c = 'GSS';
        oppPbNZ.Price_Book__c = 'GSS NZ';
        insert oppPbNZ;
        oppPbList.add(oppPbNZ);
		
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@cfs.com',
            Username = 'puser000@cfs.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        VIOpportunity__c viOpp = new VIOpportunity__c();
        viOpp.SetupOwnerId = user.id;
        insert viOpp;
        
        string recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Opportunity').getRecordTypeId();
        
        List<Opportunity> oppList =new List<opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountID = acc.ID;
        opp.CurrencyIsoCode = 'AUD';
        opp.Name = 'Covertus Opportunity';
        opp.Pricebook2ID = pb2.ID;
        opp.CloseDate =  system.today();
        opp.StageName = 'Qualification';
        opp.LeadSource = 'Sales';
        opp.Lead_Sub_Source__c = 'Inbound';
        opp.Type = 'New Customer';
        opp.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        opp.OwnerId = viOpp.SetupOwnerId;
        insert opp;
        oppList.add(opp);
       
        Opportunity oppAsia = new Opportunity();
        oppAsia.AccountID = accAsia.ID;
        oppAsia.Name = 'Opportunity Asia';
        oppAsia.CurrencyIsoCode = 'USD';
        oppAsia.Pricebook2ID = pricebook2Asia.ID;
        oppAsia.CloseDate =  system.today();
        oppAsia.StageName = 'Qualification';
        oppAsia.LeadSource = 'Sales';
        oppAsia.Lead_Sub_Source__c = 'Inbound';
        oppAsia.Type = 'New Customer';
        oppAsia.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        insert oppAsia;
        oppList.add(oppAsia);

    }
    
    static testmethod void opportunityPriceBookWithoutCountryTest(){
        
        Keystore__c key = new Keystore__c();
        key.Name = '0000000';
        insert key;

        Account acc =TestDataFactory.testData();
        
        Account accAsia = new Account(Name = 'Asia big', Company_Region__c = 'APAC', Covetrus_Customer_Number__c = '12346');
        accAsia.ShippingCity ='WaShington';
        accAsia.ShippingCountry ='United States';
        //accAsia.ShippingPostalCode='303099';
        accAsia.ShippingState ='WaShington';
        accAsia.ShippingStreet ='36 - 66 ST. ALBERT TRAIL';
        accAsia.phone ='32652534';
        accAsia.BillingCity ='WaShington';
        accAsia.BillingCountry ='United States';
        accAsia.Billingpostalcode ='303099';
        accAsia.BillingState ='WaShington';
        accAsia.BillingStreet='36 - 66 ST. ALBERT TRAIL';
        accAsia.CurrencyIsoCode ='USD';
        insert accAsia;
 
        Map<ID,string> accMap = new Map<ID,string>();
        accMap.put(acc.ID, acc.BillingCountry);
        
        Pricebook2 pb2 = new Pricebook2(Name = 'GSS AU', IsActive = True);
        insert pb2;
     
        Pricebook2 pricebook2Asia = new Pricebook2(Name = 'GSS Asia', IsActive = True);
        insert pricebook2Asia;
        
        Line_Of_Business__c lob = new Line_Of_Business__c(Name = 'GSS Test', Line_of_Business__c = 'GSS');
        insert lob;
       
        List<Opportunity_Pricebook__c> oppPbList = new List<Opportunity_Pricebook__c>();
        Opportunity_Pricebook__c oppPbAU = new Opportunity_Pricebook__c();
        oppPbAU.Name = 'Australia';
        oppPbAU.Currency_Code__c = 'NZD';
        oppPbAU.Line_Of_Business_Type__c = 'GSS';
        oppPbAU.Price_Book__c = 'GSS AU';
        insert oppPbAU;
        oppPbList.add(oppPbAU);
        
        Opportunity_Pricebook__c oppPbNZ = new Opportunity_Pricebook__c();
        oppPbNZ.Name = 'New Zealand';
        oppPbNZ.Currency_Code__c = '';
        oppPbNZ.Line_Of_Business_Type__c = 'GSS';
        oppPbNZ.Price_Book__c = 'GSS NZ';
        oppPbNZ.Country__c = 'USA';
        insert oppPbNZ;
        oppPbList.add(oppPbNZ);
	
        Map<ID,string> lobMap = new Map<ID,string>();
        lobMap.put(lob.ID, lob.Line_of_Business__c);
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@cfs.com',
            Username = 'puser000@cfs.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        VIOpportunity__c viOpp = new VIOpportunity__c();
        viOpp.SetupOwnerId = user.id;
        insert viOpp;
        
        string recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Opportunity').getRecordTypeId();
        
        List<Opportunity> oppList =new List<opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountID = acc.ID;
        opp.CurrencyIsoCode = 'AUD';
        opp.Name = 'Covertus Opportunity';
        opp.Pricebook2ID = pb2.ID;
        opp.Line_of_Business__c = lob.ID;
        opp.CloseDate =  system.today();
        opp.StageName = 'Qualification';
        opp.LeadSource = 'Sales';
        opp.Lead_Sub_Source__c = 'Inbound';
        opp.Type = 'New Customer';
        opp.OwnerId = viOpp.SetupOwnerId;
        opp.RecordTypeId = recordtypeId;
        opp.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        insert opp;
        oppList.add(opp);
        
        Opportunity oppAsia = new Opportunity();
        oppAsia.AccountID = accAsia.ID;
        oppAsia.Name = 'Opportunity Asia';
        oppAsia.CurrencyIsoCode = 'USD';
        oppAsia.Pricebook2ID = pricebook2Asia.ID;
        oppAsia.Line_of_Business__c = lob.ID;
        oppAsia.CloseDate =  system.today();
        oppAsia.StageName = 'Qualification';
        oppAsia.LeadSource = 'Sales';
        oppAsia.Lead_Sub_Source__c = 'Inbound';
        oppAsia.Type = 'New Customer';
        oppAsia.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        insert oppAsia;
        oppList.add(oppAsia);
    }
    
    static testmethod void assetCreationTest(){
        
        Map<String, String> asstRecMap = new Map<String, String>();
        Asset_Record_Types__c asstRecType = new Asset_Record_Types__c();
        asstRecType.Name = 'Hardware';
        asstRecType.Product_Category__c = 'Hardware';
        asstRecType.Asset_Record_Type__c = 'Hardware';
        Insert asstRecType;
        
        asstRecMap.put(asstRecType.Name, asstRecType.Asset_Record_Type__c);
		//System.debug('asstRecMap-->'+asstRecMap);
        Keystore__c key = new Keystore__c();
        key.Name = '0000000';
        insert key;
        //Default Account for Line of Business
		List<Account> AccountList = new List<Account>();
        Account acc =TestDataFactory.testData();
        AccountList.add(acc);
        
        contact con =new contact();
        con.lastname ='Test';
        insert con;

        Pricebook2 pb2 = new Pricebook2(Name = 'GSS NA', IsActive = True, CurrencyIsoCode = 'AUD');
        insert pb2;
  		
        List<Line_of_Business__c> LOBList = new List<Line_of_Business__c>();
        Line_of_Business__c lob = new Line_of_Business__c();
        lob.Name = 'Test';
        lob.Line_of_Business__c ='GSS';
        lob.Region__c ='NA';
        //LOBList.add(lob);
        
        insert lob;
        
          Implementation_Plan_Template__c  impPlanTemp = new Implementation_Plan_Template__c(Name ='Test',Line_of_Business__c =lob.id);
           insert impPlanTemp;
        
        List<Product2> ProductList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = 'TestProduct';
        prod.IsActive = True;
        prod.Region__c = 'APAC';
        prod.Line_of_Business__c = 'GSS';
        prod.Family = 'Hardware';
        prod.CurrencyIsoCode = 'AUD';
        prod.ProductCode = 'RXTest';
        prod.Do_Not_Create_Asset__c = False;
        prod.Implementation_Plan_Template__c =impPlanTemp.id;
        insert prod;

        
        List<PriceBookEntry> PriceBookEntryList = new List<PriceBookEntry>();
        PriceBookEntry pbeStandard = new PriceBookEntry(UnitPrice = 1.5, UseStandardPrice = false, IsActive = true, Product2ID = prod.ID, PriceBook2ID = System.Test.getStandardPricebookID());
        pbeStandard.CurrencyIsoCode = 'AUD';
        PriceBookEntryList.add(pbeStandard);
        
        PriceBookEntry pbeCustom = new PriceBookEntry(UnitPrice = 1.5, UseStandardPrice = false, IsActive = true, Product2ID = prod.ID, PriceBook2ID = pb2.ID);
        pbeCustom.CurrencyIsoCode = 'AUD';
        PriceBookEntryList.add(pbeCustom);
        
        insert PriceBookEntryList;
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@gmail.com',
            Username = 'puser000@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert user;
        VIOpportunity__c viOpp = new VIOpportunity__c();
        viOpp.SetupOwnerId = user.id;
        insert viOpp;
        
        string recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Technology').getRecordTypeId();
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountID = acc.ID;
        opp.CurrencyIsoCode = 'AUD';
        opp.Name = 'Covertus Opportunity';
        opp.Pricebook2ID = pb2.ID;
        opp.Line_of_Business__c = lob.ID;
        opp.CloseDate =  system.today();
        opp.StageName = 'Qualification';
        opp.LeadSource = 'Sales';
        opp.Lead_Sub_Source__c = 'Inbound';
        opp.Type = 'New Customer';
        opp.Amount = 10;
        opp.Number_of_Vets__c = 2;
        opp.Current_PIMS__c = 'Test';
        opp.Number_of_Faxes_Week__c = 5;
        opp.Competitive_ProvIDer__c = 'Test';
        opp.Number_of_Client_E_mails__c = 4;
        opp.Timeline_for_Decision__c = system.today();
        opp.Demo_Completed_Date__c = system.today();
        opp.Date_Paperwork_Sent__c = system.today();
        opp.Date_Paperwork_Received__c = system.today();
        opp.Decision_Maker_Present__c = True;
        opp.Decision_Maker_Agreement__c = True;
        opp.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        opp.RecordTypeId = recordtypeId;
        opp.OwnerId = viOpp.SetupOwnerId;
        OpportunityList.add(opp);
        
        insert OpportunityList;
       
        
        List<Opportunitylineitem> OpportunitylineitemList = new List<Opportunitylineitem>();
        Opportunitylineitem oppLineItem = new Opportunitylineitem();
        oppLineItem.Description='test';
        oppLineItem.OpportunityID = OpportunityList[0].ID;
        oppLineItem.Product2ID=prod.ID;
        oppLineItem.PricebookEntryID = pbeCustom.ID;
        oppLineItem.Quantity =2;
        oppLineItem.UnitPrice = 1.5;
        OpportunitylineitemList.add(oppLineItem);
        insert OpportunitylineitemList;
        
        Quote qt = new Quote();
        qt.name ='Test Quote';
        qt.OpportunityId =OpportunityList[0].Id;
        qt.ContactId =con.id;
        qt.BillingCity ='Atlanta';
        qt.BillingStreet = 'Test 1123';
        qt.BillingPostalCode ='30309';
        qt.ShippingCity ='Atlanta';
        qt.ShippingStreet = 'Test 1123';
        qt.ShippingPostalCode ='303091';
        qt.Description ='Test Descriptioon';
        qt.Pricebook2Id =pb2.ID;
        qt.BillingName ='Test';
        qt.Status = 'Accepted';
        insert qt;
        
        QuoteLineItem qutLineItem = new QuoteLineItem();
        qutLineItem.Description ='Test description';
        qutLineItem.PricebookEntryId =pbeCustom.ID;
        qutLineItem.Product2Id =prod.ID;
        qutLineItem.Quantity =2;
        qutLineItem.UnitPrice=1.5;
        qutLineItem.LineNumber__c =2;
        qutLineItem.NestedLineNumber__c ='1T2T';
        qutLineItem.RecordId__c ='TEST'; 
        qutLineItem.QuoteId=qt.id;
        insert qutLineItem;
        
        opp.SyncedQuoteId = qt.Id;
        update opp;
         
        opp.StageName ='Closed Won';
        update opp;
    }
    
    
    
}