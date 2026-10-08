import fs from 'node:fs';

const requiredFiles = [
  'SECURITY.md',
  'tests/release-tag-smoke.sh',
  'tests/upgrade-smoke.sh',
  'tests/release-assets-smoke.sh',
];

let failed = false;
for (const file of requiredFiles) {
  if (!fs.existsSync(file)) {
    console.error(`ERROR: missing stable-hardening contract file: ${file}`);
    failed = true;
  }
}

const workflowPath = '.github/workflows/validate.yml';
if (fs.existsSync(workflowPath)) {
  const workflow = fs.readFileSync(workflowPath, 'utf8');
  for (const test of ['tests/release-tag-smoke.sh', 'tests/upgrade-smoke.sh', 'tests/release-assets-smoke.sh']) {
    if (!workflow.includes(test)) {
      console.error(`ERROR: validate.yml does not run ${test}`);
      failed = true;
    }
  }
}

if (failed) process.exit(1);
console.log('OK: stable post-release hardening contract is wired into CI.');
