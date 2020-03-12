@isTest
public class TestDataFactory {
    
    public static Account testData(){
        Keystore__c key = new Keystore__c();
        key.name = '111111';
        insert key;
 string recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Covetrus Account').getRecordTypeId();

        
    
       //List<Account> acntList =new List<Account>();
        Account acc = new Account();
        acc.RecordTypeId=recordtypeId;
        acc.name ='Test';
        acc.ShippingCity ='California';
        acc.ShippingCountry ='United States';
        acc.ShippingPostalCode='30309';
        acc.ShippingState ='California';
        acc.ShippingStreet ='360 - 665 ST. ALBERT TRAIL';
        acc.phone ='32652537';
        acc.BillingCity ='California';
        acc.BillingCountry ='United States';
        acc.Billingpostalcode ='30309';
        acc.BillingState ='California';
        acc.BillingStreet='360 - 665 ST. ALBERT TRAIL';
       // acc.ShippingCountryCode ='US';
       // acc.BillingCountryCode ='US';
        //acc.BillingStateCode ='CA';
        //acc.shippingstatecode ='CA';
        acc.CurrencyIsoCode ='USD';
        acc.Company_Region__c ='NA';
        //acc.Converted_Date__c = system.today();
        acc.Covetrus_Customer_Number__c ='C12356';
        
        insert acc;
        return acc;
        
    }
    
     public static Account testData1(){
           Keystore__c key = new Keystore__c();
        key.name = '111111';
        insert key;
          string recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    
       //List<Account> acntList =new List<Account>();
        Account acc = new Account();
        acc.RecordTypeId =recordtypeId;
        acc.name ='Test123';
        acc.ShippingCity ='New york';
        acc.ShippingCountry ='United States';
        acc.ShippingPostalCode='30309';
        acc.ShippingState ='New york';
        acc.ShippingStreet ='360 - 665 ST. ALBERT TRAIL';
        acc.phone ='32652537';
        acc.BillingCity ='New york';
        acc.BillingCountry ='United States';
        acc.Billingpostalcode ='30309';
        acc.BillingState ='New york';
        acc.BillingStreet='360 - 665 ST. ALBERT TRAIL';
        acc.CurrencyIsoCode ='USD';
        acc.Company_Region__c ='NA';
        insert acc;
           
        Map<String, String> asstRecMap = new Map<String, String>();
        Asset_Record_Types__c asstRecType = new Asset_Record_Types__c();
        asstRecType.Name = 'Hardware';
        asstRecType.Product_Category__c = 'Hardware';
        asstRecType.Asset_Record_Type__c = 'Hardware';
        Insert asstRecType;
        
        asstRecMap.put(asstRecType.Name, asstRecType.Asset_Record_Type__c);
		
		List<Account> AccountList = new List<Account>();
       
        contact con =new contact();
        con.lastname ='Test';
        insert con;
        
      
        Pricebook2 pb2 = new Pricebook2(Name = 'GSS AU', IsActive = True, CurrencyIsoCode = 'AUD');
        insert pb2;
  		
        List<Line_of_Business__c> LOBList = new List<Line_of_Business__c>();
        Line_of_Business__c lob = new Line_of_Business__c();
        lob.Name = 'Test';
        lob.Line_of_Business__c ='GSS';
        lob.Region__c ='NA';        
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
        //insert pbeStandard;
        
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
        
        //string opptyRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Opportunity').getRecordTypeId();
        
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
        qt.OpportunityId =opp.Id;
        qt.ContactId =con.id;
        qt.BillingCity ='Atlanta';
        qt.BillingStreet = 'Test 1123';
        qt.BillingPostalCode ='30309';
        qt.ShippingCountryCode ='US';
        qt.ShippingCity ='Atlanta';
        qt.ShippingStreet = 'Test 1123';
        qt.Status ='Accepted';
        qt.Description ='Test Descriptioon';
        qt.Pricebook2Id =pb2.ID;
        qt.BillingName ='Test';
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
      
        Opp.SyncedQuoteId = qt.Id;
        Update Opp; 
        opp.StageName ='Closed Won';
        update opp;
         
         string covetrusRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Covetrus Account').getRecordTypeId();
         acc.RecordTypeId =covetrusRecId;
         update acc;

         return acc;
    }
    
}