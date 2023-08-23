import {api, LightningElement, wire} from 'lwc';
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';

export default class Formula extends LightningElement {
    @api recordId;
    @api title;
    @api expr;
    computed;

    @wire(evaluate, {recordId: '$recordId', formula: '$expr'})
    evaluate({error, data}) {
        if (data) {
            this.computed = data;
        } else if (error) {
            console.error(this.error);
            this.computed = undefined;
        }
    }
}
