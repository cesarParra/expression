import tags from "./tags";
import nodes from "./nodes";

const IS_PROD = process.env.NODE_ENV === 'production'

const variables = {
  tags,
  nodes,
  variables: {
    packageId: "04tHu000003OVu3IAG",
    urlPrefix: IS_PROD ? "/expression" : "",
  }
}

export default variables;
