import { LightningElement, api } from 'lwc';

export default class ExpressionElementContainer extends LightningElement {
  @api cannotShowPreview = false;
  @api error = null;
  @api loading = false;
}
