import {api} from 'lwc';
import {LightningElement} from 'lwc';
import {classNames} from 'c/utils';

export default class BannerBase extends LightningElement {
  @api
  content;

  /**
   * @type {"top" | "bottom" | "none"}
   */
  @api
  stickyVariant = 'top';

  @api
  dismissable = false;

  get bannerClasses() {
    const shared = 'start-0 z-50 flex justify-between w-full p-4 border-gray-200 bg-gray-50';

    return classNames(
      shared,
      {'fixed': this.stickyVariant !== 'none'},
      {'top-0 border-b': this.stickyVariant === 'top'},
      {'bottom-0 border-t': this.stickyVariant === 'bottom'},
      {'border': this.stickyVariant === 'none'}
    );
  }
}
