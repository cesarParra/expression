import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class People extends ExpressionSiteElement {
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
    // Computed should contain a "people" property.
    if (!("people" in this.computed)) {
      this.error = "Computed data does not contain a 'people' property.";
    }
  }
}
