import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from "lwc";

export default class Accordion extends ExpressionSiteElement {
    @api contextUrlParam;
    @api previewContextId;
    @api expr;
    @api respectSharing;

    get someItems() {
        return [
            {
                title: 'Item 1',
                content: 'Content of item 1'
            },
            {
                title: 'Item 2',
                content: 'Content of item 2'
            },
            {
                title: 'Item 3',
                content: 'Content of item 3'
            }
        ];
    }
}