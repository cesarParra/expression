/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./expression-components/**/*.{html,js}"],
  important: true,
  theme: {
    extend: {
      colors: {
        dxp: {
          bg: {
            root: "var(--dxp-g-root)",
            "root-1": "var(--dxp-g-root-1)",
            "root-2": "var(--dxp-g-root-2)",
            "root-3": "var(--dxp-g-root-3)",
          },
          text: {
            contrast: "var(--dxp-g-root-contrast)",
            "contrast-1": "var(--dxp-g-root-contrast-1)",
            "contrast-2": "var(--dxp-g-root-contrast-2)",
            "contrast-3": "var(--dxp-g-root-contrast-3)",
          },
          brand: {
            DEFAULT: "var(--dxp-g-brand)",
            "1": "var(--dxp-g-brand-1)",
            "2": "var(--dxp-g-brand-2)",
            "3": "var(--dxp-g-brand-3)",
          },
          "brand-foreground": {
            DEFAULT: "var(--dxp-g-brand-contrast)",
            "1": "var(--dxp-g-brand-contrast-1)",
            "2": "var(--dxp-g-brand-contrast-2)",
            "3": "var(--dxp-g-brand-contrast-3)",
          }
        }
      }
    },
  },
  plugins: [],
}

