import fs from 'fs';
import path from 'path';

const projectJson = 'sfdx-project.json';
const projectJsonBak = 'sfdx-project.json.bak';
const projectJsonPackaging = 'sfdx-project_packaging.json';

const projectJsonPath = path.resolve(projectJson);
const projectJsonBakPath = path.resolve(projectJsonBak);

if (fs.existsSync(projectJsonPath)) {
  fs.renameSync(projectJsonPath, projectJsonPackaging);
  console.log(`Renamed ${projectJson} to ${projectJsonPackaging}`);
}

if (fs.existsSync(projectJsonBakPath)) {
  fs.renameSync(projectJsonBakPath, projectJsonPath);
  console.log(`Renamed ${projectJsonBak} to ${projectJson}`);
}
