import {LightningElement, api} from 'lwc';
import {classNames} from 'c/utils';

export default class AccordionBase extends LightningElement {
    /**
     * @type {AccordionItem[]}
     */
    @api items;

    /**
     * @type {string[]}
     */
    visibleIds = [];

    connectedCallback() {
        console.log('AccordionBase connectedCallback', JSON.stringify(this.items));
    }

    get displayableItems() {
        const baseArrowClasses = 'w-3 h-3 shrink-0';
        const sharedButtonClasses = 'flex items-center justify-between w-full p-5 font-medium rtl:text-right text-gray-500 border border-gray-200 focus:ring-4 focus:ring-gray-200 hover:bg-gray-100 gap-3';
        const sharedContentClasses = 'p-5 border border-gray-200';

        return this.items.map((item, i) => ({
            id: i.toString(),
            ...item,
            buttonClasses: classNames(
                sharedButtonClasses,
                {
                    'border-b-0 rounded-t-xl': this.items.length > 1 ? i === 0 : false,
                    'border-b-0': i > 0 && i < this.items.length - 1,
                    'bg-gray-100': this.visibleIds.includes(i.toString())
                }),
            contentContainerClasses: classNames({'hidden': !this.visibleIds.includes(i.toString())}),
            contentClasses: classNames(
                sharedContentClasses,
                {'border-b-0': i !== this.items.length - 1},
                {'border-t-0': i === this.items.length - 1},
            ),
            arrowClasses: classNames(
                baseArrowClasses,
                {'rotate-180': !this.visibleIds.includes(i.toString())},
            ),
        }));
    }

    handleClick(event) {
        const {id} = event.currentTarget.dataset;
        this.visibleIds = this.visibleIds.includes(id)
            ? this.visibleIds.filter(visibleId => visibleId !== id)
            : [...this.visibleIds, id];
    }
}