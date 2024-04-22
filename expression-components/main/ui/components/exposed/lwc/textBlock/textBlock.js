import ExpressionSiteElement from "c/expressionSiteElement";
import {api} from "lwc";
import {classNames} from 'c/utils';
import {z} from 'c/zod';

export default class TextBlock extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api respectSharing;
  @api textAlignment;
  @api color;

  get containerClasses() {
    return classNames(
      {'text-center': this.textAlignment === 'Center'},
      {'text-right': this.textAlignment === 'Right'},
      {'text-left': this.textAlignment === 'Left'},
    );
  }

  get textStyle() {
    return 'color: ' + this.color + ';"';
  }

  validate() {
    if (!this.computed) {
      return;
    }

    const textBlockSchema = z.string();

    const validationResult = textBlockSchema.safeParse(this.computed);
    if (!validationResult.success) {
      this.error = {
        message: 'Text Block component requires a string.',
        rawError: JSON.stringify(validationResult.error.format(), null, 2),
      };
    }
  }
}
