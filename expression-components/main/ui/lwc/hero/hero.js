import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";

export default class Hero extends TwElement {
  @api expr;

  computed;
  error;

  @wire(evaluate, {recordId: '', formula: '$expr'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
      this._validate();
    }
  }

  // callToAction() {
  //   window.open(this.computed.callToAction.url, '_self');
  // }
  //
  // secondaryAction() {
  //   window.open(this.computed.secondaryAction.url, '_self');
  // }

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "title" property.
    if (!("title" in this.computed)) {
      this.error = 'Hero component requires a title.';
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
}
