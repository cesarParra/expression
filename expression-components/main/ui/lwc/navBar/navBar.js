import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import {api, wire} from "lwc";

export default class NavBar extends TwElement {
  @api expr;

  isOpen = false;
  computed;
  error;

  @wire(evaluate, {recordId: '', formula: '$expr'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
    }
  }

  toggle() {
    this.isOpen = !this.isOpen;
  }

  callToAction() {
    window.open(this.computed.callToAction.url, '_self');
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
