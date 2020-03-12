/*****************************************************************************************************
*** Class Name               :  LineOfBusinessAccountTriggerHelper
*** Class Description        :  This Helper class is invoked by LineOfBusinessAccountTrigger when the 
                                LineOfBusinessAccount record is inserted, updated or deleted.
*** Author                   :  Nagarjuna
*** Class Created Date       :  8/8/2019
*       Modified Date        :
*       Modified By          :
******************************************************************************************************/
public class LineOfBusinessAccountTriggerHelper {
    public static void doAfterUpdate(List<Line_Of_Business_Account__c> lobAccts, Map<Id, Line_Of_Business_Account__c> oldLobAccts) {
        updateProvetAccounts(new Map<Id, Line_Of_Business_Account__c>(lobAccts));
    }

    @testvisible
    private static void updateProvetAccounts(Map<Id, Line_Of_Business_Account__c> lobAcctsMap) {
        System.debug('Entering Processor');
        Map<Id, Account> acctToUpdate = new Map<Id, Account>();
        System.debug([SELECT Id,Name FROM Line_Of_Business__c where ID IN (SELECT Line_Of_Business__c FROM Line_Of_Business_Account__c)]);
        System.debug([select Id from Line_Of_Business_Account__c where Id in :lobAcctsMap.keySet() and Provet_Primary_Account__c = true and Line_Of_Business__r.Line_Of_Business__c LIKE '%CO%']);
        for (Line_Of_Business_Account__c lobA : [select Id from Line_Of_Business_Account__c where Id in :lobAcctsMap.keySet() and Provet_Primary_Account__c = true and Line_Of_Business__r.Line_Of_Business__c LIKE '%CO%']) {
            Line_Of_Business_Account__c lobAcct = lobAcctsMap.get(lobA.Id);
            Account acc = new Account();
                acc.Id = lobAcct.Account__c;
                acc.ABN__c = lobAcct.ABN__c;
                acc.BillingCity = lobAcct.Billing_City__c;
                acc.BillingCountry = lobAcct.Billing_Country__c;
                acc.BillingPostalCode = lobAcct.Billing_Postal_Code__c;
                acc.BillingState = lobAcct.Billing_State__c;
                acc.BillingStreet = lobAcct.Billing_Address_line_1__c;
                acc.CO_Credit_Limit__c = lobAcct.CO_Credit_Limit__c;
                acc.CO_Credit_Status__c = lobAcct.CO_Credit_Status__c;
                acc.Connect_Customer__c = lobAcct.Connect_Customer__c;
                acc.Corporate_Group__c = lobAcct.Corporate_Group__c;
                acc.Critical_Care__c = lobAcct.Critical_Care__c;
                acc.CurrencyIsoCode = lobAcct.CurrencyIsoCode;
                acc.Email__c = lobAcct.Email__c;
                acc.Fax = lobAcct.Fax__c;
                acc.Licensed_Veterinarian__c = lobAcct.Licensed_Veterinarian__c;
                //Number_of_Vets__c = lobAcct.Number_of_Vets__c;//
                acc.Phone = lobAcct.Phone__c;
                acc.Primary_Warehouse_Code__c = lobAcct.Primary_Warehouse_Code__c;
                acc.Primary_Warehouse_Name__c = lobAcct.Primary_Warehouse_Name__c;
                acc.Sales_Area__c = lobAcct.Sales_Area__c;
                acc.ShippingCity = lobAcct.Shipping_City__c;
                acc.ShippingCountry = lobAcct.Shipping_Country__c;
                acc.ShippingPostalCode = lobAcct.Shipping_Postal_Code__c;
                acc.ShippingState = lobAcct.Shipping_State__c;
                acc.ShippingStreet = lobAcct.Shipping_Address_line_1__c;
                acc.ProVet_Pricing_Type__c = lobAcct.ProVet_Pricing_Type__c;
                acc.Settlement_Discount__c = lobAcct.Settlement_Discount__c;
                acc.Vets_Registration_Number__c = lobAcct.Vets_Registration_Number__c;
                acc.Company_Region__c = lobAcct.Region__c;
                acc.OwnerId = lobAcct.Sales_Rep__c;
                acc.Provet_Points_Balance__c =lobAcct.Provet_Points_Balance__c;
                acc.Provet_Points_Grading__c = lobAcct.Provet_Points_Rate__c;
                if(lobAcct.Provet_Points_Plus__c != null){
                    acc.Provet_Plus_Grade__c = Integer.valueOf(lobAcct.Provet_Points_Plus__c);
                }
            acctToUpdate.put(lobAcct.Account__c,acc);
        }
        if (!acctToUpdate.isEmpty()) update acctToUpdate.values();
    }

/*************************************************************************************************************
*** Method Name             : accountTeamMembInit
*** Method Description      : This method creates the instance of Account Team Member with 'Sales/Service Rep'
as the roles.
***************************************************************************************************************/
    public static AccountTeamMember accountTeamMembInit(Id accountId, Id salesAndServRepId, String teamMembRole){
        AccountTeamMember accTeamMemb = new AccountTeamMember();
        accTeamMemb.AccountId = accountId;
        accTeamMemb.UserId = salesAndServRepId;
        accTeamMemb.AccountAccessLevel = Label.AccountAccessLevel;
        accTeamMemb.CaseAccessLevel = Label.CaseAccessLevel;
        accTeamMemb.OpportunityAccessLevel = Label.OpportunityAccessLevel;
        accTeamMemb.TeamMemberRole = teamMembRole;
        return accTeamMemb;
    }
    /*********************************************************************************************************
*** Method Name             : insertAccountForLOBAccount
*** Method Description      : This method creates Account Team Member with 'Sales/Service Rep'as the roles
based on 'Sales rep' & 'Primary Customer Service Rep' fields on LOBAccount.
***************************************************************************************************************/
    public static void insertAccountTeamForLOBAccount(List<Line_Of_Business_Account__c> lobAccountRecList){
        Map<Id,Id> salesIds = new Map<Id,Id>();
        Map<Id,Id> serviceIds = new Map<Id,Id>();
        for(Line_Of_Business_Account__c lobAccRec : lobAccountRecList){
            salesIds.put(lobAccRec.Account__c, lobAccRec.Sales_Rep__c);
            ServiceIds.put(lobAccRec.Account__c, lobAccRec.Primary_Customer_Service_Rep__c);
        }
        List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
        try{
            List<Line_Of_Business_Account__c> lobAccountRecSalesRepList = [SELECT id, Account__c, Sales_Rep__c 
                                                                             FROM Line_Of_Business_Account__c 
                                                                            WHERE Sales_Rep__c IN: serviceIds.values() 
                                                                              AND Account__c IN: serviceIds.keySet()];
            List<Line_Of_Business_Account__c> lobAccountRecServiceRepList = [SELECT id, Account__c, Primary_Customer_Service_Rep__c
                                                                             FROM Line_Of_Business_Account__c 
                                                                             WHERE Primary_Customer_Service_Rep__c IN: salesIds.values()
                                                                             AND Account__c IN: salesIds.keySet()]; 
            List<AccountTeamMember> salesAndServiceAccTeamList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                                  WHERE UserId IN: salesIds.values() AND  
                                                                  TeamMemberRole =: Label.AccountTeamRoleSalesAndService AND
                                                                  AccountId IN: salesIds.keySet()];
            for(Line_Of_Business_Account__c lobAccRecord:lobAccountRecList){
                if(lobAccRecord.Sales_Rep__c == lobAccRecord.Primary_Customer_Service_Rep__c && 
                   lobAccRecord.Sales_Rep__c != null && 
                   lobAccRecord.Primary_Customer_Service_Rep__c !=null){
                       accTeamList.add(accountTeamMembInit(lobAccRecord.Account__c, lobAccRecord.Sales_Rep__c, Label.AccountTeamRoleSalesAndService));
                   }
                else{
                    if(lobAccRecord.Sales_Rep__c != null){
                        if(lobAccountRecServiceRepList.size() > 0)
                            accTeamList.add(accountTeamMembInit(lobAccRecord.Account__c, lobAccRecord.Sales_Rep__c, Label.AccountTeamRoleSalesAndService));
                        else
                            accTeamList.add(accountTeamMembInit(lobAccRecord.Account__c, lobAccRecord.Sales_Rep__c, Label.AccountTeamRoleSales));    
                    }
                    if(lobAccRecord.Primary_Customer_Service_Rep__c != null){
                        if(lobAccountRecSalesRepList.size() > 0)
                            accTeamList.add(accountTeamMembInit(lobAccRecord.Account__c, lobAccRecord.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService));
                        else
                            accTeamList.add(accountTeamMembInit(lobAccRecord.Account__c, lobAccRecord.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                        system.debug('accTeamList '+ accTeamList); 
                        system.debug('accTeamList size'+ accTeamList.size());
                    }
                }
            }
            if(accTeamList.size() > 0){
                insert accTeamList;
            }
        }
        catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Line_Of_Business_Account__c>'), string.valueOf(lobAccountRecList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), lobAccountRecList, null, inputFromMethodParameters);
        }
    }
    /*******************************************************************************************************************
*** Method Name             : updateAccTeamForLOBAccount
*** Method Description      : This method updates Account Team Member record when the LOBAccount record is updated 
in 'Sales rep' & 'Primary Customer Service Rep' fields on LOBAccount.
************************************************************************************************************************/
    public static void updateAccTeamForLOBAccount(Map<Id,Line_Of_Business_Account__c> oldLobAccRecMap, Map<Id,Line_Of_Business_Account__c> newLobAccRecMap){
        Map<Line_Of_Business_Account__c,id> lobAccSalesAndServMap = new Map<Line_Of_Business_Account__c,id>();
        List<AccountTeamMember> accTeamMembList = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamsSalesAndServDelList = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamsSalesDelList = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamsServiceDelList = new List<AccountTeamMember>();
        List<AccountTeamMember> insertaccTeams = new List<AccountTeamMember>();
        try{
            Map<Id,Id> newSalesIds = new Map<Id,Id>();
            Map<Id,Id> newServiceIds = new Map<Id,Id>();
            for(Line_Of_Business_Account__c lobAccRec : newLobAccRecMap.values()){
                newSalesIds.put(lobAccRec.Account__c, lobAccRec.Sales_Rep__c);
                newServiceIds.put(lobAccRec.Account__c, lobAccRec.Primary_Customer_Service_Rep__c);
            }
            Map<Id,Id> oldSalesIds = new Map<Id,Id>();
            Map<Id,Id> oldServiceIds = new Map<Id,Id>();
            for(Line_Of_Business_Account__c lobAccRec : oldLobAccRecMap.values()){
                oldSalesIds.put(lobAccRec.Account__c, lobAccRec.Sales_Rep__c);
                oldServiceIds.put(lobAccRec.Account__c, lobAccRec.Primary_Customer_Service_Rep__c);
            }
            List<Line_Of_Business_Account__c> lobAccRecordList = [SELECT id, Account__c, Sales_Rep__c, Primary_Customer_Service_Rep__c FROM Line_Of_Business_Account__c 
                                                                  WHERE Primary_Customer_Service_Rep__c IN: oldServiceIds.values() 
                                                                  AND Sales_Rep__c IN: oldSalesIds.values() AND Account__c IN: oldSalesIds.keySet()];
            for(Line_Of_Business_Account__c lobAccount : lobAccRecordList){
                if(lobAccount.Sales_Rep__c == lobAccount.Primary_Customer_Service_Rep__c){
                    lobAccSalesAndServMap.put(lobAccount, lobAccount.Sales_Rep__c);
                }
            }
            List<AccountTeamMember> newAccTeamsSales = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId IN: newServiceIds.values() 
                                                     AND TeamMemberRole =: Label.AccountTeamRoleSales AND AccountId IN: newServiceIds.keySet()];
            List<AccountTeamMember> newAccTeamsService = [SELECT Id, UserId, AccountId FROM AccountTeamMember 
                                                       WHERE UserId IN: newSalesIds.values() AND TeamMemberRole =: Label.AccountTeamRoleService
                                                       AND AccountId IN: newSalesIds.keySet()];
            List<AccountTeamMember> accTeamsSales = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId IN: newServiceIds.values() 
                                                     AND AccountId IN: newServiceIds.keySet()];
            List<AccountTeamMember> accTeamsService = [SELECT Id, UserId, AccountId FROM AccountTeamMember 
                                                       WHERE UserId IN: oldServiceIds.values() AND 
                                                       AccountId IN: oldServiceIds.keySet()];
            List<AccountTeamMember> accTeamMembSalesAndService = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember 
                                                                  WHERE UserId IN: lobAccSalesAndServMap.values() AND 
                                                                  TeamMemberRole =:Label.AccountTeamRoleSalesAndService 
                                                                  AND AccountId IN: oldSalesIds.keySet()];
            List<Line_Of_Business_Account__c> servRepNewlobAccRecList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                                                      WHERE Primary_Customer_Service_Rep__c IN: newSalesIds.values() 
                                                                      AND Account__c IN: newServiceIds.keySet()];
            List<Line_Of_Business_Account__c> salesRepNewlobAccRecList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                                                       WHERE Sales_Rep__c IN: newServiceIds.values() 
                                                                       AND Account__c IN: newSalesIds.keySet()];
            List<Line_Of_Business_Account__c> ServReplobAccRecList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                                                      WHERE Primary_Customer_Service_Rep__c IN: oldSalesIds.values() 
                                                                      AND Account__c IN: oldServiceIds.keySet()];
            List<Line_Of_Business_Account__c> salesReplobAccRecList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                                                       WHERE Sales_Rep__c IN: oldServiceIds.values() 
                                                                       AND Account__c IN: oldSalesIds.keySet()];
            List<AccountTeamMember> oldAccSalesAndServiceAccTeamList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                                        WHERE UserId IN: newSalesIds.values() AND 
                                                                        TeamMemberRole =: Label.AccountTeamRoleSalesAndService AND
                                                                        AccountId IN: oldSalesIds.keySet()];
            List<AccountTeamMember> newAccSalesAndServiceAccTeamList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                                        WHERE UserId IN: newSalesIds.values() AND 
                                                                        TeamMemberRole =: Label.AccountTeamRoleSalesAndService AND 
                                                                        AccountId IN: newSalesIds.keySet()];
            List<AccountTeamMember> oldAccsalesAndServiceAccTeamForServList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                                               WHERE UserId IN: newServiceIds.values() AND 
                                                                               TeamMemberRole =: Label.AccountTeamRoleSalesAndService AND
                                                                               AccountId IN: oldServiceIds.keySet()];
            List<AccountTeamMember> newAccsalesAndServiceAccTeamForServList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                                               WHERE UserId IN: newServiceIds.values() AND 
                                                                               TeamMemberRole =: Label.AccountTeamRoleSalesAndService AND 
                                                                               AccountId IN: newServiceIds.keySet()];
            List<Line_Of_Business_Account__c> lobAccRecordSalesList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                                                       WHERE Sales_Rep__c IN: oldSalesIds.values() 
                                                                       AND Account__c IN: oldSalesIds.keySet()];
            List<Line_Of_Business_Account__c> lobAccRecordServiceList = [SELECT id, Account__c, Primary_Customer_Service_Rep__c FROM Line_Of_Business_Account__c 
                                                                         WHERE Primary_Customer_Service_Rep__c IN: oldServiceIds.values() 
                                                                         AND Account__c IN: oldServiceIds.keySet()];
            
            for(Line_Of_Business_Account__c lobAccRecordNew : newLobAccRecMap.values()){
                Line_Of_Business_Account__c lobAccRecordOld = oldLobAccRecMap.get(lobAccRecordNew.id);
                if(lobAccRecordOld.Sales_Rep__c == lobAccRecordOld.Primary_Customer_Service_Rep__c && 
                   lobAccRecordOld.Sales_Rep__c != null && lobAccRecordOld.Primary_Customer_Service_Rep__c != null){
                       if(lobAccSalesAndServMap.size() > 0){
                           if(lobAccSalesAndServMap.size() == 1 && lobAccRecordOld.Account__c == lobAccRecordNew.Account__c){
                               if(lobAccRecordNew.Sales_Rep__c != null && lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c && 
                                      lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                          accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                          accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                          accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordOld.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                      }
                                   else if(lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c && 
                                           lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                               accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordOld.Sales_Rep__c, Label.AccountTeamRoleSales));
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                           }
                                   else if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c && 
                                           lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                               accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                           }
                               }
                               if(lobAccRecordNew.Sales_Rep__c == null && lobAccRecordNew.Primary_Customer_Service_Rep__c != null &&
                                  (lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c ||
                                   lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c) ){
                                      accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                  }
                               if(lobAccRecordNew.Sales_Rep__c != null && 
                                  lobAccRecordNew.Primary_Customer_Service_Rep__c == null &&
                                  (lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c || 
                                   lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c)){
                                      accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                  }
                           }
                           else if(lobAccSalesAndServMap.size() > 1 &&
                                   lobAccRecordOld.Account__c == lobAccRecordNew.Account__c){
                               if(lobAccRecordNew.Sales_Rep__c != null && 
                                  lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c && 
                                      lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                          accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                          accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordOld.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                      }
                                   else if(lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c && 
                                           lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordOld.Sales_Rep__c, Label.AccountTeamRoleSales));
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                           }
                                   else if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c && 
                                           lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                               accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                           }
                               }
                               if(lobAccRecordNew.Sales_Rep__c == null && lobAccRecordNew.Primary_Customer_Service_Rep__c != null &&
                                  (lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c || lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c)){
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                                  }
                               if(lobAccRecordNew.Sales_Rep__c != null && lobAccRecordNew.Primary_Customer_Service_Rep__c == null &&
                                  (lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c || lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c)){
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                  }
                           }
                           else if(lobAccSalesAndServMap.size() == 1 && lobAccRecordOld.Account__c != lobAccRecordNew.Account__c){
                               if(lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c && 
                                  lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                      accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService));
                                  }
                               else if(lobAccRecordNew.Sales_Rep__c == null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                   if(newAccTeamsSales.size() > 0)
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService));
                                   else
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                               }
                               else if(lobAccRecordNew.Sales_Rep__c != null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c == null){
                                   accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                               }
                               else if(lobAccRecordNew.Sales_Rep__c != null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   accTeamsSalesAndServDelList.addAll(accTeamMembSalesAndService);
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                               }
                           }
                           else if(lobAccSalesAndServMap.size() > 1 && lobAccRecordOld.Account__c != lobAccRecordNew.Account__c){
                               if(lobAccRecordOld.Sales_Rep__c == lobAccRecordNew.Sales_Rep__c && 
                                  lobAccRecordOld.Primary_Customer_Service_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                      accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService));
                                  }
                               else if(lobAccRecordNew.Sales_Rep__c == null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                               }
                               else if(lobAccRecordNew.Sales_Rep__c != null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c == null){
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                               }
                               else if(lobAccRecordNew.Sales_Rep__c != null &&  lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales));
                                   accTeamMembList.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService));
                               }
                           }
                       }
                   }
                else if(lobAccRecordOld.Sales_Rep__c != lobAccRecordOld.Primary_Customer_Service_Rep__c && 
                        lobAccRecordNew.Sales_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c && 
                        lobAccRecordNew.Sales_Rep__c != null && lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                            if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c){
                                accTeamsServiceDelList.addAll(accTeamsService);
                                
                            }
                            else if(lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                                accTeamsSalesDelList.addAll(accTeamsSales);
                            }
                            insertaccTeams.add(accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, 
                                                                       Label.AccountTeamRoleSalesAndService)); 
                        }
                else{
                    if(lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c){
                        if(lobAccRecordSalesList.size() > 0){
                            if(lobAccRecordSalesList.size() == 1 && (lobAccRecordOld.Account__c == lobAccRecordNew.Account__c) 
                               && (lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c) && (lobAccRecordNew.Sales_Rep__c != null )){
                                   AccountTeamMember accTeamupdate; 
                                   if(ServReplobAccRecList.size() > 0 || lobAccRecordNew.Primary_Customer_Service_Rep__c == lobAccRecordNew.Sales_Rep__c)
                                       accTeamupdate = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService);
                                   else
                                       accTeamupdate = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales);
                                   if(oldAccSalesAndServiceAccTeamList.size() != 1){
                                       accTeamsSalesDelList.addAll(accTeamsSales);
                                       accTeamMembList.add(accTeamupdate);
                                   }
                               }
                            else if(lobAccRecordSalesList.size() > 1 && (lobAccRecordOld.Account__c == lobAccRecordNew.Account__c) &&
                                    (lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c) && lobAccRecordNew.Sales_Rep__c != null){
                                        AccountTeamMember insertAccTeamRecentVal;
                                        if(ServReplobAccRecList.size() > 0 || lobAccRecordNew.Primary_Customer_Service_Rep__c == lobAccRecordNew.Sales_Rep__c)
                                            insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService);
                                        else
                                            insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales);
                                        if(oldAccSalesAndServiceAccTeamList.size() != 1)
                                            accTeamMembList.add(insertAccTeamRecentVal);
                                    }
                            else if(lobAccRecordSalesList.size() == 1 && (lobAccRecordOld.Account__c != lobAccRecordNew.Account__c)){
                                if(lobAccRecordNew.Sales_Rep__c != null){
                                    AccountTeamMember accTeamupdate;
                                    if(servRepNewlobAccRecList.size() > 0 || lobAccRecordNew.Primary_Customer_Service_Rep__c == lobAccRecordNew.Sales_Rep__c)
                                        accTeamupdate = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService);
                                    else
                                        accTeamupdate = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales);
                                    if(newAccSalesAndServiceAccTeamList.size() != 1){
                                        accTeamsSalesDelList.addAll(accTeamsSales);
                                        accTeamMembList.add(accTeamupdate);
                                    }    
                                }
                                if(lobAccRecordNew.Sales_Rep__c == null){
                                    if(oldAccSalesAndServiceAccTeamList.size() != 1)
                                        accTeamsSalesDelList.addAll(accTeamsSales);
                                }
                            }
                            else if(lobAccRecordSalesList.size() > 1 && (lobAccRecordOld.Account__c != lobAccRecordNew.Account__c) && 
                                    lobAccRecordOld.Sales_Rep__c != lobAccRecordNew.Sales_Rep__c && lobAccRecordNew.Sales_Rep__c != null){
                                        AccountTeamMember insertAccTeamRecentVal;
                                        if(servRepNewlobAccRecList.size() > 0)
                                            insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService);
                                        else
                                            insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales);
                                        if(newAccSalesAndServiceAccTeamList.size() != 1)
                                            accTeamMembList.add(insertAccTeamRecentVal);                
                                    }
                            
                            else if(lobAccRecordSalesList.size() == 1 && (lobAccRecordNew.Sales_Rep__c == null)){
                                if(oldAccSalesAndServiceAccTeamList.size() != 1)
                                    accTeamsSalesDelList.addAll(accTeamsSales);
                            }
                            else if(lobAccRecordNew.Sales_Rep__c != null && lobAccRecordOld.Sales_Rep__c == null){
                                AccountTeamMember insertAccTeamRecentVal;
                                if(ServReplobAccRecList.size() > 0 && servRepNewlobAccRecList.size() > 0)
                                    insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSalesAndService);
                                else
                                    insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Sales_Rep__c, Label.AccountTeamRoleSales);
                                if(newAccSalesAndServiceAccTeamList.size() != 1 && oldAccSalesAndServiceAccTeamList.size() != 1)
                                    accTeamMembList.add(insertAccTeamRecentVal);
                            }
                        }
                    }
                    if(lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c){
                           if(lobAccRecordServiceList.size() > 0){
                               if(lobAccRecordServiceList.size() == 1 && (lobAccRecordOld.Account__c == lobAccRecordNew.Account__c) 
                                  && (lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c)
                                  && (lobAccRecordNew.Primary_Customer_Service_Rep__c != null )){
                                      AccountTeamMember accTeamupdate;
                                      if(salesReplobAccRecList.size() > 0 || lobAccRecordNew.Sales_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c)
                                          accTeamupdate = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService);
                                      else
                                          accTeamupdate = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService);
                                      if(oldAccsalesAndServiceAccTeamForServList.size() != 1){
                                          accTeamsServiceDelList.addAll(accTeamsService);
                                          accTeamMembList.add(accTeamupdate);
                                      }
                                      
                                  }
                               else if(lobAccRecordServiceList.size() > 1 && (lobAccRecordOld.Account__c == lobAccRecordNew.Account__c) &&
                                       (lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c) 
                                       && lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                           AccountTeamMember insertAccTeamRecentVal;
                                           if(salesReplobAccRecList.size() > 0 || lobAccRecordNew.Sales_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c)
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService);
                                           else
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordOld.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService);
                                           if(oldAccsalesAndServiceAccTeamForServList.size() != 1)
                                               accTeamMembList.add(insertAccTeamRecentVal);
                                       }
                               else if(lobAccRecordServiceList.size() == 1 && (lobAccRecordOld.Account__c != lobAccRecordNew.Account__c)){
                                   if(lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                       AccountTeamMember accTeamupdate;
                                       if(salesRepNewlobAccRecList.size() > 0 || lobAccRecordNew.Sales_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c)
                                           accTeamupdate = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService);
                                       else
                                           accTeamupdate = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService);
                                       if(newAccsalesAndServiceAccTeamForServList.size() != 1){
                                           accTeamsServiceDelList.addAll(accTeamsService);
                                           accTeamMembList.add(accTeamupdate);
                                       }
                                       
                                   }
                                   if(lobAccRecordNew.Primary_Customer_Service_Rep__c == null){
                                       if(oldAccsalesAndServiceAccTeamForServList.size() != 1)
                                           accTeamsServiceDelList.addAll(accTeamsService);
                                   }
                               }
                               
                               else if(lobAccRecordServiceList.size() > 1 && (lobAccRecordOld.Account__c != lobAccRecordNew.Account__c) && 
                                       lobAccRecordOld.Primary_Customer_Service_Rep__c != lobAccRecordNew.Primary_Customer_Service_Rep__c 
                                       && lobAccRecordNew.Primary_Customer_Service_Rep__c != null){
                                           AccountTeamMember insertAccTeamRecentVal;
                                           if(salesRepNewlobAccRecList.size() > 0 || lobAccRecordNew.Sales_Rep__c == lobAccRecordNew.Primary_Customer_Service_Rep__c)
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService);
                                           else
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService);
                                           if(newAccsalesAndServiceAccTeamForServList.size() != 1)
                                               accTeamMembList.add(insertAccTeamRecentVal);                
                                       }
                               
                               else if(lobAccRecordServiceList.size() == 1 && (lobAccRecordNew.Primary_Customer_Service_Rep__c == null)){
                                   if(oldAccsalesAndServiceAccTeamForServList.size() != 1)
                                       accTeamsServiceDelList.addAll(accTeamsService);
                               }
                               else if(lobAccRecordNew.Primary_Customer_Service_Rep__c != null && 
                                       lobAccRecordOld.Primary_Customer_Service_Rep__c == null){
                                           AccountTeamMember insertAccTeamRecentVal;       
                                           if(salesReplobAccRecList.size() > 0)
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleSalesAndService);
                                           else
                                               insertAccTeamRecentVal = accountTeamMembInit(lobAccRecordNew.Account__c, lobAccRecordNew.Primary_Customer_Service_Rep__c, Label.AccountTeamRoleService);
                                           if(newAccsalesAndServiceAccTeamForServList.size() != 1)
                                               accTeamMembList.add(insertAccTeamRecentVal);
                                       }
                           }
                       }
                }
            }
            if(accTeamsSalesAndServDelList.size() > 0)
                delete accTeamsSalesAndServDelList;
            if(accTeamsSalesDelList.size() > 0)
                delete accTeamsSalesDelList;
            if(accTeamsServiceDelList.size() > 0)
                delete accTeamsServiceDelList;
            if(insertaccTeams.size() > 0)
                insert insertaccTeams;
            if(accTeamMembList.size() > 0)
                insert accTeamMembList;
        }
        catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('Map<Id,Line_Of_Business_Account__c>'), string.valueOf(oldLobAccRecMap), string.valueOf('Map<Id,Line_Of_Business_Account__c>'), string.valueOf(newLobAccRecMap), null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
    /*******************************************************************************************************************
*** Method Name             : deleteAccTeamMemb
*** Method Description      : This method deletes Account Team Member record when the LOBAccount record is deleted
************************************************************************************************************************/
    public static void deleteAccTeamMemb(List<Line_Of_Business_Account__c> lobAccRecList){
        List<AccountTeamMember> salesAccountTeams = new List<AccountTeamMember>();
        List<AccountTeamMember> serviceAccountTeams = new List<AccountTeamMember>();
        Map<Id,Id> salesRepMap = new Map<Id,Id>();
        Map<Id,Id> serviceRepMap = new Map<Id,Id>();
        Set<Id> salesAndServiceRepIds = new Set<Id>();
        Set<Id> salesRepIds = new set<Id>();
        Set<Id> accountIds = new set<Id>();
        Set<Id> salesServAccIds = new set<Id>();
        Set<Id> custServRepIds = new set<Id>();
        Set<Id> accIds = new set<Id>();
        List<AccountTeamMember> salesAndServAccTeamList;
        List<AccountTeamMember> salesAndServAccTeamMembList;
        List<AccountTeamMember> accTeamMembList;
        List<Line_Of_Business_Account__c> lobAccRecordList = new List<Line_Of_Business_Account__c>();
        List<AccountTeamMember> custServAccTeamMembList;
        List<Line_Of_Business_Account__c> lobAccountRecordList = new List<Line_Of_Business_Account__c>();
        List<AccountTeamMember> accTeamMembSalesAndServList ;
        List<Line_Of_Business_Account__c> lobAccountRecSalesRepList;
        List<Line_Of_Business_Account__c> lobAccountRecServiceRepList;
        List<Line_Of_Business_Account__c> lobAccRecSalesServRepList = new List<Line_Of_Business_Account__c>();
        try{     
            for(Line_Of_Business_Account__c lobAccRecordOld : lobAccRecList){
                salesRepIds.add(lobAccRecordOld.Sales_Rep__c);
                accountIds.add(lobAccRecordOld.Account__c);
                salesRepMap.put(lobAccRecordOld.Sales_Rep__c, lobAccRecordOld.Account__c);
                custServRepIds.add(lobAccRecordOld.Primary_Customer_Service_Rep__c);
                accIds.add(lobAccRecordOld.Account__c);
                serviceRepMap.put(lobAccRecordOld.Primary_Customer_Service_Rep__c, lobAccRecordOld.Account__c);
                if(lobAccRecordOld.Sales_Rep__c == lobAccRecordOld.Primary_Customer_Service_Rep__c){
                    salesAndServiceRepIds.add(lobAccRecordOld.Primary_Customer_Service_Rep__c);
                    salesServAccIds.add(lobAccRecordOld.Account__c);
                }
            }
            if(salesAndServiceRepIds.size() > 0){
                
                accTeamMembSalesAndServList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE UserId IN:salesRepIds
                                               AND TeamMemberRole=:Label.AccountTeamRoleSalesAndService AND AccountId IN:accountIds];
                lobAccRecSalesServRepList = [SELECT id, Account__c, Sales_Rep__c,Primary_Customer_Service_Rep__c FROM Line_Of_Business_Account__c 
                                             WHERE Sales_Rep__c IN:salesAndServiceRepIds AND 
                                             Primary_Customer_Service_Rep__c IN:salesAndServiceRepIds AND Account__c IN: salesServAccIds];
                lobAccountRecSalesRepList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c 
                                             WHERE Sales_Rep__c IN:salesRepIds AND Account__c IN: accountIds];
                lobAccountRecServiceRepList = [SELECT id, Account__c, Primary_Customer_Service_Rep__c FROM Line_Of_Business_Account__c
                                               WHERE Sales_Rep__c IN:custServRepIds AND Account__c IN: accIds];
                
            }
            else{
                if(salesRepIds.size() > 0){
                    
                    salesAndServAccTeamList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                               WHERE UserId IN:salesRepIds AND TeamMemberRole =: Label.AccountTeamRoleSalesAndService 
                                               AND AccountId IN:accountIds];
                    accTeamMembList = [SELECT id, userId FROM AccountTeamMember WHERE UserId IN:salesRepIds AND AccountId IN:accountIds];
                    lobAccRecordList = [SELECT id, Account__c, Sales_Rep__c FROM Line_Of_Business_Account__c WHERE Sales_Rep__c IN: 
                                        salesRepIds AND Account__c IN: accountIds];
                }
                if(custServRepIds.size() > 0){
                    salesAndServAccTeamMembList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember
                                                   WHERE UserId IN:custServRepIds AND TeamMemberRole =: Label.AccountTeamRoleSalesAndService 
                                                   AND AccountId IN:accIds];
                    custServAccTeamMembList = [SELECT id, userId FROM AccountTeamMember WHERE UserId IN:custServRepIds AND AccountId IN:accIds];
                    lobAccountRecordList = [SELECT id, Account__c, Primary_Customer_Service_Rep__c FROM Line_Of_Business_Account__c 
                                            WHERE Primary_Customer_Service_Rep__c IN: custServRepIds AND Account__c IN: accIds];
                }
            }
            if(lobAccRecordList.size() == 1){
                if(salesAndServAccTeamList.size() != 1)
                    delete accTeamMembList;            
            }
            
            if(lobAccountRecordList.size() == 1){
                if(salesAndServAccTeamMembList.size() != 1)
                    delete custServAccTeamMembList;            
            }
            if(lobAccRecSalesServRepList.size() == 1){
                if(lobAccountRecSalesRepList.size() > 2 && lobAccountRecServiceRepList.size() < 2){
                    delete accTeamMembSalesAndServList;
                    for(Id salesId: salesRepMap.keyset()){
                        salesAccountTeams.add(accountTeamMembInit(salesId,salesRepMap.get(salesId), Label.AccountTeamRoleSales));
                    }
                    insert salesAccountTeams;
                }
                else if(lobAccountRecSalesRepList.size() < 2 && lobAccountRecServiceRepList.size() > 2){
                    delete accTeamMembSalesAndServList;
                    for(Id serviceId : serviceRepMap.keyset()){
                        serviceAccountTeams.add(accountTeamMembInit(serviceId,serviceRepMap.get(serviceId),Label.AccountTeamRoleService));
                    }
                    insert serviceAccountTeams;
                }
                else if(lobAccountRecSalesRepList.size() < 2 && lobAccountRecServiceRepList.size() < 2){
                    delete accTeamMembSalesAndServList;
                }
            }    
            
        }
        catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Line_Of_Business_Account__c>'), string.valueOf(lobAccRecList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), lobAccRecList, null, inputFromMethodParameters);
        }
    }
}