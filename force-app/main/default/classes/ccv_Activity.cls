// Covetrus Shared Customer View
// Activity

global class ccv_Activity implements Comparable {

    global String status;
    global String type;
    global String activityDate;
    global String ownerFullName;
    global String name;
    global String description;
    global Date activityDateTypedDate;
    global String activityDateType;

    global ccv_Activity() {

    }

    // implementation of compareTo
    // NOTE: sort() should always return this as Descending which is why
    //       return values are switched
    global integer compareTo ( Object compareToObj ) {
        // cast
        ccv_Activity compareToActivity = (ccv_Activity) compareToObj;
        // convert the date values
        this.typeDate ();
        compareToActivity.typeDate ();

        // only evaluate if the types are the same, and we have a Date or Date Time
        if (( this.activityDateType == compareToActivity.activityDateType ) && ( this.activityDateType == 'Date')) {
            // compare the dates
            if ( this.activityDateTypedDate == compareToActivity.activityDateTypedDate ) {
                return 0;
            } else if ( this.activityDateTypedDate > compareToActivity.activityDateTypedDate ) {
                return -1;
            } else if ( this.activityDateTypedDate < compareToActivity.activityDateTypedDate ) {
                return 1;
            }
        }
        // if we get here, just return 0 - we cannot sort
        return 0;
    }

    global void typeDate () {
        boolean dateConvertFailed = false;

        // check for null
        if ( this.activityDate == null ) {
            // just leave
            this.activityDateType = 'NULL';
            return;
        }

        // first try date
        try {
            this.activityDateTypedDate = Date.valueOf ( this.activityDate );
            this.activityDateType = 'Date';
        } catch ( Exception e ) {
            // if we have an exception, set failure
            dateConvertFailed = true;
        }
        
        // set the DateType field
        if ( dateConvertFailed ) {
            this.activityDateType = 'Unknown';
        }
    }
}