import {LightningElement} from 'lwc';
import {getFunctionsAndOperators} from 'c/functions';

export default class FunctionLibrary extends LightningElement {
  functionWithOpenDocumentation;
  isDocumentationPinned = false;
  availableFormulaFunctionsAndOperators = [];

  async connectedCallback() {
    this.availableFormulaFunctionsAndOperators = await getFunctionsAndOperators();
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
