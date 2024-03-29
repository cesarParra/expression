import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from 'lwc';
import {z} from 'c/zod';

export default class Avatar extends ExpressionSiteElement {
    @api contextUrlParam;
    @api previewContextId;
    @api expr;
    @api respectSharing;
    @api size;

    get sizeLowerecased() {
        return this.size?.toLowerCase();
    }

    /**
     * @return {AvatarItem}
     */
    validate() {
        if (!this.computed) {
            return;
        }

        const avatarSchema = z.union([
            z.object({
                initials: z.string(),
            }),
            z.object({
                avatarUrl: z.string(),
            }),
            z.object({
                useIcon: z.boolean()
            })
        ]);

        const validationResult = avatarSchema.safeParse(this.computed);
        if (!validationResult.success) {
            this.error = {
                message: 'Avatar component requires an object with "initials", "avatarUrl" or "useIcon" properties.',
                rawError: JSON.stringify(validationResult.error.format(), null, 2),
            };
        }
    }
}
