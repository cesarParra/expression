import { LightningElement } from 'lwc';
import monaco from '@salesforce/resourceUrl/monaco';
import getFunctions from '@salesforce/apex/PlaygroundController.getFunctionNames';
import validate from '@salesforce/apex/PlaygroundController.validate';

export default class Monaco extends LightningElement {
  recordId;
  iframeUrl = `${monaco}/main.html`;
  result = {};
  diagnostics = {
    cpuTime: "Unavailable",
    dmlStatements: "Unavailable",
    queries: "Unavailable",
    queryRows: "Unavailable",
  };
  ast = "";

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
      // The evaluation might return null, which is a valid result but gets converted to undefined in JS,
      // so we handle it by coercing it to null.
      const payload = result.result ?? null;
      this.result = {
        type: "success",
        payload: this._syntaxHighlight(JSON.stringify(payload, null, 4))
      }
    }

    this._setDiagnostics(result);
    this.ast = result.ast ?
      this._syntaxHighlight(JSON.stringify(result.ast, null, 4)) :
      "";
  }

  _setDiagnostics(result) {
    this.diagnostics = Object.keys(result.diagnostics).reduce((acc, key) => {
      acc[key] = result.diagnostics[key] ?? "Unavailable";
      return acc;
    }, {
      cpuTime: "Unavailable",
      dmlStatements: "Unavailable",
      queries: "Unavailable",
      queryRows: "Unavailable",
    });
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

  _syntaxHighlight(json) {
    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
      let style = 'color: #c2410c;';
      if (/^"/.test(match)) {
        if (/:$/.test(match)) {
          style = 'color: #b91c1c;';
        } else {
          style = 'color: #0f766e;';
        }
      } else if (/true|false/.test(match)) {
        style = 'color: #4338ca;';
      } else if (/null/.test(match)) {
        style = 'color: #0e7490;';
      }
      return '<span style="' + style + '">' + match + '</span>';
    });
  }
}
