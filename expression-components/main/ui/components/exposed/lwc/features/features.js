import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class Features extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;

  get hasText() {
    return this.computed?.title || this.computed?.description;
  }

  validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "features" property.
    if (!("features" in this.computed)) {
      this.error = 'Features component requires "features".';
    }
  }
}
