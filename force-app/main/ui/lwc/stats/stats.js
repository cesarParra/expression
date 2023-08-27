import {LightningElement, api, wire} from 'lwc';
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import {
    REFRESH_COMPLETE, registerRefreshContainer,
} from "lightning/refresh";
import {refreshApex} from "@salesforce/apex";

export default class Stats extends LightningElement {
    @api recordId;
    @api expr;
    computedWire;

    connectedCallback() {
        registerRefreshContainer(this, this.refreshContainer);
    }

    @wire(evaluate, {recordId: '$recordId', formula: '$expr'})
    evaluate(result) {
        this.computedWire = result;
        console.log('result', this.computedWire.data);
        const {error} = result;
        if (error) {
            console.error(this.error);
        }
    }

    get computed() {
        return this.computedWire && this.computedWire.data;
    }

    refreshContainer(refreshPromise) {
        return refreshPromise.then((status) => {
            if (status === REFRESH_COMPLETE) {
                refreshApex(this.computedWire);
            }
        });
    }
}
