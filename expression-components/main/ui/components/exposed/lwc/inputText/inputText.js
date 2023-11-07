import { api } from "lwc";
import TwElement from "c/twElement";
import { classNames } from 'c/utils';

export default class InputText extends TwElement {
  @api label;
  @api name;
  @api required;
  @api errorMessage;

  value = "";
  hasValidationError = false;

  @api
  reportValidity() {
    if (this.required && !this.value) {
      this.hasValidationError = true;
      return false;
    }
    this.hasValidationError = false;
    return true;
  }

  connectedCallback() {
    super.connectedCallback();
    this.dispatchEvent(new CustomEvent('childregister', {bubbles: true, composed: true, detail: {}}));
  }


  handleChange(event) {
    this.value = event.target.value;
    const sampleEvent = new CustomEvent(
      'inputchange',
      {
        bubbles: true,
        detail: {value: this.value, name: this.name},
        composed: false
      });
    this.dispatchEvent(sampleEvent);
  }

  get inputClasses() {
    return classNames(
      'block w-full rounded-md border-gray-300 shadow-sm focus:border-dxp-brand-1 ' +
      'focus:ring-dxp-brand-1 sm:text-sm',
      {'text-red-900 border-0 py-1.5 pr-10 text-red-900 ring-1 ring-inset ring-red-300 placeholder:text-red-300 focus:ring-2 focus:ring-inset focus:ring-red-500': this.hasValidationError}
    );
  }

  get validationErrorMessage() {
    return this.errorMessage ?? 'Please complete this field.';
  }
}
