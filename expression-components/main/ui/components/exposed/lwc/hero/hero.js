import ExpressionSiteElement from "c/expressionSiteElement";
import { api } from "lwc";
import { classNames } from 'c/utils';

export default class Hero extends ExpressionSiteElement {
  @api contextUrlParam;
  @api previewContextId;
  @api expr;
  @api centerItems;
  @api respectSharing;

  get containerClasses() {
    return classNames(
      'mx-auto max-w-7xl',
      {'lg:flex': this.hasImage}
    );
  }

  get mainClasses() {
    return classNames(
      'mx-auto lg:mx-0 lg:flex-shrink-0 lg:pt-8',
      {'max-w-2xl lg:max-w-xl': this.hasImage},
      {'text-center': this.centerItems}
    );
  }

  get buttonClasses() {
    return classNames(
      'mt-10 flex items-center gap-x-6',
      {'justify-center': this.centerItems}
    );
  }

  get hasImage() {
    return this.computed && this.computed.bannerImage;
  }

  validate() {
    if (!this.computed) {
      return;
    }
    // Computed should contain a "title" property.
    if (!("title" in this.computed)) {
      this.error = 'Hero component requires a title.';
    }
  }
}
