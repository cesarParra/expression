import {api, LightningElement} from 'lwc';
import {classNames} from 'c/utils';

export default class AlertBase extends LightningElement {
    @api title;
    @api message;
    /**
     * The variant changes the appearance of the alert.
     * Accepted variants include:
     * @type {"error" | "warning" | "success" | "info" | "neutral"}
     */
    @api type;
    @api rawError;

    get containerClasses() {
        return classNames(
            'rounded-md p-4',
            {'bg-red-50': this.isError},
            {'bg-yellow-50': this.isWarning},
            {'bg-blue-50': this.isInfo},
            {'bg-green-50': this.isSuccess},
            {'bg-gray-50': this.isNeutral},
        );
    }

    get titleTextClasses() {
        return classNames(
            'text-sm font-medium',
            {'text-red-800': this.isError},
            {'text-yellow-800': this.isWarning},
            {'text-blue-800': this.isInfo},
            {'text-green-800': this.isSuccess},
            {'text-gray-800': this.isNeutral},
        );
    }

    get messageTextClasses() {
        return classNames(
            'mt-2 text-sm',
            {'text-red-700': this.isError},
            {'text-yellow-700': this.isWarning},
            {'text-blue-700': this.isInfo},
            {'text-green-700': this.isSuccess},
            {'text-gray-700': this.isNeutral},
        );
    }

    get isWarning() {
        return this.type === 'warning';
    }

    get isError() {
        return this.type === 'error';
    }

    get isInfo() {
        return this.type === 'info';
    }

    get isSuccess() {
        return this.type === 'success';
    }

    get isNeutral() {
        return this.type === 'neutral';
    }
}
