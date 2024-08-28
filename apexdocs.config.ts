import {readFileSync, writeFileSync} from "fs";
import {defineMarkdownConfig, skip} from "@cparra/apexdocs";

export default defineMarkdownConfig({
    sourceDir: 'expression-src',
    targetDir: 'docs/src/app/docs/api',
    scope: ['global'],
    namespace: 'expression',
    transformReference: (reference) => {
        return {
            outputDocPath: reference.outputDocPath.replace('.md', '/page.md'),
            referencePath: reference.referencePath.replace('.md', ''),
        };
    },
    transformReferenceGuide: () => {
        return skip();
    },
    transformDocPage: (docPage) => {
        return {
            frontmatter: {
                nextjs: {
                    metadata: {
                        title: docPage.source.name,
                        description: `Api documentation for the ${docPage.source.name} ${docPage.source.type}}`,
                    }
                }
            },
        };
    },
    transformDocs: (docs) => {
        const navFileContents = readFileSync("docs/src/lib/navigation.json", "utf8");
        const navItems = JSON.parse(navFileContents);
        // Find an object whose title is "Api"
        let apiNavObject = navItems.find((navObject: any) => navObject.title === "Api");
        apiNavObject = apiNavObject ?? {title: "Api", links: []};

        apiNavObject.links = docs.map((doc) => {
            return {
                title: doc.source.name, href: `/docs/api/${doc.outputDocPath.replace('page.md', '').replace(/\/$/, '')}`
            };
        });

        // replace the Api object with the new one (or add it if it didn't exist)
        const newNavItems = navItems.filter((navObject: any) => navObject.title !== "Api");
        newNavItems.push(apiNavObject);

        // Write the new navigation.json file
        const newNavFileContents = JSON.stringify(newNavItems, null, 2);
        writeFileSync("docs/src/lib/navigation.json", newNavFileContents);

        return docs;
    },
});
