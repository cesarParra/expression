import {type Metadata} from 'next'
import {Poppins} from 'next/font/google'
import clsx from 'clsx'

import {Providers} from '@/app/providers'
import {Layout} from '@/components/Layout'

import '@/styles/tailwind.css'
import React from "react";

const poppins = Poppins({weight: ["400"], subsets: ['latin'], variable: '--font-poppins'});

export const metadata: Metadata = {
    title: {
        template: '%s - Docs',
        default: 'Expression Language',
    },
    description:
        'Expression - Powerful formula-syntax evaluator for Apex and LWC.',
}

export default function RootLayout({
                                       children,
                                   }: {
    children: React.ReactNode
}) {
    return (
        <html
            lang="en"
            className={clsx('h-full antialiased', poppins.variable)}
            suppressHydrationWarning
        >
        <body className="flex min-h-full bg-white dark:bg-stone-900">
        <Providers>
            <Layout>{children}</Layout>
        </Providers>
        </body>
        </html>
    )
}
