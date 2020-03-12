import { LightningElement, api } from 'lwc';

export default class CovetrusPracticeOpportunities extends LightningElement {

    @api opportunities;

    connectedCallback () {
        // parse and load sales reps
        console.log ('connected callback covetrus practice opportunities');
        console.log (JSON.stringify ( this.opportunities ));
    }
}