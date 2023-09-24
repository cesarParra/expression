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
    if (this.recordId && this.recordId.startsWith('{!')) {
      // An expression was provided. We want to extract the string from the expression and then get
      // the value from the URL parameter matching the string.
      const expr = this.recordId.substring(2, this.recordId.length - 1);
      const urlParams = new URLSearchParams(window.location.search);
      this._evaluatedId = urlParams.get(expr);
    } else {
      this._evaluatedId = this.recordId;
    }
  }

  @wire(evaluate, {recordId: '$evaluatedId', formula: '$expr'})
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

  _evaluatedId;
  get evaluatedId() {
    return this._evaluatedId;
  }

  set evaluatedId(value) {
    this._evaluatedId = value;
  }

  refreshContainer(refreshPromise) {
    return refreshPromise.then((status) => {
      if (status === REFRESH_COMPLETE) {
        refreshApex(this.computedWire);
      }
    });
  }
}
