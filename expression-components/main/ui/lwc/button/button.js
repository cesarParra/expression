import { api } from 'lwc';
import TwElement from "c/twElement";
import { NavigationMixin } from "lightning/navigation";
import execute from '@salesforce/apex/FormulaEvaluatorUiController.execute';

export default class PricingTable extends NavigationMixin(TwElement) {
  /**
   * @typedef ApexFunction
   * @property { string } class
   * @property { Object[] } args
   */

  /**
   * @typedef ApexFunctionCallback
   * @property { "navigate__namedPage" | "navigate__url" } type
   * @property { string } name
   * @property { Object } args
   */

  /**
   * The action to execute when the button is clicked
   * @property {string} label
   * @property {"action" | "navigation_namedPage" | "navigation_url" } type
   * @property {string | ApexFunction} src
   * @property {ApexFunctionCallback} callback
   */
  @api action;

  async executeAction(e) {
    e.preventDefault();
    e.stopPropagation();

    if (this.action.type === "action") {
      try {
        const result = await execute({fnReference: this.action.src});
        this[NavigationMixin.Navigate](this._getNavigationObjectFromActionResult(result));
      } catch (e) {
        console.error(e);
      }
    } else if (this.action.type === "navigation_namedPage") {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: this.action.src,
        }
      });
    } else if (this.action.type === "navigation_url") {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: this.action.src,
        }
      });
    } else {
      throw new Error(`Unknown action type: ${this.action.type}`);
    }
  }

  _getNavigationObjectFromActionResult(result) {
    return {
      type: this._mapApexCallbackToNavigationMixinType(this.action.callback.type),
      attributes: {
        name: this.action.callback.name,
      },
      state: Object.entries(this.action.callback.args)
        .map(([key, value]) => {
          return [key, value.replace("{!placeholder}", result)];
        })
        .reduce((acc, [key, value]) => {
          acc[key] = value;
          return acc;
        }, {})
    };
  }

  _mapApexCallbackToNavigationMixinType(callbackType) {
    switch (callbackType) {
      case "navigate__namedPage":
        return "comm__namedPage";
      case "navigate__url":
        return "standard__webPage";
      default:
        throw new Error(`Unknown callback type: ${callbackType}`);
    }
  }
}
