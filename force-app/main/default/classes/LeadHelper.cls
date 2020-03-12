// LeadHelper
// Bhanudas Tanaka - Covetrus - Feb 2020
// --------------------------------------
// Provides CRUD sObject interface for interacting with Leads

public without sharing class LeadHelper {
    
    static public void createLeadFromForm ( LeadFormController.LeadForm leadData ) {

        try {
            // get the record type and other values
            RecordType naRt = [ SELECT Id, Name FROM RecordType WHERE Name = 'NA' and sObjectType = 'Lead' ];
            //Line_Of_Business__c lob = [ SELECT Id, Name FROM Line_Of_Business__c WHERE Name = 'GSS NA' ];
            
            // create the lead
            Lead newLead = new Lead ();
            newLead.recordTypeId = naRt.Id;
            newLead.Status = 'New';
            newLead.FirstName = leadData.pcFirstName;
            newLead.LastName = leadData.pcLastName;
            newLead.Email = leadData.pcEmail;
            newLead.Phone = leadData.pcPhone;
            newLead.Company = leadData.accountName;
            //newLead.Line_Of_Business__c = lob.Id;
            newLead.CurrencyIsoCode = 'USD';
            newLead.LeadSource = 'Internal Referral';
            newLead.Lead_Sub_Source__c = 'CO NA';
            //newLead.Lead_Source_Description__c = '???'
            //newLead.Lead_Interest__c = need to map
            newLead.State = leadData.stateProvince;
            newLead.Country = 'United States';
            //newLead.Referral_Source_Name__c = leadData.famFirstName + ' ' + leadData.famLastName;
            //newLead.Referral_Source_Email__c = leadData.famEmail;
            insert newLead;
        } catch ( Exception e ) {
            throw new LeadFormException ( 'An Error Occurred in Creating Lead', e.getMessage(), true );
        }
        
    }
}