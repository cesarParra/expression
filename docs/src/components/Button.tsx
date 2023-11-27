import Link from 'next/link'
import clsx from 'clsx'
import React from "react";

const variantStyles = {
  primary:
    'rounded-full bg-orange-300 py-2 px-4 text-sm font-semibold text-stone-900 hover:bg-orange-200 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-300/50 active:bg-orange-500',
  secondary:
    'rounded-full bg-stone-800 py-2 px-4 text-sm font-medium text-white hover:bg-stone-700 focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white/50 active:text-stone-400',
}

type ButtonProps = {
  variant?: keyof typeof variantStyles
} & (
  | React.ComponentPropsWithoutRef<typeof Link>
  | (React.ComponentPropsWithoutRef<'button'> & { href?: undefined })
)

export function Button({
  variant = 'primary',
  className,
  ...props
}: ButtonProps) {
  className = clsx(variantStyles[variant], className)

  return typeof props.href === 'undefined' ? (
    <button className={className} {...props} />
  ) : (
    <Link className={className} {...props} />
  )
}
