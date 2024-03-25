import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from "lwc";

export default class Accordion extends ExpressionSiteElement {
    @api contextUrlParam;
    @api previewContextId;
    @api expr;
    @api respectSharing;

    validate() {
        if (!this.computed) {
            return;
        }
        // Computed should be a list
        if (!Array.isArray(this.computed)) {
            this.error = 'Accordion component requires a list of items.';
        }
    }
}