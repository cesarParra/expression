import withMarkdoc from '@markdoc/next.js'
import withSearch from './src/markdoc/search.mjs'

const isProd = process.env.NODE_ENV === 'production';

/** @type {import('next').NextConfig} */
const nextConfig = {
  basePath: isProd ? '/expression' : '',
  pageExtensions: ['js', 'jsx', 'md', 'ts', 'tsx'],
  output: "export",
}

export default withSearch(
  withMarkdoc({ schemaPath: './src/markdoc' })(nextConfig),
)
