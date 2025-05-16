import { LightningElement, api } from 'lwc';
import { getFunctionsAndOperators } from 'c/functions';

export default class MiniEditor extends LightningElement {
  @api
  title = 'Expression Editor';

  @api
  placeholder = "Your Expression";

  categories = [];
  preview = '';
  lastHoveredFunction = null;

  async connectedCallback() {
    this.categories = await getFunctionsAndOperators();
  }

  handleMouseEnter(event) {
    console.log('handleOnMouseEnter', event);
    const hoveredElementName = event.target.dataset.name;
    console.log('hoveredElementName', hoveredElementName);

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
