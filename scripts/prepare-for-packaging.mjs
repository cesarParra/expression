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

  // Save the updated file
  fs.writeFileSync(projectJsonPackagingPath, JSON.stringify(json, null, 2), 'utf8');
  console.log(`Updated ${projectJsonPackaging}`);

  fs.renameSync(projectJsonPackagingPath, projectJsonPath);
  console.log(`Renamed ${projectJsonPackaging} to ${projectJson}`);
}
