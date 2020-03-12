// Lead Form Exception Class for UI error reporting

public with sharing class LeadFormException extends Exception {

    public class ExceptionData {
        public string title;
        public string userMessage;
        public string variant;
    }

    public LeadFormException ( string title, string message, boolean auraEnabled ) {
        ExceptionData data = new ExceptionData ();
        data.title = title;
        data.userMessage = message;
        data.variant = 'error';
        throw new AuraException ( JSON.serialize ( data ));

    }
}