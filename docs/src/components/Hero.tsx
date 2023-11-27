import { Button } from '@/components/Button'

export function Hero() {
  return (
    <div className="overflow-hidden dark:-mb-32 dark:mt-[-4.75rem] dark:pb-32 dark:pt-[4.75rem]">
      <div className="py-16 sm:px-2 lg:relative lg:px-0 lg:py-20">
        <div className="mx-auto grid grid-cols-1 items-center gap-x-8 gap-y-16 px-4 lg:max-w-8xl lg:px-8 xl:gap-x-16 xl:px-12">
          <div className="relative z-10 text-center">
            <div className="relative">
              <p className="inline bg-orange-400 bg-clip-text font-display text-5xl tracking-tight text-transparent">
                Expression
              </p>
              <p className="mt-3 text-2xl tracking-tight text-orange-100">
                Powerful formula-syntax evaluator for Apex and LWC.
              </p>
              <div className="mt-8 flex gap-4 justify-center">
                <Button href="https://github.com/cesarParra/expression">
                  View on GitHub
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
