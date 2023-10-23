import { LightningElement, wire } from 'lwc';
import getFunctions from '@salesforce/apex/PlaygroundController.getCustomFunctions';
import { operators } from './operators';
import { data } from './functions';

export default class FunctionLibrary extends LightningElement {
  _categories;
  functionWithOpenDocumentation;
  isDocumentationPinned = false;

  @wire(getFunctions)
  handleGetPricingVariablesWire({data, error}) {
    if (data && data.length) {
      this._categories = data.map((category) => {
        return {
          category: category.name,
          values: category.functions.map((fn) => {
            return {
              name: fn.name,
              autoCompleteValue: fn.autoCompleteValue,
              icon: category.icon,
              description: fn.description,
              examples: fn.example ? [fn.example] : undefined
            };
          })
        };
      });
    } else if (error) {
      console.error(error.body.message);
      this._categories = undefined;
    }
  }

  get availableFormulaFunctionsAndOperators() {
    let availableFunctionsAndOperators = [...operators, ...data];
    if (this._categories) {
      availableFunctionsAndOperators = [...availableFunctionsAndOperators, ...this._categories];
    }
    return availableFunctionsAndOperators;
  }

  handleDisplayFunctionDocumentation(event) {
    const functionName = event.target.dataset.item;
    if (!functionName) {
      return;
    }
    this.functionWithOpenDocumentation = this.getFunctionByName(functionName);
  }

  handlePinFunctionDocumentation(event) {
    event.preventDefault();
    this.isDocumentationPinned = !this.isDocumentationPinned;
  }

  handleCloseDocumentation(event) {
    event.preventDefault();
    this.isDocumentationPinned = false;
    this.functionWithOpenDocumentation = undefined;
  }

  handleHideFunctionDocumentation() {
    if (this.isDocumentationPinned) {
      return;
    }
    this.functionWithOpenDocumentation = undefined;
  }

  handleFunctionClick(event) {
    event.preventDefault();
    const functionName = event.target.dataset.item;
    if (!functionName) {
      return;
    }
    const functionToAppend = this.getFunctionByName(functionName);
    const clickEvent = new CustomEvent('selected', {
      detail: functionToAppend.autoCompleteValue
    });
    this.dispatchEvent(clickEvent);
  }

  getFunctionByName(functionName) {
    const availableFunctions = this.availableFormulaFunctionsAndOperators.map((item) => item.values).flat();
    return availableFunctions.find(item => item.name === functionName);
  }
}
