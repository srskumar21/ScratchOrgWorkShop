/**************************************************************************************************
*** Class Name             : OpportunityTriggerHelper
*** Class Description      : This Helper class is invoked from the trigger when trigger events are
fired.
*** Author                 : Sreenath Dhanireddy
*** Class Created Date     : 30/07/2019
*            Modified Date : 28/02/2020 
*            Modified By   : Sreenath Dhanireddy
*			 Ticket Number : CCRM-3413
**************************************************************************************************/

public class OpportunityTriggerHelper {
    Public Static final String Order_Status ='Draft';
    public static final String LineOfBusiness = 'GSS';
    public Static final String LineOfBusinessRegion = 'NA';
    
    /************************************************************************************************
*** Method Name             : updateOpportunityPriceBook
*** Method Description      : This method update the Opportunity's price book based on Opportunity
CurrencyIsoCode, Account Billing Country and Line of Business of LOB 
for the opportunities passed as parameters 
**************************************************************************************************/
    public static void updateOpportunityPriceBook(List<Opportunity> oppList){
        Set<ID> accIdSet =new Set<ID>();
        Set<ID> lobIdSet =new Set<ID>();
        
        try {
            for(opportunity opp :oppList){
                lobIdSet.add(opp.Line_Of_Business__c);
                accIdSet.add(opp.AccountID);
            }
            Map<ID, Account> accMap = new Map<ID, Account>([SELECT ID, BillingCountry FROM Account WHERE ID in :accIdSet]);
            Map<ID, Line_Of_Business__c> lobMap = new Map<ID, Line_Of_Business__c>([SELECT ID, Name, Line_of_Business__c, Region__c 
                                                                                    FROM Line_Of_Business__c 
                                                                                    WHERE ID in :lobIdSet]);
            List<Opportunity_Pricebook__c> oppPBList = Opportunity_Pricebook__c.getAll().values();
            Map<Opportunity, String> oppToPBNameMap = new Map<Opportunity, String>();
            for (Opportunity oppty : oppList) {
                if(oppty.Line_Of_Business__c != NULL){
                    Line_Of_Business__c lob = lobMap.get(oppty.Line_Of_Business__c); 
                    for (Opportunity_Pricebook__c pb : oppPBList) {
                        //Start Of CCRM-2132
                        if(lob.Line_of_Business__c == LineOfBusiness && pb.Line_Of_Business_Type__c == LineOfBusiness && 
                           lob.Region__c == LineOfBusinessRegion && pb.LOB_Region__c == LineOfBusinessRegion){                           
                               oppToPBNameMap.put(oppty, pb.Price_Book__c);
                           }
                        //End of CCRM-2132
                        else if ((String.isEmpty(pb.Currency_Code__c) || pb.Currency_Code__c == oppty.CurrencyIsoCode) &&
                                 (String.isEmpty(pb.Line_Of_Business_Type__c) || pb.Line_Of_Business_Type__c == lob.Line_of_Business__c) &&
                                 (String.isEmpty(pb.Country__c) || pb.Country__c == accMap.get(oppty.AccountId).BillingCountry) &&
                                 (pb.LOB_Region__c == lob.Region__c)) {
                                     oppToPBNameMap.put(oppty, pb.Price_Book__c);
                                 }else if((String.isEmpty(pb.Currency_Code__c) || pb.Currency_Code__c == oppty.CurrencyIsoCode) &&
                                          (String.isEmpty(pb.Line_Of_Business_Type__c) || pb.Line_Of_Business_Type__c == lob.Line_of_Business__c) &&
                                          (String.isEmpty(pb.Country__c)) &&
                                          (pb.LOB_Region__c == lob.Region__c)){
                                              oppToPBNameMap.put(oppty, pb.Price_Book__c);
                                          }
                    }
                }
                else {
                    for (Opportunity_Pricebook__c pb : oppPBList) {
                        if ((String.isEmpty(pb.Currency_Code__c) || pb.Currency_Code__c == oppty.CurrencyIsoCode) &&
                            (String.isEmpty(pb.Country__c) || pb.Country__c == accMap.get(oppty.AccountId).BillingCountry)) {
                                // do nothing
                            }else if((String.isEmpty(pb.Currency_Code__c) || pb.Currency_Code__c == oppty.CurrencyIsoCode) &&
                                     (String.isEmpty(pb.Country__c))){
                                     }
                    }
                }
            }
            
            Map<String, ID> pbNameToId = new Map<String, ID>();
            for(Pricebook2 pb : [SELECT ID, Name FROM Pricebook2 WHERE IsActive = TRUE AND Name IN : oppToPBNameMap.values()]) {
                pbNameToId.put(pb.Name, pb.ID);
            }
            for (Opportunity opp : oppToPBNameMap.keySet()) {
                opp.Pricebook2Id = pbNameToId.get(oppToPBNameMap.get(opp));
            }
        }catch (Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Opportunity>'), string.valueOf(oppList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), oppList, null, inputFromMethodParameters);
        } 
    }
    
    /****************************************************************************************************
*** Method Name             : assetCreationOppClosedWon
*** Method Description      : This method will create the Assets when Opportunity StageName isClosed Won 
and Product Do Not Create Asset is FALSE and only for Covetrus Accounts.
we are updating the account field 'Associated Line of business' field using
'Line of business field' on Opportunity.
*********************************************************************************************************/
    public static void assetCreationOppClosedWon(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap){        
        try 
        {
            //Start of CCRM-3110
            String accRecTypeName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getName();
            set<Id> nonProspectAccIds = new Set<Id>();
            Set<Id> accIds = new Set<Id>();
            List<Account> acntList = new List<Account>();
            Map<ID, Opportunity> oppIdSet = new Map<ID, Opportunity>();
            Map<ID,Asset> assetRecMap =new Map<ID,Asset>();
            Set<Id> closedOppIDs = new Set<Id>();
            for(Opportunity opp : oppList){
                if(opp.AccountID != NULL) {
                    accIds.add(opp.accountID);
                }
                if(opp.StageName != oldOppMap.get(opp.id).StageName){
                    closedOppIDs.add(opp.id);                    
                }
            }
            Map<Id,Account> mapAccount=new Map<Id,Account>([Select Id,Recordtype.Name,Associated_Line_of_Businesses__c,(SELECT id,name,stagename,Line_of_Business__r.name 
                                                                                                                        FROM Opportunities WHERE StageName =: System.Label.Opportunity_Stage_Name AND Id NOT IN (SELECT OpportunityId FROM Order) ) 
                                                            FROM Account where Id IN :accIds]);
            System.debug('mapAccount:-'+mapAccount);  
            for(Account accId : mapAccount.values()){
                String assLineOfBusiness= '';
                for(Opportunity oppty :accId.opportunities){
                    if(String.isNotBlank(oppty.Line_of_Business__r.name)){
                        if(accId.RecordType.Name != accRecTypeName && oppty.stagename == System.Label.Opportunity_Stage_Name && closedOppIDs.contains(oppty.id)){
                            nonProspectAccIds.add(accId.Id);
                            If(String.isNotBlank(accId.Associated_Line_of_Businesses__c)){
                                if(!accId.Associated_Line_of_Businesses__c.Contains(oppty.Line_of_Business__r.name) && 
                                   !assLineOfBusiness.Contains(oppty.Line_of_Business__r.name)){
                                       assLineOfBusiness = accId.Associated_Line_of_Businesses__c+';'+oppty.Line_of_Business__r.name;
                                   }
                            }
                            else{
                                if (!assLineOfBusiness.Contains(oppty.Line_of_Business__r.name)) {
                                    assLineOfBusiness = assLineOfBusiness +';'+oppty.Line_of_Business__r.name;
                                }
                            }
                        }  
                        if(String.isNotBlank(assLineOfBusiness)){
                            accId.Associated_Line_of_Businesses__c = assLineOfBusiness;
                        }
                    }
                    
                }  
                acntList.add(accId);
            }
            if(acntList.Size()>0){
                update acntList;
            }
            
            //End of CCRM-3110
            for (Opportunity opp : oppList) {
                if(opp.StageName == System.Label.Opportunity_Stage_Name && 
                   opp.StageName != oldOppMap.get(opp.Id).StageName  && nonProspectAccIds.contains(opp.AccountId)){
                       oppIdSet.put(opp.ID, null);
                   }
            }
            if (!oppIdSet.isEmpty()) {
                Map<String, String> assetRecdMap = new Map<String, String>();
                for(Asset_Record_Types__c assRecType : Asset_Record_Types__c.getAll().values()){
                    assetRecdMap.put(assRecType.Name, assRecType.Asset_Record_Type__c);
                }
                oppIdSet = new Map<Id, Opportunity>([SELECT ID, AccountId, Line_of_Business__c, Line_of_Business__r.Name, Line_of_Business__r.Line_of_Business__c, Line_of_Business__r.Region__c, CloseDate,
                                                     (SELECT ID,
                                                      PricebookEntry.product2.Description,
                                                      PricebookEntry.product2.Name,
                                                      PricebookEntry.Product2.ID,
                                                      PricebookEntry.Product2.ProductCode,
                                                      PricebookEntry.product2.ERP_Product_Number__c, Quantity, 
                                                      PricebookEntry.product2.Family,
                                                      PricebookEntry.product2.Manufacturer__c,
                                                      //Start of 2941
                                                      PricebookEntry.product2.Asset_Type__c,
                                                      PricebookEntry.product2.Enabled_by_Default__c,
                                                      //End of 2941
                                                      //Start of CCRM-2820
                                                      PricebookEntry.Product2.Hardware_Express_Price__c,
                                                      //End of CRM-2820
                                                      PricebookEntry.Product2.Manufacturer_Item_Number__c,
                                                      PricebookEntry.Product2.Implementation_Plan_Template__c,
                                                      PricebookEntry.Product2.Implementation_Plan_Template__r.OwnerId,
                                                      PricebookEntry.Product2.Implementation_Plan_Template__r.Name FROM OpportunityLineItems
                                                      WHERE PricebookEntry.Product2.Do_Not_Create_Asset__c = false
                                                     )
                                                     FROM Opportunity WHERE ID in :oppIdSet.keySet()]);
                system.debug('oppIdSet'+oppIdSet);                
                Id ownerId = [SELECT ID FROM GROUP WHERE Name = 'GSS NA Implementations Team'].ID;                
                List<Asset> assetList = new List<Asset>();
                Map<Integer, Implementation_Plan__c> implementationPlans = new Map<Integer, Implementation_Plan__c>();
                for(Opportunity opp : oppIdSet.values()) {
                    for (OpportunityLineItem lineItem : opp.OpportunityLineItems) {
                        if(assetRecdMap.containsKey(lineItem.PricebookEntry.product2.Family)){
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
                            //Start of CCRM-2820
                            asst.Hardware_Express_Price__c = lineItem.PricebookEntry.Product2.Hardware_Express_Price__c;
                            //End of CCRM-2820
                            asst.Manuafacturer_Item_Number__c = lineItem.PricebookEntry.Product2.Manufacturer_Item_Number__c;
                            //Start of CCRM-2941
                            asst.Asset_Type__c = lineItem.PricebookEntry.Product2.Asset_Type__c;
                            if(lineItem.PricebookEntry.Product2.Enabled_by_Default__c == true)
                                asst.Software_Status__c = System.Label.Asset_status_enabled;
                            else
                                asst.Software_Status__c = System.Label.Asset_status_disabled;
                            //End of CCRM-2941
                            assetList.add(asst);    
                            // only GSS NA for now
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
                    
                    for(Asset astRec : assetList){
                        assetRecMap.put(astRec.Id,astRec);
                    }                    
                    if (!implementationPlans.isEmpty()) {
                        // go through and insert the implementation plans - updating the asset ids on them first
                        for (Integer implementationPlan : implementationPlans.keySet()) {
                            implementationPlans.get(implementationPlan).Asset__c = assetList[implementationPlan].Id;
                        }
                        insert implementationPlans.values();
                    }
                }                
                orderCreationOppClosedWon(oppIdSet.keyset(),assetRecMap);
                
                
            }
        }catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Opportunity>'), string.valueOf(oppList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), oppList, null, inputFromMethodParameters);            
        } 
    }
    
    /************************************************************************************************
*** Method Name             : updateOpportunityOwner
*** Method Description      : This method will update the opportunity owner based on record type 
Custom setting value.
**************************************************************************************************/
    public static void updateOpportunityOwner(List<Opportunity> oppList){
        try{
            VIOpportunity__c viOpp = [SELECT Name, SetupOwnerId FROM VIOpportunity__c LIMIT 1];
            string recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Opportunity').getRecordTypeId();
            for(opportunity opp :oppList){
                if(opp.RecordTypeid == recordtypeId){
                    opp.OwnerId = viOpp.SetupOwnerId;
                }
            }
        }catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Opportunity>'), string.valueOf(oppList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), oppList, null, inputFromMethodParameters);
            
        } 
    }
    /************************************************************************************************
*** Method Name             : checkQuoteStatus
*** Method Description      : This method is to display error when opportunity has more than one quote with "Accepted" status
**************************************************************************************************/
    //Start of CCRM-3788
    public static void checkQuoteStatus(List<Opportunity> OptyList){
        try{
            Map<Id,List<Quote>> quotesMap = new Map<Id,List<Quote>>();
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
            String opportunityRecordType = 'Technology';
            String QuoteStatus = 'Accepted';
            String OpportunityStageName = 'Closed Won';
            Map < ID, Schema.RecordTypeInfo > rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
            //Start of CCRM-3413
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
           
            if(profileName != System.Label.GPM_Sales_NA){
             //End of CCRM-3413
                for(opportunity oppnty :OptyList){
                    if(rt_map.get(oppnty.recordTypeID).getName().containsIgnoreCase(opportunityRecordType) && oppnty.StageName == OpportunityStageName){
                        OpportunityMap.put(oppnty.id,oppnty);	 
                    }            		            
                }
                for(Quote quteList : [SELECT id,opportunityid, IsSyncing 
                                      FROM Quote 
                                      WHERE opportunityId =:OpportunityMap.keyset() AND Status =: QuoteStatus]){                        
                                          if(quotesMap.Containskey(quteList.opportunityid)){
                                              List<Quote> quoteRecLists = quotesMap.get(quteList.opportunityid);
                                              quoteRecLists.add(quteList);
                                              quotesMap.put(quteList.opportunityid,quoteRecLists);
                                          }
                                          else{
                                              quotesMap.put(quteList.opportunityid,new List<Quote>{quteList});  
                                          }
                                      }
                
                for(Opportunity oppid : OpportunityMap.Values()){
                    List<Quote> quteRecs =quotesMap.get(oppid.id);
                    if(quteRecs == NULL){
                        OpportunityMap.get(oppid.id).addError('In order to close this Opportunity, you must have at least one Quote which is Accepted and Synced'); 
                    }
                    else if(quteRecs.size()>1){
                        OpportunityMap.get(oppid.id).addError('In order to close this Opportunity, you must have only one Quote which is Accepted and Synced');                
                    } 
                    else if(quteRecs.size()==1){
                        for(Quote quoteRecord : quteRecs){
                            System.debug('quoteRecord:-'+quoteRecord);
                            if(quoteRecord.IsSyncing == False){
                                OpportunityMap.get(oppid.id).addError('In order to close this Opportunity, you must sync the Accepted Quote');                  
                            }
                        }
                    }
                }        
            }
        }
        Catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Opportunity>'), string.valueOf(OptyList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
            
        }
    }
    
    //End of CCRM-3788
    
    /************************************************************************************************
*** Method Name             : orderCreationOppClosedWon
*** Method Description      : This method will Create the Order when opportunity is Closed Won.
**************************************************************************************************/
    
    //CCRM - 2694
    public static void orderCreationOppClosedWon(Set<ID> oppIds,Map<ID,Asset> assetRecMap){
        System.debug('oppIds:-'+oppIds);
        try {
            Map<ID,ID> ordrQuoteIdMap = new Map<ID,ID>();
            Map<ID,order> orderMapRecs = new Map<ID,Order>();
            Map<ID,ID> assetProdCodeMap =new Map<ID,ID>();
            if (!oppIds.isEmpty()) {                
                List<quote> QuoteList = [SELECT Id,name,OpportunityId,AccountId,BillingName,opportunity.closedate,BillingCity,BillingCountry,BillingPostalCode,
                                         BillingStreet,Description,ContactId,OwnerId,TotalPrice,Pricebook2Id,ShippingCity,ShippingCountry,BillingState,
                                         ShippingPostalCode,ShippingState,ShippingStreet,opportunity.currencyisocode,opportunity.CreatedById
                                         // Start of CCRM-3788 --Added condition to create order when Status ='Accepted'
                                         FROM Quote where opportunityid =: oppIds AND Status = 'Accepted' AND IsSyncing = True];
                // End of CCRM-3788
                List<Order> orderList = new List<Order>();
                // Start of CCRM-3788 Added condition to create orders only one quote With 'Accepted' status
                if(quoteList.size() == 1){
                    // End of CCRM-3788
                    for(quote quoteRec : quoteList ){
                        order ordr = new order();
                        ordr.AccountId = quoteRec.AccountId;
                        ordr.OpportunityId =quoteRec.OpportunityId;
                        ordr.BillToContactId = quoteRec.ContactId;
                        ordr.BillingCity =quoteRec.BillingCity;
                        ordr.Billingcountry =quoteRec.Billingcountry;
                        ordr.BillingPostalCode =quoteRec.BillingPostalCode;
                        ordr.BillingState =quoteRec.BillingState;                        
                        ordr.BillingStreet =quoteRec.BillingStreet;
                        ordr.EffectiveDate =System.today();
                        ordr.Status =Order_Status;
                        ordr.QuoteId =quoteRec.id;
                        ordr.CompanyAuthorizedDate =quoteRec.opportunity.closedate;
                        ordr.Description = quoteRec.Description;
                        ordr.CurrencyIsoCode = quoteRec.opportunity.currencyisocode;
                        ordr.name=quoteRec.name;
                        ordr.ShippingCity=quoteRec.ShippingCity;
                        ordr.ShippingCountry=quoteRec.ShippingCountry;
                        ordr.ShippingPostalCode=quoteRec.ShippingPostalCode;
                        ordr.ShippingState=quoteRec.ShippingState;
                        ordr.ShippingStreet=quoteRec.ShippingStreet;
                        ordr.Pricebook2Id = quoteRec.Pricebook2Id;
                        //Start of CCRM-3704
                        ordr.OwnerId = quoteRec.opportunity.CreatedById;
                        //End of CCRM-3704
                        orderList.add(ordr);
                    } 
                    if (!orderList.isEmpty()) {                   
                        insert orderList;                   
                    }
                    if(assetRecMap.size() > 0 ){
                        for(Asset asetrecords : assetRecMap.values()){
                            assetProdCodeMap.put(asetrecords.Product2Id,asetrecords.Id); 
                        }
                    }
                    for(Order ordrRecrds : orderList){
                        ordrQuoteIdMap.put(ordrRecrds.id,ordrRecrds.QuoteId);
                        orderMapRecs.put(ordrRecrds.QuoteId,ordrRecrds);
                    }
                    addingOrderLineItemsToOrder(ordrQuoteIdMap,orderMapRecs,assetProdCodeMap);                          
                }
                
            }
        }catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Set<ID>'), string.valueOf(oppIds), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
            
        }
        
    }
    
    /************************************************************************************************
*** Method Name             : addingOrderLineItemsToOrder
*** Method Description      : This method will create OrderLine items using the Quoteline items values.
**************************************************************************************************/
    
    Public static void addingOrderLineItemsToOrder(Map<ID,ID> orderMap,Map<id,Order> orderMapRecs,Map<ID,ID> assetProdctIDMap){
        
        try{
            List<OrderItem> ordrLineItems=new List<OrderItem>();
            List<Order> ordersList = new List<Order>();
            Map<id,list<QuoteLineItem>> quotelineitemMap = new map<id,list<QuoteLineItem>>();
            for(QuoteLineItem quoteLineItem : [SELECT ID,Quantity,LineNumber__c,NestedLineNumber__c,PricebookEntryId,Product2.ProductCode,Product2Id,RecordId__c,Description,QuoteId,ListPrice,TotalPrice,UnitPrice 
                                               FROM QuoteLineItem 
                                               WHERE QuoteId IN: orderMap.values()]){
                                                   if(quotelineitemMap.containskey(orderMapRecs.get(quoteLineItem.QuoteId).id)){
                                                       list<QuoteLineItem> quotelist = quotelineitemMap.get(orderMapRecs.get(quoteLineItem.QuoteId).id);
                                                       quotelist.add(quoteLineItem);
                                                       quotelineitemMap.put(orderMapRecs.get(quoteLineItem.QuoteId).id,quotelist);
                                                   }
                                                   else{
                                                       quotelineitemMap.put(orderMapRecs.get(quoteLineItem.QuoteId).id,new list<QuoteLineItem> {quoteLineItem});
                                                   }
                                               }
            for(order ordId: [select id,status from order where id IN: quotelineitemMap.keyset()]){
                for(quoteLineItem quoteline: quotelineitemMap.get(ordId.id)){
                    OrderItem ordrItem = new OrderItem();
                    ordrItem.LineNumber__c=quoteline.LineNumber__c;
                    if(assetProdctIDMap.containsKey(quoteline.Product2Id)){
                        ordrItem.Asset__c = assetProdctIDMap.get(quoteline.Product2Id);
                    }                    
                    ordrItem.NestedLineNumber__c =quoteline.NestedLineNumber__c;
                    ordrItem.RecordId__c =quoteline.RecordId__c;
                    ordrItem.Description =quoteline.Description;
                    ordrItem.OrderId=ordId.id;
                    ordrItem.PricebookEntryId =quoteline.PricebookEntryId;
                    ordrItem.Product2Id=quoteline.Product2Id;
                    ordrItem.Quantity=quoteline.Quantity;
                    ordrItem.QuoteLineItemId =quoteline.Id;
                    ordrItem.UnitPrice =quoteline.UnitPrice;
                    // Start of CCRM-3463
                    ordrItem.Price_After_Discount__c =quoteLine.TotalPrice;
                    // End of CCRM-3463
                    ordrLineItems.add(ordrItem);
                    System.debug(ordrLineItems);                            
                }
                ordId.Status = System.Label.Order_status_Activated;
                ordersList.add(ordId);
            }
            if(ordrLineItems.size()>0){
                insert ordrLineItems;
                
                if(ordersList.size()>0){
                    update ordersList;     
                }        
            }
            
        } catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Map<String,ID>'), string.valueOf(assetProdctIDMap), String.valueof('Map<ID,ID>') , String.valueof(orderMap), String.valueof('Map<id,Order>'),String.valueof(orderMapRecs), null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
    
}