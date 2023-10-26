import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";
import { classNames } from 'c/utils';

export default class PricingTable extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;

  get gridClasses() {
    return classNames(
      'isolate -mt-16 grid max-w-sm grid-cols-1 gap-y-16 divide-y divide-gray-100 ' +
      'sm:mx-auto lg:-mx-8 lg:mt-0 lg:max-w-none lg:divide-x lg:divide-y-0 xl:-mx-4',
      {'lg:grid-cols-3': this.computed.plans.length >= 3},
      {'lg:grid-cols-2': this.computed.plans.length === 2},
      {'lg:grid-cols-1': this.computed.plans.length === 1},
    );
  }

  validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "plans" array.
    if (!("plans" in this.computed)) {
      this.error = 'The evaluated Expression must contain a "plans" array.';
    }
  }
}
