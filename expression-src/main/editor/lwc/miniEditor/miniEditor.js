import { LightningElement, api } from 'lwc';
import { getFunctionsAndOperators } from 'c/functions';
import monaco from '@salesforce/resourceUrl/monaco';
import getFunctions from "@salesforce/apex/PlaygroundController.getFunctionNames";
import validate from '@salesforce/apex/PlaygroundController.validate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MiniEditor extends LightningElement {
  @api
  title = 'Expression Editor';

  @api
  placeholder = "Your Expression";

  /**
   * Deprecated: Use variant instead.
   * @type {boolean}
   */
  @api
  displayAsTextArea = false;

  /**
   *
   * @type {"input" | "textarea" | "editor"}
   */
  @api
  variant = "editor";

  @api
  defaultExpression = '';

  @api
  enableValidation = false;

  @api
  recordId = '';

  iframeUrl = `${monaco}/main.html`;

  categories = [];
  expression = '';
  lastHoveredFunction = null;
  result = {};
  diagnostics = {
    cpuTime: "Unavailable",
    dmlStatements: "Unavailable",
    queries: "Unavailable",
    queryRows: "Unavailable",
  };
  ast = "";
  showResults = false;

  async connectedCallback() {
    this.categories = await getFunctionsAndOperators();
    this.expression = this.defaultExpression;
  }

  get displayAsInput() {
    return this.variant === 'input';
  }

  get displayAsTextareaVariant() {
    return this.variant === 'textarea';
  }

  get displayAsEditor() {
    return this.variant === 'editor';
  }

  get showValidationButton() {
    return this.enableValidation && (this.variant === 'editor' || this.variant === 'textarea');
  }

  get resultColor() {
    return this.result.type === 'error' ? 'slds-text-color_error' : 'slds-text-color_default';
  }

  async iframeLoaded() {
    const functionKeywords = await getFunctions();
    this.iframeWindow.postMessage({
      name: 'initialize',
      keywords: functionKeywords,
      initialValue: this.expression
    });

    window.addEventListener('message', (event) => {
      const {name, payload} = event.data;
      if (name === 'content_change') {
        this.expression = payload;
      }
    }, false);
  }

  get iframeWindow() {
    return this.template.querySelector('iframe').contentWindow;
  }

  get displayFunctions() {
    const data = this.categories.map((category) => {
      return {
        ...category,
        values: category.values.map((value) => {
          return {
            ...value,
            icon: value.icon || category.icon
          };
        })
      };
    });

    function filter(expression) {
      if (!expression) {
        return data;
      }

      const rightmostWord = expression.split(" ").pop() ?? expression;
      const filteredData = data
        .map((category) => {
          const filteredValues = category.values.filter((value) =>
            value.name.toLowerCase().startsWith(rightmostWord.toLowerCase())
          );
          return {
            ...category,
            values: filteredValues,
          };
        })
        .filter((category) => category.values.length > 0);

      return filteredData.length > 0 ? filteredData : data;
    }

    return filter(this.expression);
  }

  handleExpressionChange(event) {
    this.expression = event.target.value;
  }

  handleExpressionSaved() {
    this.dispatchEvent(new CustomEvent('save', {
      detail: {
        expression: this.expression,
      }
    }));
  }

  handleMouseEnter(event) {
    const hoveredElementName = event.target.dataset.name;

    // Find the function by loooping through each category,
    // then each value until found
    for (const category of this.categories) {
      const foundValue = category.values.find((value) => value.name === hoveredElementName);
      if (foundValue) {
        this.lastHoveredFunction = foundValue;
        break;
      }
    }
  }

  handleFunctionClick(event) {
    event.preventDefault();
    const functionName = event.target.dataset.name;
    if (!functionName) {
      return;
    }

    // Find the function to insert
    for (const category of this.categories) {
      const foundValue = category.values.find((value) => value.name === functionName);
      if (foundValue) {
        const functionToInsert = foundValue.autoCompleteValue || foundValue.name;

        if (this.variant === 'editor') {
          // For Monaco editor, send message to iframe
          this.iframeWindow.postMessage({
            name: 'append',
            payload: functionToInsert
          });
        } else if (this.variant === 'textarea' || this.variant === 'input') {
          // For textarea and input, insert at cursor position
          const inputElement = this.template.querySelector(`${this.variant}[name="expression"]`);
          if (inputElement) {
            const start = inputElement.selectionStart;
            const end = inputElement.selectionEnd;
            const text = inputElement.value;
            const before = text.substring(0, start);
            const after = text.substring(end, text.length);

            this.expression = before + functionToInsert + after;
            inputElement.value = this.expression;

            // Set cursor position after inserted text
            setTimeout(() => {
              const newPosition = start + functionToInsert.length;
              inputElement.setSelectionRange(newPosition, newPosition);
              inputElement.focus();
            }, 0);
          }
        }
        break;
      }
    }
  }

  handleRecordIdChange(event) {
    this.recordId = event.target.value;
  }

  async handleValidate() {
    if (!this.expression) {
      return;
    }

    if (this.variant === 'editor') {
      this.iframeWindow.postMessage({
        name: 'clear_markers'
      });
    }

    try {
      const result = await validate({ expr: this.expression, recordId: this.recordId });
      if (result.error) {
        this.result = {
          type: "error",
          payload: [{ type: 'error', message: result.error.message }]
        };

        if (this.variant === 'editor') {
          this.iframeWindow.postMessage({
            name: 'evaluation_error',
            payload: result.error
          });
        }
      } else {
        const payload = result.result ?? null;
        const toPrint = result.toPrint.map((item) => item ?? null);
        const allResults = [...toPrint, payload];
        this.result = {
          type: "success",
          payload: allResults.map((current, i) => ({
            type: i === allResults.length - 1 ? "result" : "printed",
            message: this._syntaxHighlight(JSON.stringify(current, null, 4))
          }))
        };
      }

      this._setDiagnostics(result.diagnostics ?? {});
      this.ast = result.ast ?
        this._syntaxHighlight(JSON.stringify(result.ast, null, 4)) :
        "";
      this.showResults = true;
    } catch (e) {
      const event = new ShowToastEvent({
        title: 'Unknown error',
        variant: 'error',
        message: e.body?.message || 'An unknown error occurred',
      });
      this.dispatchEvent(event);

      this.result = {
        type: "error",
        payload: [{ type: 'error', message: 'An unknown error occurred while evaluating the expression.' }]
      };
      this.showResults = true;
    }
  }

  _setDiagnostics(diagnostics) {
    this.diagnostics = Object.keys(diagnostics).reduce((acc, key) => {
      acc[key] = diagnostics[key] ?? "Unavailable";
      return acc;
    }, {
      cpuTime: "Unavailable",
      dmlStatements: "Unavailable",
      queries: "Unavailable",
      queryRows: "Unavailable",
    });
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
