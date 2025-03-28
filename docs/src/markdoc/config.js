import tags from './tags'
import nodes from './nodes'

const IS_PROD = process.env.NODE_ENV === 'production'

const variables = {
  tags,
  nodes,
  variables: {
    packageId: '04tRb000002mNZ3IAM',
    componentPackageId: '04tRb0000012Mv8IAE',
    urlPrefix: IS_PROD ? '/expression' : '',
  },
}

export default variables
