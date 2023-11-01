import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class Logos extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;
  validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "title" property.
    if (!("title" in this.computed)) {
      this.error = 'Hero component requires a title.';
    }

    // Computed should contain a "logos" property.
    if (!("logos" in this.computed)) {
      this.error = 'Hero component requires a "logos" key.';
    }
  }
}
