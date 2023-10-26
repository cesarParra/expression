import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class Status extends ExpressionSiteElement {
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
    // Computed should contain a "stats" property.
    if (!("stats" in this.computed)) {
      this.error = 'Status component requires a "stats" key.';
    }
  }
}
