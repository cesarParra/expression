// Copies the subscriber version id `sf package version create` just wrote into the packaging
// aliases over to the docs, so the install instructions point at the release that was made.
import fs from 'fs';

const project = JSON.parse(fs.readFileSync('sfdx-project_packaging.json', 'utf8'));
const { versionNumber } = project.packageDirectories.find((dir) => dir.package === 'Expression');
const prefix = `Expression@${versionNumber.replace(/\.NEXT$/, '')}-`;
// sf appends aliases in creation order, so the last one under this version is the newest build.
const packageId = Object.entries(project.packageAliases)
  .filter(([alias]) => alias.startsWith(prefix))
  .map(([, id]) => id)
  .at(-1);

if (!packageId) {
  throw new Error(`No alias starting with "${prefix}" in sfdx-project_packaging.json`);
}

const file = 'docs/public/packages.json';
const packages = JSON.parse(fs.readFileSync(file, 'utf8'));
fs.writeFileSync(file, JSON.stringify({ ...packages, packageId }, null, 2) + '\n');
console.log(`${file}: packageId -> ${packageId}`);
