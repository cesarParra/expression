import {api, LightningElement, wire} from 'lwc';
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import {
    REFRESH_COMPLETE, registerRefreshContainer,
} from "lightning/refresh";
import {refreshApex} from "@salesforce/apex";

export default class Formula extends LightningElement {
    @api recordId;
    @api title;
    @api expr;
    computedWire;

    connectedCallback() {
        registerRefreshContainer(this, this.refreshContainer);
    }

    @wire(evaluate, {recordId: '$recordId', formula: '$expr'})
    evaluate(result) {
        this.computedWire = result;
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
