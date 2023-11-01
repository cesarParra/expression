import { LightningElement } from 'lwc';

/**
 * @slot Form-Region
 */
export default class Form extends LightningElement {
  // Holds any values from "input" fields placed within the Form-Region.
  // Gets added to the "args" property during submission.
  _values = {};

  _children = [];

  connectedCallback() {
    this.template.addEventListener('childregister', this.registerChild);
    this.template.addEventListener('inputchange', this.registerValue)
    this.template.addEventListener('submit', this.submit)
  }

  registerChild = (event) => {
    event.stopPropagation();
    this._children.push(event.target);
  }

  registerValue = (event) => {
    event.stopPropagation();
    const {detail} = event;
    this._values[detail.name] = detail.value;
  }

  submit = async (event) => {
    event.stopPropagation();
    const {detail} = event;

    const isValid =
      this._children
        .reduce(
          (acc, htmlElement) => {
            return (htmlElement.reportValidity ? htmlElement.reportValidity() : true) && acc;
          },
          true);

    if (!isValid) {
      return;
    }

    const args = [...detail.fnReference.args, this._values];
    const result = await detail.action({fnReference: {...detail.fnReference, args: args}});
    detail.callback(result);
  }
}
