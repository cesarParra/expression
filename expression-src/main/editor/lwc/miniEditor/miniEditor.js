import { LightningElement, api } from 'lwc';
import { getFunctionsAndOperators } from 'c/functions';

export default class MiniEditor extends LightningElement {
  @api
  title = 'Expression Editor';

  @api
  placeholder = "Your Expression";

  @api
  displayAsTextArea = false;

  @api
  defaultExpression = '';

  categories = [];
  expression = '';
  lastHoveredFunction = null;

  async connectedCallback() {
    this.categories = await getFunctionsAndOperators();
    this.expression = this.defaultExpression;
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
}
