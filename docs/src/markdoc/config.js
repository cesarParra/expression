import tags from "./tags";
import nodes from "./nodes";

const IS_PROD = process.env.NODE_ENV === 'production'

const variables = {
    tags,
    nodes,
    variables: {
        packageId: "04tRb000000uSuTIAU",
        componentPackageId: "04tRb000000sGz3IAE",
        urlPrefix: IS_PROD ? "/expression" : "",
    }
}

export default variables;
