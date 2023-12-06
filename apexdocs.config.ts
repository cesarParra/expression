import {readFileSync, writeFileSync} from "fs";
import {OutputDir, TargetFile} from "@cparra/apexdocs/lib/settings";

function onBeforeFileWrite(file: TargetFile): TargetFile {
    const outputDir: OutputDir = {
        baseDir: file.dir.baseDir,
        fileDir: file.name
    };

    return {
        name: 'page',
        extension: '.md',
        dir: outputDir
    }
}

function onAfterProcess(files: TargetFile[]) {
    const navFileContents = readFileSync("docs/src/lib/navigation.json", "utf8");
    const navItems = JSON.parse(navFileContents);
    // Find an object whose title is "Api"
    let apiNavObject = navItems.find((navObject: any) => navObject.title === "Api");
    apiNavObject = apiNavObject ?? {title: "Api", links: []};

    apiNavObject.links = files.filter((file) => file.dir.fileDir !== 'index').map((file) => {
        return {title: file.dir.fileDir, href: `/docs/api/${file.dir.fileDir}`};
    });

    // replace the Api object with the new one (or add it if it didn't exist)
    const newNavItems = navItems.filter((navObject: any) => navObject.title !== "Api");
    newNavItems.push(apiNavObject);

    // Write the new navigation.json file
    const newNavFileContents = JSON.stringify(newNavItems, null, 2);
    console.log("Writing new navigation.json file");
    writeFileSync("docs/src/lib/navigation.json", newNavFileContents);
}

export default {
    onBeforeFileWrite,
    onAfterProcess
};
