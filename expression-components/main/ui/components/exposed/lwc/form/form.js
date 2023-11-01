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
    this.template.addEventListener('childregister', this.registerChild); // TODO: if the slot stuff works then get rid of this
    this.template.addEventListener('inputchange', this.registerValue)
    this.template.addEventListener('submit', this.submit)
  }

  registerChild = (event) => {
    console.log('registerChild', event);
    event.stopPropagation();
    this._children.push(event.target);
    console.log('registered children are', this._children);
    this._children.forEach(child => {
      console.log('does child has a reportValidity method?', child.reportValidity);
    });
  }

  registerValue = (event) => {
    console.log('registerValue', event);
    event.stopPropagation();
    const {detail} = event;
    this._values[detail.name] = detail.value;
  }

  submit = async (event) => {
    console.log('submit', event);
    event.stopPropagation();
    const {detail} = event;

    // const isValid =
    //   [...this.template.querySelector('slot').assignedElements()]
    //     .reduce(
    //       (acc, htmlElement) => {
    //         return acc && (htmlElement.reportValidity ? htmlElement.reportValidity() : true);
    //       },
    //       true);

    const isValid =
      this._children
        .reduce(
          (acc, htmlElement) => {
            return (htmlElement.reportValidity ? htmlElement.reportValidity() : true) && acc;
          },
          true);

    console.log('val', isValid);
    if (!isValid) {
      console.log('form is not valid');
      return;
    }

    console.log('form is valid');

    const args = [...detail.fnReference.args, this._values];
    const result = await detail.action({fnReference: {...detail.fnReference, args: args}});
    detail.callback(result);
  }
}
