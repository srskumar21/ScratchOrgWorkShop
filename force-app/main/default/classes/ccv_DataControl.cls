// Covetrus Shared Customer View
// Data Control

// Segment for messaging, status and version numbers

global with sharing class ccv_DataControl {

    global String version;
    global String errorMessage;
    
    global ccv_DataControl() {
        this.version = '1.0';
    }
}