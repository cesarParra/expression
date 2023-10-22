import { LightningElement } from 'lwc';
import monaco from '@salesforce/resourceUrl/monaco';
import getFunctions from '@salesforce/apex/PlaygroundController.getFunctionNames';
import validate from '@salesforce/apex/PlaygroundController.validate';

export default class Monaco extends LightningElement {
  recordId;
  iframeUrl = `${monaco}/main.html`;
  result = {};

  async iframeLoaded() {
    const functionKeywords = await getFunctions();
    this.iframeWindow.postMessage({
      name: 'initialize',
      keywords: functionKeywords
    });
  }

  async getExpression() {
    const expr = this.iframeWindow.editor.getValue();
    const result = await validate({expr: expr, recordId: this.recordId});
    if (result.error) {
      this.result = {
        type: "error",
        payload: result.error.message
      }

      this.iframeWindow.postMessage({
        name: 'evaluation_error',
        payload: result.error
      });
    } else {
      this.result = {
        type: "success",
        payload: JSON.stringify(result.result, null, 2)
      }
    }
  }

  handleInputChange(event) {
    this.recordId = event.detail.value;
  }

  handleFunctionFromLibrarySelected(event) {
    this.iframeWindow.postMessage({
      name: 'append',
      payload: event.detail
    });
  }

  get iframeWindow() {
    return this.template.querySelector('iframe').contentWindow;
  }

  get resultColor() {
    return this.result.type === 'error' ? 'slds-text-color_error' : 'slds-text-color_default';
  }
}
