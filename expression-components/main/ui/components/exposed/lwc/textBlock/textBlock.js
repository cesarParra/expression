import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";
import { classNames } from 'c/utils';

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
}
