import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";

export default class Logos extends TwElement {
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

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "title" property.
    if (!("title" in this.computed)) {
      this.error = 'Hero component requires a title.';
    }

    // Computed should contain a "logos" property.
    if (!("logos" in this.computed)) {
      this.error = 'Hero component requires a "logos" key.';
    }
  }
}
