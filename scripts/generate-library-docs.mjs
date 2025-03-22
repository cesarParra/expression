import {reflect} from '@cparra/apex-reflection';
import * as fs from 'fs';
import * as path from 'path';
import MarkdownBuilder from "./markdown-builder.mjs";

const rootDirectory = 'expression-src';

// Loop through all .cls files in the expression-src directory
const dirPath = path.join(process.cwd(), rootDirectory);

function processFiles(rootDirectory) {
  let allCategories = [];
  const directories = fs.readdirSync(rootDirectory, {withFileTypes: true});
  directories.forEach((directory) => {
    if (directory.isDirectory()) {
      allCategories = allCategories.concat(processFiles(path.join(rootDirectory, directory.name)));
    } else if (directory.isFile() && directory.name.endsWith('.cls')) {
      const filePath = path.join(rootDirectory, directory.name);
      const fileContents = fs.readFileSync(filePath, 'utf8');
      const reflectedClass = getClass(fileContents);
      if (!isFunctionRepository(reflectedClass)) {
        return;
      }
      const category = getCategory(reflectedClass);
      allCategories.push(category);
    }
  });

  return allCategories;
}

function getClass(fileContents) {
  const result = reflect(fileContents);
  return result.typeMirror;
}

function isFunctionRepository(reflectedClass) {
  return reflectedClass?.docComment?.annotations.find((annotation) => annotation.name === 'function-repository');
}

function getCategory(functionRepo) {
  const functions = functionRepo.classes.map((currentClass) => {
    const fnName = currentClass.docComment?.annotations.find((annotation) => annotation.name === 'function')?.body;
    return {
      name: fnName,
      autoCompleteValue: `${fnName}(`,
      description: currentClass.docComment?.descriptionLines.join('<br/>'),
      examples: [currentClass.docComment?.exampleAnnotation.bodyLines.join('\n')],
      icon: functionRepo.docComment?.annotations.find((annotation) => annotation.name === 'display-icon')?.body
    };
  })
    .filter((fn) => fn.name)
    .sort((a, b) => a.name.localeCompare(b.name));

  return {
    category: functionRepo.docComment?.annotations.find((annotation) => annotation.name === 'group')?.body,
    values: functions
  };
}

const categories = processFiles(dirPath);

const outputFileName = path.join(process.cwd(), 'expression-src/main/editor/lwc/functionLibrary/functions.js');
// Write the output to a file
fs.writeFileSync(outputFileName, `export const data = ${JSON.stringify(categories, null, 2)};`);

// Update the Functions page

const frontMatter = {
  title: 'Functions',
  nextjs: {
    metadata: {
      title: 'Functions',
      description: 'Functions overview.'
    }
  }
};

const markdownBuilder = new MarkdownBuilder();
markdownBuilder.frontMatter(frontMatter);
for (const category of categories) {
  markdownBuilder.h2(category.category);
  for (const fn of category.values) {
    markdownBuilder.h3(fn.name);
    markdownBuilder.text(fn.description);
    fn.examples.forEach((example) => {
      markdownBuilder.code(example);
    });
  }
}

const outputMarkdown = path.join(process.cwd(), 'docs/src/app/docs/functions/page.md');
fs.writeFileSync(outputMarkdown, markdownBuilder.markdown);
