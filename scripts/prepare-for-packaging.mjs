import fs from 'fs';
import path from 'path';

const projectJson = 'sfdx-project.json';
const projectJsonBak = 'sfdx-project.json.bak';
const projectJsonPackaging = 'sfdx-project_packaging.json';

const projectJsonPath = path.resolve(projectJson);
const projectJsonBakPath = path.resolve(projectJsonBak);

if (fs.existsSync(projectJsonPath)) {
  fs.renameSync(projectJsonPath, projectJsonBakPath);
  console.log(`Renamed ${projectJson} to ${projectJsonBak}`);
}

const projectJsonPackagingPath = path.resolve(projectJsonPackaging);
if (fs.existsSync(projectJsonPackagingPath)) {
  const data = fs.readFileSync(projectJsonPackagingPath, 'utf8');
  const json = JSON.parse(data);

  const corePackage = json.packageDirectories.find((pkg) => pkg.package === 'Expression');

  // Update versionName
  const versionNameParts = corePackage.versionName.split(' ');
  const versionNumber = parseFloat(versionNameParts[1]);
  corePackage.versionName = `${versionNameParts[0]} ${versionNumber + 0.01}`;

  // Update versionNumber
  const versionNumberParts = corePackage.versionNumber.split('.');
  const majorVersion = parseInt(versionNumberParts[0]);
  const minorVersion = parseInt(versionNumberParts[1]);
  corePackage.versionNumber = `${majorVersion}.${minorVersion + 1}.0.NEXT`;

  // Save the updated file
  fs.writeFileSync(projectJsonPackagingPath, JSON.stringify(json, null, 2), 'utf8');
  console.log(`Updated ${projectJsonPackaging}`);

  fs.renameSync(projectJsonPackagingPath, projectJsonPath);
  console.log(`Renamed ${projectJsonPackaging} to ${projectJson}`);
}
