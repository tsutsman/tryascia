import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const workflowDir = path.join(root, '.github', 'workflows');
const releasePath = path.join(workflowDir, 'release.yml');

function fail(message) {
  console.error(`ERROR: ${message}`);
  process.exitCode = 1;
}

if (!fs.existsSync(releasePath)) {
  fail('відсутній постійний .github/workflows/release.yml');
}

const workflowFiles = fs.existsSync(workflowDir)
  ? fs.readdirSync(workflowDir).filter((name) => /\.ya?ml$/.test(name))
  : [];

for (const name of workflowFiles) {
  const text = fs.readFileSync(path.join(workflowDir, name), 'utf8');
  for (const match of text.matchAll(/^\s*uses:\s*([^\s#]+)(?:\s+#.*)?\s*$/gm)) {
    const spec = match[1];
    if (spec.startsWith('./')) continue;
    const at = spec.lastIndexOf('@');
    if (at < 0 || !/^[0-9a-f]{40}$/.test(spec.slice(at + 1))) {
      fail(`${name}: action dependency must be pinned to a 40-char commit SHA: ${spec}`);
    }
  }
}

if (fs.existsSync(releasePath)) {
  const release = fs.readFileSync(releasePath, 'utf8');
  const required = [
    ['tag push trigger', /tags:\s*\n(?:\s*-\s*['"]?v\*\.\*\.\*['"]?\s*\n?)/],
    ['manual rerun trigger', /workflow_dispatch:/],
    ['contents write permission', /permissions:\s*\n\s*contents:\s*write/],
    ['checkout without persisted credentials', /persist-credentials:\s*false/],
    ['stable semver guard', /\^v\[0-9\]\+\\\.\[0-9\]\+\\\.\[0-9\]\+\$/],
    ['main ancestry guard', /git merge-base --is-ancestor/],
    ['package version check', /package\.json/],
    ['eval version check', /evals\/evals\.json/],
    ['full validation', /npm test/],
    ['clean-tree check', /git diff --exit-code/],
    ['tag-ref installer smoke', /tests\/release-ref-smoke\.sh/],
    ['deterministic archive', /git archive/],
    ['deterministic gzip', /gzip -n/],
    ['release checksum manifest', /SHA256SUMS/],
    ['existing-tag release creation', /gh release create/],
    ['verify-tag guard', /--verify-tag/],
  ];

  for (const [label, pattern] of required) {
    if (!pattern.test(release)) fail(`release.yml: missing ${label}`);
  }

  const forbidden = [
    ['git push', /\bgit\s+push\b/],
    ['git commit', /\bgit\s+commit\b/],
    ['tag mutation', /\bgit\s+tag\b/],
    ['ref mutation', /\bgit\s+update-ref\b/],
  ];
  for (const [label, pattern] of forbidden) {
    if (pattern.test(release)) fail(`release.yml must not perform ${label}`);
  }
}

if (!process.exitCode) {
  console.log(`OK: release pipeline contract valid; ${workflowFiles.length} workflow file(s) use SHA-pinned actions.`);
}
