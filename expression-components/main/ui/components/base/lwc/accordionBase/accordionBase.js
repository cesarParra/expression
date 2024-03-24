import {LightningElement, api} from 'lwc';
import {classNames} from 'c/utils';

export default class AccordionBase extends LightningElement {
    @api alwaysOpen = false;
    /**
     * @type {AccordionItem[]}
     */
    @api items;

    connectedCallback() {
        console.log('AccordionBase connectedCallback', JSON.stringify(this.items));
    }

    get displayableItems() {
        const sharedClasses = 'flex items-center justify-between w-full p-5 font-medium rtl:text-right text-gray-500 border border-gray-200 focus:ring-4 focus:ring-gray-200 hover:bg-gray-100 gap-3';

        return this.items.map((item, i) => ({
            ...item,
            buttonClasses: classNames(
                sharedClasses,
                {
                    'border-b-0 rounded-t-xl': i === 0,
                    'border-b-0': i > 0 && i < this.items.length - 1,
                }
            ),
        }));
    }
}