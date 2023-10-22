import { LightningElement, wire } from 'lwc';
import getFunctions from '@salesforce/apex/PlaygroundController.getFunctions';
import { operators } from './operators';

export default class FunctionLibrary extends LightningElement {
  _functions;
  _errorMessage;

  @wire(getFunctions)
  handleGetPricingVariablesWire({data, error}) {
    if (data && data.length) {
      this._functions = {
        category: "Functions",
        values: data.map((fn) => {
          return {
            name: fn,
            autoCompleteValue: fn,
            icon: "utility:apex_plugin",
            description: "",
            syntax: fn,
            examples: [
              fn
            ]
          };
        })
      };
    } else if (error) {
      this._errorMessage = error.body.message;
      this._functions = undefined;
    }
  }

  get availableFormulaFunctionsAndOperators() {
    let availableFunctionsAndOperators = operators;
    if (this._functions) {
      availableFunctionsAndOperators = [this._functions, ...availableFunctionsAndOperators];
    }
    return availableFunctionsAndOperators;
  }

  functionWithOpenDocumentation;

  handleDisplayFunctionDocumentation(event) {
    const functionName = event.target.dataset.item;
    if (!functionName) {
      return;
    }
    this.functionWithOpenDocumentation = this.getFunctionByName(functionName);
  }

  handleHideFunctionDocumentation() {
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
