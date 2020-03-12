// CVET Helper JS
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// error handler
function handleError ( error ) {
    console.log('--error--');
    console.log(error);
    let errorObj = JSON.parse(error.body.message);
    console.log ( 'errorObj', errorObj );
    dispatchEvent(
        new ShowToastEvent({
            title: errorObj.title,
            message: errorObj.userMessage,
            variant: errorObj.variant,
            mode: errorObj.mode
        })
    );
}

// notify handler
function handleNotify ( title, message, variant ) {
    console.log('--notify--');
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
    );
}

export {
    handleError,
    handleNotify
}