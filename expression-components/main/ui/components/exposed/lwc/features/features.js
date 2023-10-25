import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";

export default class Features extends TwElement {
  @api expr;
  @api respectSharing;

  computed;
  error;

  @wire(evaluate, {recordId: '', formula: '$expr', respectSharing: '$respectSharing'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
      this._validate();
    }
  }

  get loading() {
    return !this.computed && !this.error;
  }

  get hasError() {
    return this.error;
  }

  get ready() {
    return !this.loading && !this.hasError;
  }

  get hasText() {
    return this.computed?.title || this.computed?.description;
  }

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "features" property.
    if (!("features" in this.computed)) {
      this.error = 'Features component requires "features".';
    }
  }
}
