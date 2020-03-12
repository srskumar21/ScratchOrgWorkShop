/*****************************************************************************************************************
*** Class Name               :  AccountTriggerHelper
*** Class Description        :  This Helper class is invoked by AccountTrigger when the Account record is updated
by AccountTeamMember.
*** Author                   :  Nagarjuna
*** Class Created Date       :  9/10/2019
*       Modified Date        :  27/12/2019  
*       Modified By          :  Hanumath 
* Source Of Modification     :  CCRM-3788--Vinod
******************************************************************************************************************/
public with sharing class AccountTriggerHelper {
    /***************************************************************************************************************
*** Method Name             : accountTeamMembCreation
*** Method Description      : This method validates the all the fields on Account record and displays error message 
when it is modified by AccountTeamMember except "No of Vets" field.
********************************************************************************************************************/
    public static void validateFieldsForAccTeamUsers(map < id, Account > newAccRecordMap, map < id, Account > oldAccRecordMap) {
        map < String, String > newAccRecFieldValMap = new map < String, String > ();
        map < String, String > oldAccRecFieldValMap = new map < String, String > ();
        Set < Id > profileIds = new Set < Id > ();
        map < id, Account > newAccountUsermap = new map < id, Account > ();
        map < id, Account > oldAccountUsermap = new map < id, Account > ();
        List < String > ProfileNames = new List < String > ();
        ProfileNames.add(Label.COSalesUser);
        ProfileNames.add(Label.COSupportUser);
        ProfileNames.add(Label.GSSSalesANZUK);
        ProfileNames.add(Label.GSSSupportANZUK);
        //CCRM-3651 Removed GSS-NA Sales & GSS-NA Support Profiles from the List 
        List < Profile > profileList = [SELECT id, name FROM profile where name IN: ProfileNames];
        for (Profile prof: profileList) {
            profileIds.add(prof.id);
        }
        Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.SalesOpsAdmin);
        List < AccountTeamMember > accTeamMembList = [select id, userid, AccountId from AccountTeamMember where AccountId =: newAccRecordMap.keySet()];
        
        for (AccountTeamMember accTeamMemb: accTeamMembList) {
            newAccountUsermap.put(accTeamMemb.UserId, newAccRecordMap.get(accTeamMemb.AccountId));
            oldAccountUsermap.put(accTeamMemb.UserId, oldAccRecordMap.get(accTeamMemb.AccountId));
        }
        for (Id userId: newAccountUsermap.keyset()) {
            if (userId == UserInfo.getUserId() && newAccountusermap.get(userId).Number_of_Vets__c == oldAccountUsermap.get(userId).Number_of_Vets__c &&
                (newAccountUsermap.get(userId).Name != oldAccountUsermap.get(userId).Name ||
                 newAccountUsermap.get(userId).CurrencyIsoCode != oldAccountUsermap.get(userId).CurrencyIsoCode ||
                 newAccountUsermap.get(userId).OwnerId != oldAccountUsermap.get(userId).OwnerId)) {
                     newAccountUsermap.get(userId).addError('As a Account Team Member, you cannot modify any other fields other than "Number of Vets" field');
                 }
        }
        for (Account newAcc: newAccRecordMap.values()) {
            Account oldAcc = oldAccRecordMap.get(newAcc.id);
            if (!(hasCustomPermission) &&
                !(newAccountUsermap.containsKey(UserInfo.getUserId())) && (newAcc.Name != oldAcc.Name ||
                                                                           newAcc.CurrencyIsoCode != oldAcc.CurrencyIsoCode ||
                                                                           newAcc.OwnerId != oldAcc.OwnerId ||
                                                                           newAcc.Number_of_Vets__c != oldAcc.Number_of_Vets__c ||
                                                                           newAcc.RecordTypeId != oldAcc.RecordTypeId) &&
                                                                           newAcc.Update_RecordType__c == False &&
                profileIds.contains(UserInfo.getProfileId())) {
                    newAcc.addError('You are not allowed to change the Account details.');
                }
        }
        updateIntegrationRequestedDateBasedOnGovernedFieldSet(newAccRecordMap,oldAccRecordMap);
        
    }
    
    /***************************************************************************************************************
*** Method Name             : updateIntegrationRequestedDateBasedOnGovernedFieldSet
*** Method Description      : This method is used to send Account details to Boomi.When there is any of the field is
edited in the fieldset.
********************************************************************************************************************/
    
    public Static void updateIntegrationRequestedDateBasedOnGovernedFieldSet(Map<Id,Account> newAccntRecrdMap,Map<Id,Account> oldAcntRecrdMap){
        try {
            set<String> fieldSet = new Set<String>();           
            for(Schema.Fieldsetmember fields :Schema.SObjecttype.Account.Fieldsets.getmap().get('Governed_Fields').getfields()){
                fieldSet.add(fields.getFieldPath());
            }
            for(Account accRecs : newAccntRecrdMap.values()){
                for(String fieldSetList : fieldSet){
                    if(accRecs.get(fieldSetList) != oldAcntRecrdMap.get(accRecs.id).get(fieldSetList)){
                        accRecs.Integration_Requested_Date__c =System.now();                   
                    }                   
                }                
            }            
        }
        catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Map<Id,Account>'), string.valueOf(newAccntRecrdMap), string.valueOf('Map<Id,Account>'), string.valueOf(oldAcntRecrdMap), null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
            
        }
    }
    /***************************************************************************************************************
*** Method Name             : populateCovetrusCustomerAccountNumber
*** Method Description      : This method is used to populate the value on 'Covetrus customer number' and 
'integration requested date' fields.
*** Modified Descrption     : Integration Requested Date will Update When Associated Line Of Bussiness Field Is Updated
when Associated Line Of Bussiness Field Old Value Not Equal New Value
********************************************************************************************************************/
    public static void populateCovetrusCustomerAccountNumber(list < account > accountList) {
        try {
            Map < ID, Schema.RecordTypeInfo > rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
            Keystore__c key = [SELECT Id, Name FROM Keystore__c];
            List < Account > accsToUpdate = new List < Account > ();
            Integer typeCastIntegerValue = Integer.ValueOf(key.name);
            for (Account acc: accountList) {
                    if (rt_map.get(acc.recordTypeID).getName().containsIgnoreCase('Covetrus Account')) {
                        If(acc.Covetrus_Customer_Number__c == Null) {
                            typeCastIntegerValue = typeCastIntegerValue + 1;
                            acc.Covetrus_Customer_Number__c = 'C' + String.valueOf(typeCastIntegerValue).leftPad(7, '0');
                            acc.Integration_Requested_Date__c = DateTime.Now();
                        }
                    }                
            }
            
            if (typeCastIntegerValue != NULL && typeCastIntegerValue != Integer.ValueOf(key.name)) {
                key.name = string.valueOf(typeCastIntegerValue);
                update key;
            }
        } catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Opportunity>'), string.valueOf(accountList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), accountList, null, inputFromMethodParameters);
            
        }
    }
    
    /***************************************************************************************************************
*** Method Name             : populateAssociatedLineOfBusiness
*** Method Description      : This method is used to populate the Opportunity 'Line of Business' field value on Account 
'Associated line of business' field.
********************************************************************************************************************/
    
    Public static void populateAssociatedLineOfBusiness(Map < Id, Account > accountMap, map < id, Account > oldAccnt) {
        try {  
            List < Opportunity > oppLists = new List < Opportunity > ();
            for (Opportunity oppnty: [SELECT id, stagename, Line_of_Business__r.name, Account.Associated_Line_of_Businesses__c 
                                      FROM opportunity 
                                      WHERE Id NOT IN
                                      (SELECT OpportunityId FROM Order) AND StageName =: System.Label.Opportunity_Stage_Name AND Accountid =: accountMap.keyset()]) {
                                          oppLists.add(oppnty);
                                      }
            for (Account accnt: accountMap.values()) {
                String assLineOfBusiness = '';
                if(oppLists.size()>0){
                    for (Opportunity oppty: oppLists) {
                        if (accnt.id == oppty.accountid) {
                            //Start of CCRM-3518
                            if(String.isNotBlank(oppty.Line_of_Business__r.name)){
                            //End of CCRM-3518
                                if (String.isNotBlank(oldAccnt.get(accnt.id).Associated_Line_of_Businesses__c)) {
                                    if (!oldAccnt.get(accnt.id).Associated_Line_of_Businesses__c.Contains(oppty.Line_of_Business__r.name) &&
                                        !assLineOfBusiness.Contains(oppty.Line_of_Business__r.name) &&
                                         String.isNotBlank(oppty.Line_of_Business__r.name)) {
                                            assLineOfBusiness = oldAccnt.get(accnt.id).Associated_Line_of_Businesses__c + ';' + oppty.Line_of_Business__r.name;
                                        }
                                } 
                                else {	
                                    if (!assLineOfBusiness.Contains(oppty.Line_of_Business__r.name)) {
                                        assLineOfBusiness = assLineOfBusiness + ';' + oppty.Line_of_Business__r.name;
                                    }
                                }
                            }
                            if (String.isNotBlank(assLineOfBusiness)) {
                                accnt.Associated_Line_of_Businesses__c = assLineOfBusiness;
                                accnt.Integration_Requested_Date__c = DateTime.Now();
                            }
                        }
                    }
                }
            }
        }
        Catch(Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Map<Id,Account>'), string.valueOf(accountMap), string.valueOf('Map<Id,Account>'), string.valueOf(oldAccnt), null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
    
    /***************************************************************************************************************
*** Method Name             : createOrderandOrderlines
*** Method Description      : This method is used to create assets from opportunitylineitems.when the account recordtype 
changes from 'Prospect' to 'Covetrus account'
********************************************************************************************************************/
    public static void createOrderandOrderlines(Set < Id > setAcntIds) {
        Map < Id, Opportunity > opptyMaps = new Map < Id, Opportunity > ();
        Set < Id > opptyIdSet = new Set < Id > ();
        Set < Id > accntIdSet = new Set < Id > ();
        List < Account > accList = new List < Account > ();
        Map < ID, Asset > assetRecMap = new Map < ID, Asset > ();
        try {
            for (Opportunity opty: [SELECT ID, accountid, StageName FROM opportunity WHERE Id NOT IN
                                    (SELECT OpportunityId FROM Order) AND StageName =: System.Label.Opportunity_Stage_Name AND AccountId =: setAcntIds]) {
                                        opptyIdSet.add(opty.id);
                                    }
            System.debug('opptyIdSet:-' + opptyIdSet);
            if (!opptyIdSet.isEmpty()) {
                Map < String, String > assetRecdMap = new Map < String, String > ();
                for (Asset_Record_Types__c assRecType: Asset_Record_Types__c.getAll().values()) {
                    assetRecdMap.put(assRecType.Name, assRecType.Asset_Record_Type__c);
                }
                opptyMaps = new Map < Id, Opportunity > ([SELECT ID, AccountId, Line_of_Business__c, Line_of_Business__r.Name, Line_of_Business__r.Line_of_Business__c, Line_of_Business__r.Region__c, CloseDate,
                                                          (SELECT ID,
                                                           PricebookEntry.product2.Description,
                                                           PricebookEntry.product2.Name,
                                                           PricebookEntry.Product2.ID,
                                                           PricebookEntry.Product2.ProductCode,
                                                           PricebookEntry.product2.ERP_Product_Number__c, Quantity,
                                                           PricebookEntry.product2.Family,
                                                           PricebookEntry.product2.Manufacturer__c,
                                                           PricebookEntry.product2.Asset_Type__c,
                                                           PricebookEntry.product2.Enabled_by_Default__c,
                                                           PricebookEntry.Product2.Hardware_Express_Price__c,
                                                           PricebookEntry.Product2.Manufacturer_Item_Number__c,
                                                           PricebookEntry.Product2.Implementation_Plan_Template__c,
                                                           PricebookEntry.Product2.Implementation_Plan_Template__r.OwnerId,
                                                           PricebookEntry.Product2.Implementation_Plan_Template__r.Name FROM OpportunityLineItems WHERE PricebookEntry.Product2.Do_Not_Create_Asset__c = false
                                                          )
                                                          FROM Opportunity WHERE ID in: opptyIdSet
                                                         ]);
                Id ownerId = [SELECT ID FROM GROUP WHERE Name = 'GSS NA Implementations Team'].ID;
                List < Asset > assetList = new List < Asset > ();
                Map < Integer, Implementation_Plan__c > implementationPlans = new Map < Integer, Implementation_Plan__c > ();
                for (Opportunity opp: opptyMaps.values()) {
                    for (OpportunityLineItem lineItem: opp.OpportunityLineItems) {
                        if (assetRecdMap.containsKey(lineItem.PricebookEntry.product2.Family)) {
                            Asset asst = new Asset();
                            asst.Name = lineItem.PricebookEntry.product2.Name;
                            asst.AccountId = opp.AccountId;
                            asst.Line_of_Business__c = opp.Line_Of_Business__c;
                            asst.Description = lineItem.PricebookEntry.product2.Description;
                            asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get(assetRecdMap.get(lineItem.PricebookEntry.product2.Family)).getRecordTypeId();
                            asst.Product2Id = lineItem.PricebookEntry.Product2Id;
                            asst.PurchaseDate = opp.CloseDate;
                            asst.ERP_Product_Number__c = lineItem.PricebookEntry.Product2.ERP_Product_Number__c;
                            asst.Quantity = lineItem.Quantity;
                            asst.Manufacturer__c = lineItem.PricebookEntry.Product2.Manufacturer__c;
                            asst.Product_Name__c = lineItem.PricebookEntry.Product2.Name;
                            asst.Hardware_Express_Price__c = lineItem.PricebookEntry.Product2.Hardware_Express_Price__c;
                            asst.Manuafacturer_Item_Number__c = lineItem.PricebookEntry.Product2.Manufacturer_Item_Number__c;
                            asst.Asset_Type__c = lineItem.PricebookEntry.Product2.Asset_Type__c;
                            if (lineItem.PricebookEntry.Product2.Enabled_by_Default__c == true)
                                asst.Software_Status__c = System.Label.Asset_status_enabled;
                            else
                                asst.Software_Status__c = System.Label.Asset_status_disabled;
                            assetList.add(asst);
                            if (lineItem.PricebookEntry.Product2.Implementation_Plan_Template__c != null &&
                                opp.Line_Of_Business__r.Line_Of_Business__c == 'GSS' && opp.Line_Of_Business__r.Region__c == 'NA') {
                                    implementationPlans.put(assetList.size() - 1, new Implementation_Plan__c(
                                        Name = lineItem.PricebookEntry.Product2.Implementation_Plan_Template__r.Name,
                                        OwnerId = ownerId,
                                        Account__c = opp.AccountId,
                                        Implementation_Plan_Template__c = lineItem.PricebookEntry.Product2.Implementation_Plan_Template__c,
                                        Quote__c = opp.Quotes.isEmpty() ? null : opp.Quotes[0].Id
                                    ));
                                }
                        }
                    }
                }
                if (!assetList.isEmpty()) {
                    insert assetList;
                    
                    for (Asset astRec: assetList) {
                        assetRecMap.put(astRec.Id, astRec);
                    }
                    if (!implementationPlans.isEmpty()) {
                        // go through and insert the implementation plans - updating the asset ids on them first
                        for (Integer implementationPlan: implementationPlans.keySet()) {
                            implementationPlans.get(implementationPlan).Asset__c = assetList[implementationPlan].Id;
                        }
                        insert implementationPlans.values();
                    }
                }
                orderCreationOnCovetrusAccount(opptyIdSet, assetRecMap);
                
            }
            
        } catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Set<Id>'), string.valueOf(setAcntIds), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
            
        }
    }
    
    /***************************************************************************************************************
*** Method Name             : orderCreationOnCovetrusAccount
*** Method Description      : This method is used to create orders from quotes.When the opportunity stage is 'closed won'
********************************************************************************************************************/
    
    public static void orderCreationOnCovetrusAccount(Set < ID > oppIds, Map < ID, Asset > assetRecMap) {
        
        try {
            Map < ID, ID > ordrQuoteIdMap = new Map < ID, ID > ();
            Map < ID, order > orderMapRecs = new Map < ID, Order > ();
            Map < ID, ID > assetProdCodeMap = new Map < ID, ID > ();
            if (!oppIds.isEmpty()) {
                list < quote > quoteList = [SELECT Id, name, OpportunityId, AccountId, BillingName, opportunity.closedate, BillingCity, 
                                            BillingCountry, BillingPostalCode, BillingState, BillingStreet, Description, ContactId, OwnerId, 
                                            TotalPrice, Pricebook2Id,ShippingCity,ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, 
                                            opportunity.currencyisocode,opportunity.CreatedById
                                             // Start of CCRM-3788 --Added condition to create order when Status ='Accepted'
                                            FROM Quote where opportunityid =: oppIds AND Status='Accepted' AND IsSyncing = True
                                            // End of CCRM-3788
                                           ];
                
                List < Order > orderList = new List < Order > ();
                    // Start of CCRM-3788 Added condition to create orders only one quote With 'Accepted' status
                if (quoteList.size() == 1) {
                     // End of CCRM-3788
                    for (quote quoteRec: quoteList) {
                        order ordr = new order();
                        ordr.AccountId = quoteRec.AccountId;
                        ordr.OpportunityId = quoteRec.OpportunityId;
                        ordr.BillToContactId = quoteRec.ContactId;
                        ordr.BillingCity = quoteRec.BillingCity;
                        ordr.Billingcountry = quoteRec.Billingcountry;
                        ordr.BillingPostalCode = quoteRec.BillingPostalCode;
                        ordr.BillingState = quoteRec.BillingState;
                        ordr.BillingStreet = quoteRec.BillingStreet;
                        ordr.EffectiveDate = System.today();
                        ordr.Status = 'Draft';
                        ordr.QuoteId = quoteRec.id;
                        ordr.CompanyAuthorizedDate = quoteRec.opportunity.closedate;
                        ordr.Description = quoteRec.Description;
                        ordr.CurrencyIsoCode = quoteRec.opportunity.currencyisocode;
                        ordr.name = quoteRec.name;
                        ordr.ShippingCity = quoteRec.ShippingCity;
                        ordr.ShippingCountry = quoteRec.ShippingCountry;
                        ordr.ShippingPostalCode = quoteRec.ShippingPostalCode;
                        //Start of CCRM-3521
                        ordr.ShippingState = quoteRec.ShippingState;
                        //End of CCRM-3521
                        ordr.ShippingStreet = quoteRec.ShippingStreet;
                        ordr.Pricebook2Id = quoteRec.Pricebook2Id;
                        //Start of CCRM-3704
                        ordr.OwnerId = quoteRec.opportunity.CreatedById;
                        //End of CCRM-3704
                        orderList.add(ordr);
                        system.debug('orderList' + orderList);
                    }
                    if (!orderList.isEmpty()) {
                        insert orderList;
                        
                    }
                    if(assetRecMap.Size() > 0){
                        for (Asset asetrecords: assetRecMap.values()) {
                            assetProdCodeMap.put(asetrecords.Product2Id, asetrecords.Id);
                        }
                        
                    }
                    
                    for (Order ordrRecrds: orderList) {
                        ordrQuoteIdMap.put(ordrRecrds.id, ordrRecrds.QuoteId);
                        orderMapRecs.put(ordrRecrds.QuoteId, ordrRecrds);
                    }
                    
                }
                addingOrderLineItemsToOrder(ordrQuoteIdMap, orderMapRecs, assetProdCodeMap);
            }
        } catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Set<ID>'), string.valueOf(oppIds), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
            
        }
    }
    /***************************************************************************************************************
*** Method Name             : addingOrderLineItemsToOrder
*** Method Description      : This method is used to create orderlines from quotelines.
********************************************************************************************************************/
    
    Public static void addingOrderLineItemsToOrder(Map < ID, ID > orderMap, Map < id, Order > orderMapRecs, Map < ID, ID > assetProdctIDMap) {
        
        try {
            List < OrderItem > ordrLineItems = new List < OrderItem > ();
            List < Order > ordersList = new List < Order > ();
            Map < id, list < QuoteLineItem >> quotelineitemMap = new map < id, list < QuoteLineItem >> ();
            for (QuoteLineItem quoteLineItem: [SELECT ID, Quantity, LineNumber__c, NestedLineNumber__c, PricebookEntryId, Product2.ProductCode, Product2Id, RecordId__c, Description, QuoteId, ListPrice, TotalPrice, UnitPrice FROM QuoteLineItem
                                               WHERE QuoteId IN: orderMap.values()]) {                     
                                                   if (quotelineitemMap.containskey(orderMapRecs.get(quoteLineItem.QuoteId).id)) {
                                                       list < QuoteLineItem > quotelist = quotelineitemMap.get(orderMapRecs.get(quoteLineItem.QuoteId).id);
                                                       quotelist.add(quoteLineItem);
                                                       quotelineitemMap.put(orderMapRecs.get(quoteLineItem.QuoteId).id, quotelist);
                                                   }
                                                   else{
                                                       quotelineitemMap.put(orderMapRecs.get(quoteLineItem.QuoteId).id, new list < QuoteLineItem > {
                                                           quoteLineItem});
                                                   }
                                               }
            for (order ordId: [select id, status from order where id IN: quotelineitemMap.keyset()]) {
                for (quoteLineItem quoteline: quotelineitemMap.get(ordId.id)) {
                    OrderItem ordrItem = new OrderItem();
                    ordrItem.LineNumber__c = quoteline.LineNumber__c;
                    if(assetProdctIDMap.containskey(quoteline.Product2Id)){
                        ordrItem.Asset__c = assetProdctIDMap.get(quoteline.Product2Id);  
                    }                    
                    ordrItem.NestedLineNumber__c = quoteline.NestedLineNumber__c;
                    ordrItem.RecordId__c = quoteline.RecordId__c;
                    ordrItem.Description = quoteline.Description;
                    ordrItem.OrderId = ordId.id;
                    ordrItem.PricebookEntryId = quoteline.PricebookEntryId;
                    ordrItem.Product2Id = quoteline.Product2Id;
                    ordrItem.Quantity = quoteline.Quantity;
                    ordrItem.QuoteLineItemId = quoteline.Id;
                    ordrItem.UnitPrice = quoteline.UnitPrice;
                    // Start of CCRM-3463
                    ordrItem.Price_After_Discount__c =quoteLine.TotalPrice;
                    // End of CCRM-3463
                    ordrLineItems.add(ordrItem);
                    System.debug(ordrLineItems);
                }
                ordId.Status = System.Label.Order_status_Activated;
                ordersList.add(ordId);
            }
            if (ordrLineItems.size() > 0) {
                insert ordrLineItems;
                
                if (ordersList.size() > 0) {
                    update ordersList;
                }
            }
            
        } catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Map<String,ID>'), string.valueOf(assetProdctIDMap), String.valueof('Map<ID,ID>'), String.valueof(orderMap), String.valueof('Map<id,Order>'), String.valueof(orderMapRecs), null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
}