import {api} from 'lwc';
import TwElement from "c/twElement";
import {NavigationMixin} from "lightning/navigation";
import {RefreshEvent} from "lightning/refresh";
import execute from '@salesforce/apex/FormulaEvaluatorUiController.execute';
import {classNames} from 'c/utils';

export default class BaseButton extends NavigationMixin(TwElement) {
  /**
   * @typedef ApexFunction
   * @property { string } class
   * @property { Object[] } args
   */

  /**
   * @typedef ApexFunctionCallback
   * @property { "navigate__namedPage" | "navigate__url", "reload", "refresh" } type
   * @property { string } name
   * @property { Object } args
   */

  /**
   * The action to execute when the button is clicked
   * @property {string} label
   * @property {"action", "submit" | "navigation_namedPage" | "navigation_url" } type
   * @property {string | ApexFunction} src
   * @property {ApexFunctionCallback} callback
   */
  @api action;

  @api size = "md";

  @api variant = "primary";

  disabled = false;

  get btnClasses() {
    switch (this.variant) {
      case "primary":
        return classNames(
          'block rounded-md bg-dxp-brand text-center text-sm font-semibold w-full ' +
          'leading-6 text-dxp-brand-foreground shadow-sm hover:bg-dxp-brand-1 focus-visible:outline ' +
          'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-dxp-brand-3 ' +
          'hover:no-underline disabled:opacity-50 disabled:cursor-not-allowed',
          {'px-3 py-2': this.size === "md"},
          {'px-3.5 py-2.5': this.size === "lg"},
        );
      case "secondary":
        return classNames(
          'text-sm font-semibold leading-6 text-dxp-brand'
        );
      default:
        throw new Error(`Unknown variant: ${this.variant}`);
    }
  }

  async executeAction(e) {
    e.preventDefault();
    e.stopPropagation();

    // TODO: This needs to be more robust because it doesn't work for refresh
    // and also doesn't work if the validation fails on a submit.
    this.disabled = true;

    if (this.action.type === 'submit') {
      const evt = new CustomEvent('submit',
        {
          bubbles: true,
          detail: {action: execute, fnReference: this.action.src, callback: this.actionCallback},
          composed: true
        });
      this.dispatchEvent(evt);
    } else if (this.action.type === "action") {
      try {
        const result = await execute({fnReference: this.action.src});
        this.actionCallback(result);
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

  get displayAsAnchor() {
    return this.action.type === "navigation_namedPage" || this.action.type === "navigation_url";
  }

  get displayAsButton() {
    return this.action.type === "submit" || this.action.type === "action";
  }

  actionCallback = (result) => {
    switch (this.action.callback.type) {
      case "reload":
        this.dispatchEvent(new RefreshEvent());
        break;
      case "refresh":
        this.dispatchEvent(new CustomEvent('expression_refresh', {bubbles: true, composed: true}));
        break;
      case "navigate__namedPage":
      case "navigate__url":
        this._navigate(result);
        break;
      default:
        throw new Error(`Unknown callback type: ${this.action.callback.type}`);
    }
  }

  _navigate(result) {
    this[NavigationMixin.Navigate](this._getNavigationObjectFromActionResult(result));
  }

  _getNavigationObjectFromActionResult = (result) => {
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
