import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { api, wire } from "lwc";
import { classNames } from 'c/utils';

export default class TextBlock extends TwElement {
  @api expr;
  @api textAlignment;
  @api color;

  computed;
  error;

  @wire(evaluate, {recordId: '', formula: '$expr'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
    }
  }

  get containerClasses() {
    return classNames(
      {'text-center': this.textAlignment === 'Center'},
      {'text-right': this.textAlignment === 'Right'},
      {'text-left': this.textAlignment === 'Left'},
    );
  }

  get textStyle() {
    return 'color: ' + this.color + ';"';
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
}
