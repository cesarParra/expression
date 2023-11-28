import tags from "./tags";
import nodes from "./nodes";

const IS_PROD = process.env.NODE_ENV === 'production'

export default {
  tags,
  nodes,
  variables: {
    packageId: "04t",
    urlPrefix: IS_PROD ? "/expression" : "",
  }
}
