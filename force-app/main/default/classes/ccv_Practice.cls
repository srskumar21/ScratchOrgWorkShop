// Covetrus Customer View
// Practice

global class ccv_Practice {
    global String covetrusCustomerNumber;
    global String systemOfRecord;
    global string practiceName;
    global String addressLine1;
    global String addressLine2;
    global String city;
    global String state;
    global String zipCode;
    global String countryCode;
    global String numberOfVets;
    global String phone;
    global String website;
    global String id; // used by display layer only

    global List < ccv_SalesRepresentative > salesRepresentatives;
    global List < ccv_Contact > contacts;
    global List < ccv_Activity > activities;
    global List < ccv_Opportunity > opportunities;
    global List < ccv_AccountSummary > accountSummaries;
    
    global ccv_Practice() {

    }
}