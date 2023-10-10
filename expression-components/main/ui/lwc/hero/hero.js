import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";
import { classNames } from 'c/utils';

export default class Hero extends TwElement {
  @api expr;
  @api centerItems;

  computed;
  error;

  @wire(evaluate, {recordId: '', formula: '$expr'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
      this._validate();
    }
  }

  get loading() {
    return !this.computed && !this.error;
  }

  get hasError() {
    return this.error;
  }

  get ready() {
    return !this.loading && !this.hasError;
  }

  get containerClasses() {
    return classNames(
      'mx-auto max-w-7xl',
      {'lg:flex': this.hasImage}
    );
  }

  get mainClasses() {
    return classNames(
      'mx-auto lg:mx-0 lg:flex-shrink-0 lg:pt-8',
      {'max-w-2xl lg:max-w-xl': this.hasImage},
      {'text-center': this.centerItems}
    );
  }

  get buttonClasses() {
    return classNames(
      'mt-10 flex items-center gap-x-6',
      {'justify-center': this.centerItems}
    );
  }

  get hasImage() {
    return this.computed && this.computed.bannerImage;
  }

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "title" property.
    if (!("title" in this.computed)) {
      this.error = 'Hero component requires a title.';
    }
  }
}
