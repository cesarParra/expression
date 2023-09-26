import {LightningElement} from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";

import tw from '@salesforce/resourceUrl/tw';

export default class TwElement extends LightningElement {
  connectedCallback() {
    this.template.host.style.opacity = "0";
    loadStyle(this, `${tw}/css/main.css`).then(() => {
      this.template.host.style.opacity = "1";
    });
  }
}
