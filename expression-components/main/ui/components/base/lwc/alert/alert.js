import { api, LightningElement } from 'lwc';
import { classNames } from 'c/utils';

export default class Alert extends LightningElement {
  @api title;
  @api message;
  /**
   * The variant changes the appearance of the alert.
   * Accepted variants include:
   * - error
   * - warning
   */
  @api type;

  get containerClasses() {
    return classNames(
      'rounded-md p-4',
      {'bg-red-50': this.isError},
      {'bg-yellow-50': this.isWarning},
    );
  }

  get titleTextClasses() {
    return classNames(
      'text-sm font-medium',
      {'text-red-800': this.isError},
      {'text-yellow-800': this.isWarning},
    );
  }

  get messageTextClasses() {
    return classNames(
      'mt-2 text-sm',
      {'text-red-700': this.isError},
      {'text-yellow-700': this.isWarning},
    );
  }

  get isWarning() {
    return this.type === 'warning';
  }

  get isError() {
    return this.type === 'error';
  }
}
