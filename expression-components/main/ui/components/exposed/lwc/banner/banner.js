import {api} from "lwc";
import ExpressionSiteElement from "c/expressionSiteElement";
import {z} from 'c/zod';

export default class Banner extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;
  @api stickyVariant;
  @api dismissable;

  get stickyVariantLowered() {
    return this.stickyVariant?.toLowerCase();
  }

  validate() {
    if (!this.computed) {
      return;
    }

    const bannerSchema = z.string();

    const validationResult = bannerSchema.safeParse(this.computed);
    if (!validationResult.success) {
      this.error = {
        message: 'Banner component requires a string.',
        rawError: JSON.stringify(validationResult.error.format(), null, 2),
      };
      return;
    }
  }
}
