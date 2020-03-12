/****************************************************************************************************************************
*** Class Name          	 :  AssetTriggerHelperTest 
*** Author                   :  Nagarjuna G
*** Class Created Date     	 :	11/12/2019
*		Modified Date        :	
*		Modified By          :  
******************************************************************************************************************************/
@isTest
public class AssetTriggerHelperTest {
    public static testMethod void createChildAssets(){
        Account acc =TestDataFactory.testData();

        Product2 testProd = new Product2();
        testProd.Name = 'sampleProd';
       	testProd.Region__c = 'APAC';
        testProd.Family = 'Hardware';
        testProd.ProductCode = 'APAC2346';
        testProd.Bundle_Key__c = 'APAC2346';
        testProd.Line_of_Business__c = 'GSS';
        insert testProd;
        
        Product2 testProduct = new Product2();
         testProduct.Name = 'Mic';
       	testProduct.Region__c = 'APAC';
        testProduct.Family = 'Support';
        testProduct.ProductCode = 'APAC2346';
        testProduct.Bundle_Key__c = 'APAC2346';
        testProduct.Line_of_Business__c = 'GSS';
        insert testProduct;
        
        Product2 prod = new Product2();
        prod.Name = 'testProd';
       	prod.Region__c = 'APAC';
        prod.Family = 'Practice Performance';
        prod.ProductCode = 'APAC2346';
        prod.Bundle_Key__c = 'APAC2346';
        prod.Line_of_Business__c = 'GSS';
        insert prod;
     
        List<Asset> asstList = new List<Asset>();
  string supportRecId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Support').getRecordTypeId();

         Asset asst = new Asset();
        asst.RecordTypeId =supportRecId;
        asst.Name = 'Test Asset';
        asst.AccountID =acc.ID;
        asst.Status = 'Purchased';
        asst.Product2Id = testProduct.Id;
        
        insert asst;
        asstList.add(asst);
          string recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Practice Performance').getRecordTypeId();

        Asset ast = new Asset();
        ast.RecordTypeId =recordtypeId;
        ast.Name = 'Test Asset';
        ast.AccountID =acc.ID;
        ast.SerialNumber ='testt123';
        ast.Quantity =2;
        ast.License_Expiry_Date__c=system.today();
        ast.Computer_Name__c='Test';
        ast.Version__c ='2';
        ast.Demo_Expiry_Date__c =system.today();
        ast.Update_Date__c =system.today();
        //ast.LOB__c ='Test';
        ast.Status = 'Purchased';
        ast.Product2Id = prod.Id;
        insert ast;
      
        asstList.add(asst);
         
        test.startTest();
        AssetTriggerHelper.assetCreation(asstList);
          ast.SerialNumber ='testt123';
        ast.Quantity =2;
        ast.License_Expiry_Date__c=system.today()+3;
        ast.Computer_Name__c='Test';
        ast.Version__c ='2';
        ast.Demo_Expiry_Date__c =system.today()+3;
        ast.Update_Date__c =system.today()+3;
        //ast.LOB__c ='Test';
        ast.Status = 'Purchased';
        ast.Product2Id = testProduct.Id;
        ast.Integration_Requested_Date__c =system.now();
        update ast;
        test.stopTest();
        
    }
    public static testMethod void prodFamilyCovetSoftTest(){
         Account acc =TestDataFactory.testData();

        Product2 testProd = new Product2();
        testProd.Name = 'sampleProd';
       	testProd.Region__c = 'APAC';
        testProd.Family = 'Hardware';
        testProd.ProductCode = 'APAC2346';
        testProd.Bundle_Key__c = 'APAC2346';
        testProd.Line_of_Business__c = 'GSS';
        insert testProd;
        
        Product2 testProduct = new Product2();
         testProduct.Name = 'Mic';
       	testProduct.Region__c = 'APAC';
        testProduct.Family = 'Support';
        testProduct.ProductCode = 'APAC2346';
        testProduct.Bundle_Key__c = 'APAC2346';
        testProduct.Line_of_Business__c = 'GSS';
        insert testProduct;
        
        Product2 prod = new Product2();
        prod.Name = 'testProd';
       	prod.Region__c = 'APAC';
        prod.Family = 'Covetrus Software';
        prod.ProductCode = 'APAC2346';
        prod.Bundle_Key__c = 'APAC2346';
        prod.Line_of_Business__c = 'GSS';
        insert prod;
     
        List<Asset> asstList = new List<Asset>();
  string supportRecId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Support').getRecordTypeId();

         Asset asst = new Asset();
        asst.RecordTypeId =supportRecId;
        asst.Name = 'Test Asset';
        asst.AccountID =acc.ID;
        asst.Status = 'Purchased';
        asst.Product2Id = testProduct.Id;
        
        insert asst;
        asstList.add(asst);
          string recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Practice Performance').getRecordTypeId();

        Asset ast = new Asset();
        ast.RecordTypeId =recordtypeId;
        ast.Name = 'Test Asset';
        ast.AccountID =acc.ID;
        ast.SerialNumber ='testt123';
        ast.Quantity =2;
        ast.License_Expiry_Date__c=system.today();
        ast.Computer_Name__c='Test';
        ast.Version__c ='2';
        ast.Demo_Expiry_Date__c =system.today();
        ast.Update_Date__c =system.today();
        //ast.LOB__c ='Test';
        ast.Status = 'Purchased';
        ast.Product2Id = prod.Id;
        insert ast;
      
        asstList.add(asst);
         
        test.startTest();
        AssetTriggerHelper.assetCreation(asstList);
          ast.SerialNumber ='testt123';
        ast.Quantity =2;
        ast.License_Expiry_Date__c=system.today()+3;
        ast.Computer_Name__c='Test';
        ast.Version__c ='2';
        ast.Demo_Expiry_Date__c =system.today()+3;
        ast.Update_Date__c =system.today()+3;
        //ast.LOB__c ='Test';
        ast.Status = 'Purchased';
        ast.Product2Id = testProduct.Id;
        ast.Integration_Requested_Date__c =system.now();
        update ast;
        test.stopTest();
        
    }
}