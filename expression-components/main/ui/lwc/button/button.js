import { api } from 'lwc';
import TwElement from "c/twElement";
import { NavigationMixin } from "lightning/navigation";
import execute from '@salesforce/apex/FormulaEvaluatorUiController.execute';

export default class PricingTable extends NavigationMixin(TwElement) {
  @api action;

  async executeAction(e) {
    e.preventDefault();
    e.stopPropagation();
    try {
      // TODO: Support other types of actions and navigations
      const result = await execute({fnReference: this.action.src});
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
          name: this.action.callback.namedPage,
        },
        state: Object.entries(this.action.callback.args)
          .map(([key, value]) => {
            return [key, value.replace("{!placeholder}", result)];
          })
          .reduce((acc, [key, value]) => {
            acc[key] = value;
            return acc;
          }, {})
      });
    } catch (e) {
      console.error(e);
    }
  }
}
