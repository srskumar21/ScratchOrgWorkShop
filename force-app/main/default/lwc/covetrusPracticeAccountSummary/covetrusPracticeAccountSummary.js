import { LightningElement, api, track } from 'lwc';

export default class CovetrusPracticeAccountSummary extends LightningElement {

    @api accountSummary;
    @track revenueData;
    
    connectedCallback () {
        // populate the data grid for revenue display
        this.revenueData = [
            {   type: 'Potential', 
                annual: this.accountSummary.annualRevenuePotential, 
                mtd: this.accountSummary.mtdRevenuePotential,
                rolling: this.accountSummary.rollingSixMonthsPotential
            },
            {
                type: 'Actual',
                annual: this.accountSummary.annualRevenueActual,
                mtd: this.accountSummary.mtdRevenueActual,
                rolling: this.accountSummary.rollingSixMonthsActual,
                ytd: this.accountSummary.ytdRevenue
            }
        ];


        
    }
}