import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class Button extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;

  validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "label" property.
    if (!("label" in this.computed)) {
      this.error = 'Button component requires "label".';
    }
    if (!("label" in this.computed)) {
      this.error = 'Button component requires "label".';
    }
    if (!("type" in this.computed)) {
      this.error = 'Button component requires "type".';
    }
    if (!("src" in this.computed)) {
      this.error = 'Button component requires "src".';
    }
  }
}
