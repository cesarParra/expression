import tags from './tags'
import nodes from './nodes'
import packages from '../../public/packages.json'

const IS_PROD = process.env.NODE_ENV === 'production'

const variables = {
  tags,
  nodes,
  variables: {
    ...packages,
    urlPrefix: IS_PROD ? '/expression' : '',
  },
}

export default variables
