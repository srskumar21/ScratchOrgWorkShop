/**************************************************************************************************
*** Trigger Name             : AssetTrigger
*** Trigger Description      : This trigger is invoked after Asset record is inserted.
*** Author                   : Sreenath Dhanireddy 
*** Trigger Created Date     : 11/7/2019
*       Modified Date        : 11/13/2019
*       Modified By          : Nagarjuna G
**************************************************************************************************/

trigger AssetTrigger on Asset (before insert,after insert,before update) {
    List<Asset> assetRecList = new List<Asset>();
    Map<Id,Schema.RecordTypeInfo> recTypeMap = new Map<Id,Schema.RecordTypeInfo>();
    
    Map<ID,Schema.RecordTypeInfo> rectype_Map = Asset.sObjectType.getDescribe().getRecordTypeInfosById(); 
    for(Schema.RecordTypeInfo recTypeInfo :rectype_Map.values()){
        System.debug('recTypeInfo----->'+recTypeInfo);
        if(recTypeInfo.name == 'Software' ||recTypeInfo.name =='Practice Performance' ||recTypeInfo.name =='Support'){
            recTypeMap.put(recTypeInfo.getRecordTypeId(),recTypeInfo);
        }
    }
    
    if(trigger.isBefore && trigger.isInsert){
        for(Asset astRec :trigger.new){
            if(recTypeMap.containsKey(astRec.RecordTypeId)){
                if(recTypeMap.get(astRec.RecordTypeId).getName().containsIgnoreCase('Software') ||
                   recTypeMap.get(astRec.RecordTypeId).getName().containsIgnoreCase('Practice Performance')||
                   recTypeMap.get(astRec.RecordTypeId).getName().containsIgnoreCase('Support')){
                       assetRecList.add(astRec); 
                   }
            }
        }
        AssetTriggerHelper.updateAssetIntegrationRequestedDate(assetRecList);
    }
    if(trigger.isAfter && trigger.isInsert){
        AssetTriggerHelper.assetCreation(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        for(Asset astRecrds : trigger.new){
            if(recTypeMap.containsKey(astRecrds.RecordTypeId)){
                if(recTypeMap.get(astRecrds.RecordTypeId).getName().containsIgnoreCase('Software') ||
                   recTypeMap.get(astRecrds.RecordTypeId).getName().containsIgnoreCase('Practice Performance')||
                   recTypeMap.get(astRecrds.RecordTypeId).getName().containsIgnoreCase('Support')){
                       assetRecList.add(astRecrds);
                   }
            }
        }
        AssetTriggerHelper.updateAssetIntegReqDateWhenFieldSetChange(assetRecList); 
    }
    
}