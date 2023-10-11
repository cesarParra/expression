import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";
import { classNames } from 'c/utils';

export default class PricingTable extends TwElement {
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
    }
  }

  get hasText() {
    return this.computed?.title || this.computed?.description;
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
