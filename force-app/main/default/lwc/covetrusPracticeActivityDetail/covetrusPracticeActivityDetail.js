import { LightningElement, api } from 'lwc';

export default class CovetrusPracticeActivityDetail extends LightningElement {

    @api activity;

    openModal () {
        console.log ( 'covetrus practice activity detail' );
        console.log ( 'pop model for activity ' );
        console.log ( JSON.stringify ( this.activity ));
        // dispatch the event
        this.dispatchEvent ( new CustomEvent ( 'covetrusshowactivitydetail', { bubbles: true, composed: true, detail: { activity: this.activity }} ));
    }

}