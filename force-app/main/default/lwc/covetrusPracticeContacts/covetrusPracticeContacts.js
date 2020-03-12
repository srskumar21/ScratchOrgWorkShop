import { LightningElement, api } from 'lwc';

export default class CovetrusPracticeContacts extends LightningElement {

    @api contacts;
    
    connectedCallback () {
        // parse and load sales reps
        console.log ('connected callback covetrus practice contacts');
        console.log (JSON.stringify ( this.contacts));
    }
}