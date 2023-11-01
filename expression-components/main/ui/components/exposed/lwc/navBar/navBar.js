import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";

export default class NavBar extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;

  isOpen = false;
  toggle() {
    this.isOpen = !this.isOpen;
  }
}
