import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import execute from '@salesforce/apex/FormulaEvaluatorUiController.execute';
import { api, wire } from "lwc";

// TODO: Dynamically style based on the number of plans:
// 1 plan: 100% width
// 2 plans: 50% width
// 3 plans: 33% width
// More than 3 then flow to a new row.
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
      this._validate();
    }
  }

  async executeAction(e) {
    e.preventDefault();
    const planName = e.target.dataset.plan;
    const action = this.computed.plans.find(p => p.name === planName).action;
    try {
      await execute({fnReference: action.src});
    } catch (e) {
      console.error(e);
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

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "plans" array.
    if (!("plans" in this.computed)) {
      this.error = 'The evaluated Expression must contain a "plans" array.';
    }
  }
}
