import { LightningElement, api, track } from 'lwc';

export default class CovetrusPracticeHeader extends LightningElement {

    @api practice;
    @track systemOfRecord;
    @track covetrusCustomerNumber;
    @track practiceName;
    @track street;
    @track phone;
    @track website;
    @track numberOfVets;

    connectedCallback () {
        console.log ('connected call back - covetrus practice header' );
        this.load ( this.practice );
    }

    @api
    load ( newPractice ) {
        console.log ('load Covetrus Practice Header');
        this.practice = newPractice;
        // set fields
        this.systemOfRecord = this.practice.systemOfRecord;
        this.covetrusCustomerNumber = this.practice.covetrusCustomerNumber;
        this.practiceName = this.practice.practiceName;
        this.street = this.practice.addressLine1;
        if ( this.practice.addressLine2 != null ) {
            this.street = this.street + '\n' + this.practice.addressLine2;
        }
        this.city = this.practice.city;
        this.zipCode = this.practice.zipCode;
        this.phone = this.practice.phone;
        this.website = this.practice.website;
        this.numberOfVets = this.practice.numberOfVets;
    }


}