// Lead Form LWC Controller
// Bhanudas Tanaka - Covetrus - Feb 2020
// -------------------------------------
// Provides Controller logic and interface between LWC and APEX

public with sharing class LeadFormController {

    // LeadForm
    // JSON Wrapper Class 
    public class LeadForm {

        public string covetrusId;
        public List < string > referredProducts;
        public string pcFirstName;
        public string pcLastName;
        public string pcEmail;
        public string pcPhone;
        public string accountName;
        public string stateProvince;
        public string currentPims;
        public string famFirstName;
        public string famLastName;
        public string famEmail;
        public string notes;

    }

    // Static Methods for AURA interfacing

    // recentLeadReferrals :: Searches by Covetrus ID and returns a list of referrals that should be supressed on form
    @AuraEnabled (cacheable=false)
    public static string recentLeadReferrals ( string covetrusId ) {
        string returnJson;

        return returnJson;
    }

    // requestLeadStatusEmail :: sends an email (as specified) a list of Lead Status for those submitted by that email
    @AuraEnabled (cacheable=false)
    public static string requestLeadStatusEmail ( string famEmail ) {
        string returnJson;

        return returnJson;
    }

    // createLead :: creates a new lead and returns Lead ID
    @AuraEnabled (cacheable=false)
    public static string createLead ( string leadFormJson ) {
        string returnJson;

        LeadForm leadData = (LeadForm) JSON.deserialize ( leadFormJson, LeadForm.class );
        System.debug ( 'Lead Data ' + leadData );

        // send into Lead Helper for creation
        LeadHelper.createLeadFromForm ( leadData );

        // return results
        return returnJson;
    }
}