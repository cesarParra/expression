import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import execute from '@salesforce/apex/FormulaEvaluatorUiController.execute';
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
      this._validate();
    }
  }

  get gridClasses() {
    return classNames(
      'isolate -mt-16 grid max-w-sm grid-cols-1 gap-y-16 divide-y divide-gray-100 ' +
      'sm:mx-auto lg:-mx-8 lg:mt-0 lg:max-w-none lg:divide-x lg:divide-y-0 xl:-mx-4',
      {'lg:grid-cols-3': this.computed.plans.length >= 3},
      {'lg:grid-cols-2': this.computed.plans.length === 2},
      {'lg:grid-cols-1': this.computed.plans.length === 1},
    );
  }

  async executeAction(e) {
    e.preventDefault();
    const planName = e.target.dataset.plan;
    const action = this.computed.plans.find(p => p.name === planName).action;
    try {
      const result = await execute({fnReference: action.src});
    } catch (e) {
      console.error(e);
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
    // Computed should contain a "plans" array.
    if (!("plans" in this.computed)) {
      this.error = 'The evaluated Expression must contain a "plans" array.';
    }
  }
}
