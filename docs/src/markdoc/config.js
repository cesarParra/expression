import tags from "./tags";
import nodes from "./nodes";

const IS_PROD = process.env.NODE_ENV === 'production'

const variables = {
  tags,
  nodes,
  variables: {
    packageId: "04tRb000000zZVVIA2",
    componentPackageId: "04tRb0000011OhFIAU",
    urlPrefix: IS_PROD ? "/expression" : "",
  }
}

export default variables;
