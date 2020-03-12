import { LightningElement, api } from 'lwc';

export default class CovetrusPracticeSalesRepresentatives extends LightningElement {

    @api salesRepresentatives;

    connectedCallback () {
        // parse and load sales reps
        console.log ('connected callback covetrus practice sales representatives');
        console.log (JSON.stringify ( this.salesRepresentatives));
    }
}