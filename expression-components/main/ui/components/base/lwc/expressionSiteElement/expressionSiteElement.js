import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { CurrentPageReference } from "lightning/navigation";
import { wire } from "lwc";

export default class ExpressionSiteElement extends TwElement {
  // These 4 need to be set by the extending class as `@api` properties.
  contextUrlParam;
  previewContextId;
  expr;
  respectSharing;

  currentPageReference;
  computed;
  error;
  contextId = null

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
    if (this.contextUrlParam) {
      this.contextId = this.isInBuilder ? this.previewContextId : this.currentPageReference.state[this.contextUrlParam];
    }
  }

  @wire(evaluate, {recordId: '$contextId', formula: '$expr', respectSharing: '$respectSharing'})
  evaluate({error, data}) {
    if (error) {
      console.error(error);
      this.error = error.body.message;
    } else {
      this.computed = data;
      this.validate();
    }
  }

  get loading() {
    return !this.computed && !this.error;
  }

  get hasError() {
    return this.error;
  }

  get ready() {
    return !this.loading && !this.hasError && !this.cannotShowPreview;
  }

  get isInBuilder() {
    return this.currentPageReference?.state?.app === 'commeditor';
  }

  get cannotShowPreview() {
    // If in the builder, and the contextUrlParam is set but the previewContextId is not,
    // then we cannot show the preview.
    if (!this.contextUrlParam) {
      return false;
    }

    if (this.isInBuilder) {
      return !this.previewContextId;
    }

    return false;
  }

  validate() {}
}