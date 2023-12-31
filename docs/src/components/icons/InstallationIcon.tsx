import {Gradient} from '@/components/Icon'
import React from "react";

export function InstallationIcon({
                                     id,
                                     color,
                                 }: {
    id: string
    color?: React.ComponentProps<typeof Gradient>['color']
}) {
    return (
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
             className="w-6 h-6 text-orange-600" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round"
                  d="M7.5 7.5h-.75A2.25 2.25 0 004.5 9.75v7.5a2.25 2.25 0 002.25 2.25h7.5a2.25 2.25 0 002.25-2.25v-7.5a2.25 2.25 0 00-2.25-2.25h-.75m-6 3.75l3 3m0 0l3-3m-3 3V1.5m6 9h.75a2.25 2.25 0 012.25 2.25v7.5a2.25 2.25 0 01-2.25 2.25h-7.5a2.25 2.25 0 01-2.25-2.25v-.75"/>
        </svg>
    )
}

