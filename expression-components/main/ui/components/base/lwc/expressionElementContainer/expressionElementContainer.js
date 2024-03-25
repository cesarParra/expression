import {LightningElement, api} from 'lwc';

export default class ExpressionElementContainer extends LightningElement {
    @api cannotShowPreview = false;
    @api error = null;
    @api loading = false;

    get showLoading() {
        return this.loading && !this.cannotShowPreview;
    }

    get isErrorObject() {
        // Error (when not null) can either be a string or an object with a "message" and a "rawError" property.
        return typeof this.error === 'object';
    }

    get errorMessage() {
        return this.isErrorObject ? this.error.message : this.error;
    }

    get errorRaw() {
        return this.isErrorObject ? this.error.rawError : null;
    }
}
