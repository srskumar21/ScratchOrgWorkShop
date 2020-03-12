// Covetrus Shared Customer View
// Account Summary

global class ccv_AccountSummary {

    global String   type;
    global String   summaryName;
    global String   startDate;
    global String   firstOrderDate;
    global String   nextBillDate;
    global String   inactivityDate;
    global String   status;
    global Decimal  annualRevenuePotential;
    global Decimal  annualRevenueActual;
    global Decimal  mtdRevenuePotential;
    global Decimal  mtdRevenueActual;
    global Decimal  rollingSixMonthsPotential;
    global Decimal  rollingSixMonthsRevenueActual;
    global Decimal  ytdRevenue;
    global String   id; // for UI only
    global String   label; // for UI only
    
    global ccv_AccountSummary() {

    }
}