/**************************************************************************************************
*** Class Name             : AssetTriggerHelper
*** Class Description      : This Helper class is invoked from the trigger when trigger events are
fired.
*** Author                 : Sreenath Dhanireddy
*** Class Created Date     : 11/7/2019
*            Modified Date : 11/13/2019
*            Modified By   : Nagarjuna G
**************************************************************************************************/
public class AssetTriggerHelper {
    Public Static final String Asset_Software_Recordtype ='Software';
    Public Static final String Asset_PracticePerformance_Recordtype ='Practice Performance';
    Public Static final String Asset_Support_Recordtype ='Support';
    
    /************************************************************************************************
*** Method Name             : assetCreation
*** Method Description      : This method will create subassets for those products that are associated
via a bundle id to the main product(Parent Asset).
*****************************************************************************************************/
    public static void assetCreation(List<Asset> assetList){
        set<String> prodCodes = new Set<String>();
        map<string,id> assetProdMap = new map<string,id>();
        list<asset> asstList = new list<asset>();
        map<string,list<product2>> prodBundleKeyMap = new map<string,list<product2>>();
        try{
            for(Asset asset : assetList){
                if (!String.isEmpty(asset.ProductCode)) {
	                prodCodes.add(asset.ProductCode);
    	            assetProdMap.put(asset.Product2Id,asset.Id);
                }
            }
            if (!prodCodes.isEmpty()) {
                List<Product2> prodList = [SELECT ID, Name, Bundle_Key__c, Family, Manufacturer__c, Manufacturer_Item_Number__c 
                                           FROM Product2 WHERE Bundle_Key__c IN: prodCodes];  
                for(product2 prod: prodList){
                    if(prodBundleKeyMap.containskey(prod.Bundle_Key__c)){
                        List<product2> bundleKeyProdList = prodBundleKeyMap.get(prod.Bundle_Key__c);
                        bundleKeyProdList.add(prod);
                        prodBundleKeyMap.put(prod.Bundle_Key__c, bundleKeyProdList);
                    } else {
                        prodBundleKeyMap.put(prod.Bundle_Key__c, new List<product2> { prod });
                    }
                }
            }
            for(asset ass: assetList){
                if (prodBundleKeyMap.containsKey(ass.ProductCode)) {
                    for(product2 prod: prodBundleKeyMap.get(ass.ProductCode)){
                        if(!assetProdMap.keyset().contains(prod.Id) && ass.ParentId==null){
                            Asset asst =  new Asset();
                            asst.Product2Id = prod.Id;
                            asst.ParentId = ass.Id;
                            asst.Status = ass.Status;
                            asst.AccountId = ass.AccountId;
                            asst.Name = prod.Name;
                            asst.Line_of_Business__c= ass.Line_of_Business__c;
                            asst.PurchaseDate = ass.PurchaseDate;
                            if(prod.Family == 'Covetrus Software' || prod.Family == '3rd Party Software'){
                                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Software').getRecordTypeId();
                            }
                            else if(prod.Family == 'Hardware' || prod.Family == 'Warranty' || prod.Family == 'Product'){
                                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Hardware').getRecordTypeId();
                                asst.Manufacturer__c = prod.Manufacturer__c;
                                asst.Product_Name__c = prod.Name;
                                asst.Manuafacturer_Item_Number__c = prod.Manufacturer_Item_Number__c;
                            }
                            else if(prod.Family == 'Support')
                                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Support').getRecordTypeId();
                            else if(prod.Family == 'Configuration and Setup' || prod.Family == 'Professional Services')
                                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Services').getRecordTypeId();
                            else if(prod.Family == 'Practice Performance')
                                asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Practice Performance').getRecordTypeId();
                            
                            asstList.add(asst);
                        }
                    }
                }
            }
            if(asstList.size()>0){
                insert asstList;
            }
        }
        catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Asset>'), string.valueOf(assetList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
    /************************************************************************************************
*** Method Name             : updateAssetIntegrationRequestedDate
*** Method Description      : This method will update the 'Integration Requested date'.When the asset record 
creates from 'Software' ,'Support' and 'Practice performace' record types.
*****************************************************************************************************/
    
    Public static void updateAssetIntegrationRequestedDate(List<Asset> asetList){
        List<Asset> assetListRecrds = new List<Asset>();
        try{
            for(Asset astRecs :asetList){
                system.debug('Enter');
                system.debug(astRecs.RecordType.name);
                astRecs.Integration_Requested_Date__c =System.now();
                assetListRecrds.add(astRecs);
            }
        }catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Asset>'), string.valueOf(asetList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
        
    }
    
    /************************************************************************************************
*** Method Name             : updateAssetIntegReqDateWhenFieldSetChange
*** Method Description      : This method will update the 'Integration Requested date'. when the asset record
updates from 'Software' ,'Support' and 'Practice performace' record types.
*****************************************************************************************************/
    public static void updateAssetIntegReqDateWhenFieldSetChange(List<Asset> asstRecsList){
        List<Asset> updateAstRecList = new List<Asset>();
        set<String> fieldSet = new Set<String>();
        try{
            for(Schema.Fieldsetmember fields :Schema.SObjecttype.Asset.Fieldsets.getmap().get('Integration_Fields').getfields()){
                fieldSet.add(fields.getFieldPath());
            }
            for(Asset ast : asstRecsList){
                system.debug(ast.RecordType.name);
                for(String fieldSetList : fieldSet){
                    if(ast.get(fieldSetList) != trigger.oldmap.get(ast.id).get(fieldSetList)){
                        ast.Integration_Requested_Date__c = System.now();
                        updateAstRecList.add(ast);
                        system.debug('updateAstRecList'+updateAstRecList);
                    }
                    
                }
                
            }
            
        }catch(Exception e){
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Asset>'), string.valueOf(asstRecsList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
        
    }
}