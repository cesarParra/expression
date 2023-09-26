import {api, LightningElement} from 'lwc';

export default class Alert extends LightningElement {
  @api title;
  @api message;
}
