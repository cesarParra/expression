import TwElement from "c/twElement";
import evaluate from '@salesforce/apex/FormulaEvaluatorUiController.evaluate';
import { CurrentPageReference } from "lightning/navigation";
import { api, wire } from "lwc";

// TODO: There's going to be way too much duplicate code now, we need to find a way to share whatever possible
export default class Features extends TwElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;

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
    return !this.loading && !this.hasError && !this.cannotShowPreview;
  }

  get hasText() {
    return this.computed?.title || this.computed?.description;
  }

  get toDelete() {
    return JSON.stringify(this.currentPageReference, null, 2);
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

  _validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "features" property.
    if (!("features" in this.computed)) {
      this.error = 'Features component requires "features".';
    }
  }
}
