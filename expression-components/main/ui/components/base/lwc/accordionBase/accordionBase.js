import {LightningElement, api} from 'lwc';
import {classNames} from 'c/utils';

export default class AccordionBase extends LightningElement {
    /**
     * @type {AccordionItem[]}
     */
    @api items;

    /**
     * Whether to collapse all other items when one is opened. Defaults to false.
     * @type {boolean}
     */
    @api autoCollapse = false;

    /**
     * @type {string[]}
     */
    _visibleIds = [];

    get displayableItems() {
        const baseArrowClasses = 'w-3 h-3 shrink-0';
        const sharedButtonClasses = 'flex items-center justify-between w-full p-5 font-medium text-dxp-text-contrast border border-gray-200 focus:ring-4 focus:ring-text-contrast-2 hover:bg-brand-foreground gap-3';
        const sharedContentClasses = 'p-5 border border-gray-200';

        return this.items.map((item, i) => ({
            id: i.toString(),
            ...item,
            buttonClasses: classNames(
                sharedButtonClasses,
                {
                    'border-b-0 rounded-t-xl': this.items.length > 1 ? i === 0 : false,
                    'border-b-0': i > 0 && i < this.items.length - 1,
                    'bg-gray-100': this._visibleIds.includes(i.toString())
                }),
            contentContainerClasses: classNames({'hidden': !this._visibleIds.includes(i.toString())}),
            contentClasses: classNames(
                sharedContentClasses,
                {'border-b-0': i !== this.items.length - 1},
                {'border-t-0': i === this.items.length - 1},
            ),
            arrowClasses: classNames(
                baseArrowClasses,
                {'rotate-180': !this._visibleIds.includes(i.toString())},
            ),
        }));
    }

    handleClick(event) {
        const {id} = event.currentTarget.dataset;
        this._handleToggled(id);
    }

    _handleToggled(id) {
        if (this.autoCollapse) {
            this._toggleAutoCollapse(id);
        } else {
            this._toggleNoAutoCollapse(id);
        }
    }

    _toggleAutoCollapse(id) {
        this._visibleIds = this._visibleIds.includes(id) ? [] : [id];
    }

    _toggleNoAutoCollapse(id) {
        this._visibleIds = this._visibleIds.includes(id)
            ? this._visibleIds.filter(visibleId => visibleId !== id)
            : [...this._visibleIds, id];
    }
}