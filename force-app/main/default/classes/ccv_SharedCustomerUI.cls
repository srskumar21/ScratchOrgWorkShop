public with sharing class ccv_SharedCustomerUI {
    
    @AuraEnabled (cacheable=true)
    public static string requestCustomerData ( String accountId ) {

        System.debug ('entering method with ' + accountId );

        Account a;

        try {
            // query for Covetrus Customer Number
            a = [ SELECT ID, Covetrus_Customer_Number__c FROM Account WHERE ID =: accountId ];
        } catch ( Exception e ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'A system issue has occurred looking up record ' + accountId + ' error:' + e.getMessage(), 'Please report this to the Salesforce Team', null );
        }
        

        if ( a.Covetrus_Customer_Number__c == null ) {
            // no key to use, throw exception
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.WARNING, 'Business does not have a Covetrus Customer Key assigned to it', 'Try another Business that has a Covetrus Customer Key', null );
        }

        // get the end point name
        ccv_Environment env = new ccv_Environment ();
        if ( env.load () == false ) {
            // throw exception that system is not functional
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'Requests from Salesforce are currently misconfigured', 'Please contact the Salesforce Team and report this issue', null );
        }

        string endPointName = env.ccvEndpointName;

        ccv_Request req = new ccv_Request ( new ccv_RequestQueryStringHelper ());
        req.initialize ( endPointName );
        ccv_SharedCustomerJSON jsonOutput = req.getCovetrusCustomer ( a.Covetrus_Customer_Number__c, env.requestTimeout );
        system.debug ( jsonOutput );

        // check for practices
        if ( jsonOutput.practices.size () == 0 ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.WARNING, 'No practices found within other CRM systems for Covetrus Customer Key ' + a.Covetrus_Customer_Number__c, 'If you believe this is an error, please report to the Salesforce Team', null );
        }
        
        // build ID, and other miscellany for UI
        try {
            for ( ccv_Practice practice : jsonOutput.practices ) {
                // check and initialize core arrays
                if ( practice.salesRepresentatives == null ) {
                    practice.salesRepresentatives = new List < ccv_SalesRepresentative > ();
                }
                if ( practice.contacts == null ) {
                    practice.contacts = new List < ccv_Contact > ();
                }
                if ( practice.opportunities == null ) {
                    practice.opportunities = new List < ccv_Opportunity > ();
                }
                if ( practice.activities == null ) {
                    practice.activities = new List < ccv_Activity > ();
                }
                if ( practice.accountSummaries == null ) {
                    practice.accountSummaries = new List < ccv_AccountSummary > ();
                }
                // build IDs 
                practice.id = ccv_SharedCustomerUI.generateGuid ();
                // transform data
                for ( ccv_SalesRepresentative salesRep : practice.salesRepresentatives ) {
                    salesRep.fullName = salesRep.firstName + ' ' + salesRep.lastName;
                }
                for ( ccv_Contact con : practice.contacts ) {
                    con.fullName = con.firstName + ' ' + con.lastName;
                }
                for ( ccv_AccountSummary accSum : practice.accountSummaries ) {
                    // set label for UI
                    accSum.label = '';
                    if ( accSum.type != null ) {
                        accSum.label = accSum.type + ' ';
                    }
                    if ( accSum.summaryName != null ) {
                        accSum.label = accSum.label + accSum.summaryName;
                    }
                    accSum.id = ccv_SharedCustomerUI.generateGuid ();
                }
                // sort activities
                for ( ccv_Activity act : practice.activities ) {
                    act.typeDate ();
                }
                practice.activities.sort ();
            }
        } catch ( Exception e ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'System encountered an unhandled problem in preparing data for ' + a.Covetrus_Customer_Number__c, 'Please report this to the Salesforce Team', null );
        }
        
        
        system.debug ('returning ' + jsonOutput );
        return JSON.serialize(jsonOutput);
    }

    // Thank you Rev at https://salesforce.stackexchange.com/questions/4073/how-to-generate-a-guid-uuid
    private static string generateGuid () {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

}