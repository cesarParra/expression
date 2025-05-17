import { LightningElement } from 'lwc';

export default class MiniEditorExample extends LightningElement {
  handleExpressionSaved(event) {
    console.log('Expression saved:', event.detail.expression);
  }
}
