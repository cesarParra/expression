import {api, LightningElement} from 'lwc';
import {classNames} from 'c/utils';

export default class AvatarBase extends LightningElement {
    /**
     * @type {AvatarItem}
     */
    @api avatarItem;

    /**
     * @type {"small" | "medium" | "large"}
     */
    @api size;

    get shouldUseImageUrl() {
        return this.avatarItem && this.avatarItem.avatarUrl;
    }

    get shouldUseInitials() {
        return this.avatarItem && this.avatarItem.initials;
    }

    get shouldUseIcon() {
        return this.avatarItem && this.avatarItem.useIcon;
    }

    get avatarContainerClasses() {
        return classNames(
            'rounded-full',
            {
                // Common for initials and icon based avatars
                'relative overflow-hidden bg-gray-100': this.shouldUseInitials || this.shouldUseIcon,

                // Only for initials
                'inline-flex items-center justify-center': this.shouldUseInitials,

                // Size related classes
                'w-8 h-8': this.size === 'small',
                'w-12 h-12': this.size === 'medium',
                'w-16 h-16': this.size === 'large'
            }
        );
    }

    get iconInnerClasses() {
        return classNames(
            'absolute text-gray-400 -left-1',
            {
                'w-10 h-10': this.size === 'small',
                'w-14 h-14': this.size === 'medium',
                'w-18 h-18': this.size === 'large'
            }
        );
    }
}
