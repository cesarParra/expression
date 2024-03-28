import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from 'lwc';
import {z} from 'c/zod';

export default class Alert extends ExpressionSiteElement {
    @api contextUrlParam;
    @api previewContextId;
    @api expr;
    @api respectSharing;

    validate() {
        if (!this.computed) {
            return;
        }

        const alertSchema = z.object({
            title: z.string(),
            message: z.string(),
            type: z.union([z.literal('info'), z.literal('warning'), z.literal('error'), z.literal('success'), z.literal('neutral')])
        });
        
        const validationResult = alertSchema.safeParse(this.computed);
        if (!validationResult.success) {
            this.error = {
                message: 'Alert component requires an array of objects with "title", "message" and "type" properties.',
                rawError: JSON.stringify(validationResult.error.format(), null, 2),
            };
            return;
        }
    }
}
