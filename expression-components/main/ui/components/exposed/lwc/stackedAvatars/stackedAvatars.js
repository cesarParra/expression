import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from 'lwc';
import {z} from 'c/zod';

export default class StackedAvatars extends ExpressionSiteElement {
    @api contextUrlParam;
    @api previewContextId;
    @api expr;
    @api respectSharing;
    @api size;
    @api displayStyle;

    get sizeLowerecased() {
        return this.size?.toLowerCase();
    }

    get styleLowercased() {
        return this.displayStyle?.toLowerCase();
    }

    get computedWithIds() {
        if (!this.computed) {
            return;
        }
        console.log(JSON.stringify(this.computed, null, 2));
        return this.computed.map((avatar, index) => {
            console.log(JSON.stringify(avatar, null, 2));
            return {
                ...avatar,
                id: index,
            };
        });
    }

    validate() {
        if (!this.computed) {
            return;
        }

        const avatarSchema = z.array(z.union([z.object({
            initials: z.string(),
        }), z.object({
            avatarUrl: z.string(),
        }), z.object({
            useIcon: z.boolean()
        })]));

        const validationResult = avatarSchema.safeParse(this.computed);
        if (!validationResult.success) {
            this.error = {
                message: 'Stacked Avatars component requires a list of objects with "initials", "avatarUrl" or "useIcon" properties.',
                rawError: JSON.stringify(validationResult.error.format(), null, 2),
            };
        }
    }
}
