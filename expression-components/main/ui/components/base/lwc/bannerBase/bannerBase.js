import {api} from 'lwc';
import {LightningElement} from 'lwc';

export default class BannerBase extends LightningElement {
  @api
  content;
}
