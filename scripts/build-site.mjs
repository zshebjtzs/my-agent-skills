import { execFileSync } from 'node:child_process';
import { readdir, readFile, rm, mkdir, writeFile, stat } from 'node:fs/promises';
import { dirname, join, relative, resolve, sep, posix } from 'node:path';
import matter from 'gray-matter';
import { strToU8, zipSync } from 'fflate';

const ROOT = resolve(dirname(new URL(import.meta.url).pathname), '..');
const SITE = join(ROOT, 'site');
const DOWNLOADS = join(SITE, 'public', 'downloads');
const CATEGORIES = ['personal', 'community', 'shared'];
const EXTERNAL_MANIFEST = join(ROOT, 'catalog', 'external-skills.json');
const repoName = 'zshebjtzs/my-agent-skills';
const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN || '';
const apiHeaders = {
  Accept: 'application/vnd.github+json',
  'X-GitHub-Api-Version': '2022-11-28',
  ...(token ? { Authorization: `Bearer ${token}` } : {})
};

function safeSegment(value) {
  return String(value).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'skill';
}

async function walk(directory) {
  const output = [];
  let entries;
  try { entries = await readdir(directory, { withFileTypes: true }); }
  catch { return output; }
  entries.sort((a, b) => a.name.localeCompare(b.name));
  for (const entry of entries) {
    if (entry.name === '.git' || entry.name === 'node_modules') continue;
    const fullPath = join(directory, entry.name);
    if (entry.isDirectory()) output.push(...await walk(fullPath));
    else if (entry.isFile()) output.push(fullPath);
  }
  return output;
}

async function findLocalSkills() {
  const found = [];
  for (const category of CATEGORIES) {
    const categoryRoot = join(ROOT, 'skills', category);
    for (const file of await walk(categoryRoot)) {
      if (file.split(sep).at(-1).toLowerCase() !== 'skill.md') continue;
      const skillRoot = dirname(file);
      const categoryRelative = relative(categoryRoot, skillRoot).split(sep).join('/');
      found.push({ category, skillRoot, skillFile: file, categoryRelative });
    }
  }
  return found;
}

async function readSkillDocument(skillRoot, skillFile) {
  const files = await readdir(skillRoot, { withFileTypes: true });
  const readme = files.find(item => item.isFile() && item.name.toLowerCase() === 'readme.md');
  const documentPath = readme ? join(skillRoot, readme.name) : skillFile;
  const raw = await readFile(documentPath, 'utf8');
  const parsed = matter(raw);
  const skillMeta = matter(await readFile(skillFile, 'utf8')).data;
  const metadata = { ...skillMeta, ...parsed.data };
  const folderName = skillRoot.split(sep).at(-1);
  const name = metadata.name || folderName;
  const description = metadata.description || parsed.content.split(/\n\s*\n/).find(line => line.trim() && !line.trim().startsWith('#'))?.replace(/[*_`]/g, '').trim().slice(0, 220) || 'No description provided.';
  return { name, description, markdown: parsed.content.trim(), documentPath };
}

async function addZipFromDirectory(skillRoot, id) {
  const files = await walk(skillRoot);
  const entries = {};
  const folderName = skillRoot.split(sep).at(-1);
  for (const file of files) {
    const relativePath = relative(skillRoot, file).split(sep).join('/');
    const bytes = await readFile(file);
    entries[`${folderName}/${relativePath}`] = new Uint8Array(bytes);
  }
  const zip = zipSync(entries, { level: 6 });
  await writeFile(join(DOWNLOADS, `${id}.zip`), zip);
}

function rewriteRelativeLinks(markdown, source) {
  const rawBase = `https://raw.githubusercontent.com/${source.repository}/${source.ref}/${source.path}/`;
  const blobBase = `https://github.com/${source.repository}/blob/${source.ref}/${source.path}/`;
  return markdown.replace(/(!?\[[^\]]*\]\()([^\s)]+)(\))/g, (match, prefix, target, suffix) => {
    if (/^(?:[a-z][a-z0-9+.-]*:|\/|#)/i.test(target)) return match;
    const [relativeFile, anchor] = target.split('#', 2);
    const normalized = posix.normalize(posix.join(posix.dirname(source.readmePath), relativeFile));
    if (normalized === '..' || normalized.startsWith('../')) return match;
    const encoded = normalized.split('/').map(encodeURIComponent).join('/');
    const url = (prefix.startsWith('!') ? rawBase : blobBase) + encoded + (anchor ? `#${anchor}` : '');
    return prefix + url + suffix;
  });
}

function detailPage(item) {
  const sourceLink = item.source.url;
  const markdown = rewriteRelativeLinks(item.markdown, item.source);
  return `---
title: ${JSON.stringify(item.name)}
description: ${JSON.stringify(item.description)}
aside: false
---

<div class="skill-toolbar">
  <a class="skill-download" href="../../downloads/${item.id}.zip" download>Download Skill (.zip)</a>
  <a class="skill-source" href="${sourceLink}" target="_blank" rel="noreferrer">View source repository ↗</a>
</div>

<div class="skill-meta"><span>${item.category}</span>${item.tags.length ? `<span>${item.tags.join(' · ')}</span>` : ''}</div>

${markdown || '_No README or SKILL.md content was found._'}
`;
}

async function fetchJson(url) {
  let lastError;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await fetch(url, { headers: apiHeaders });
      if (!response.ok) throw new Error(`GitHub API ${response.status}: ${await response.text()}`);
      return await response.json();
    } catch (error) {
      lastError = error;
      await new Promise(resolve => setTimeout(resolve, 400 * (attempt + 1)));
    }
  }
  throw lastError;
}

async function fetchBytes(url) {
  let lastError;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await fetch(url, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
      if (!response.ok) throw new Error(`Download ${response.status}: ${url}`);
      return new Uint8Array(await response.arrayBuffer());
    } catch (error) {
      lastError = error;
      await new Promise(resolve => setTimeout(resolve, 400 * (attempt + 1)));
    }
  }
  throw lastError;
}

async function buildExternalSkill(entry) {
  const { repository, path: skillPath } = entry.source;
  const repo = await fetchJson(`https://api.github.com/repos/${repository}`);
  const ref = entry.source.ref || repo.default_branch;
  const commit = await fetchJson(`https://api.github.com/repos/${repository}/commits/${encodeURIComponent(ref)}`);
  const commitSha = commit.sha;
  const tree = await fetchJson(`https://api.github.com/repos/${repository}/git/trees/${commitSha}?recursive=1`);
  if (tree.truncated) throw new Error(`External repository tree is truncated: ${repository}`);
  const prefix = skillPath.replace(/\/$/, '') + '/';
  const files = tree.tree.filter(item => item.type === 'blob' && item.path.startsWith(prefix) && !item.path.split('/').includes('.git'));
  if (!files.length) throw new Error(`No files found under ${repository}/${skillPath}`);
  if (files.length > 500) throw new Error(`Skill is too large to package safely (${files.length} files): ${entry.id}`);
  const readme = files.find(file => file.path.slice(prefix.length).toLowerCase() === 'readme.md')
    || files.find(file => file.path.slice(prefix.length).toLowerCase() === 'skill.md');
  if (!readme) throw new Error(`No README.md or SKILL.md found for ${entry.id}`);

  const entries = {};
  let totalBytes = 0;
  const contents = await Promise.all(files.map(async file => {
    const bytes = await fetchBytes(`https://raw.githubusercontent.com/${repository}/${commitSha}/${file.path.split('/').map(encodeURIComponent).join('/')}`);
    totalBytes += bytes.byteLength;
    if (totalBytes > 25 * 1024 * 1024) throw new Error(`Skill exceeds 25 MB: ${entry.id}`);
    return { file, bytes };
  }));
  for (const { file, bytes } of contents) {
    const innerPath = file.path.slice(prefix.length);
    entries[`${skillPath.split('/').at(-1)}/${innerPath}`] = bytes;
  }
  await writeFile(join(DOWNLOADS, `${entry.id}.zip`), zipSync(entries, { level: 6 }));

  const readmeBytes = contents.find(item => item.file.path === readme.path).bytes;
  const parsed = matter(new TextDecoder().decode(readmeBytes));
  const description = entry.description || parsed.data.description || 'External Skill from GitHub.';
  return {
    id: entry.id,
    name: entry.name || parsed.data.name || skillPath.split('/').at(-1),
    category: entry.category,
    tags: entry.tags || [],
    description,
    markdown: parsed.content.trim(),
    source: {
      repository,
      ref: commitSha,
      path: skillPath,
      readmePath: readme.path.slice(prefix.length),
      url: `https://github.com/${repository}/tree/${commitSha}/${skillPath}`
    }
  };
}

await rm(join(SITE, 'skills'), { recursive: true, force: true });
await rm(DOWNLOADS, { recursive: true, force: true });
await mkdir(DOWNLOADS, { recursive: true });

const items = [];
for (const local of await findLocalSkills()) {
  const id = `${local.category}-${local.categoryRelative.split('/').map(safeSegment).join('--')}`;
  const doc = await readSkillDocument(local.skillRoot, local.skillFile);
  const repoRelative = relative(ROOT, local.skillRoot).split(sep).join('/');
  let sourceRepository = repoName;
  let sourcePath = repoRelative;
  let sourceRef = process.env.GITHUB_SHA || 'main';
  const submoduleRoot = join(ROOT, 'skills', 'community', 'spec-kit');
  if (repoRelative.startsWith('skills/community/spec-kit/')) {
    sourceRepository = 'github/spec-kit';
    sourcePath = repoRelative.slice('skills/community/spec-kit/'.length);
    try { sourceRef = execFileSync('git', ['-C', submoduleRoot, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim(); }
    catch { sourceRef = 'main'; }
  }
  const source = {
    repository: sourceRepository,
    ref: sourceRef,
    path: sourcePath,
    readmePath: relative(local.skillRoot, doc.documentPath).split(sep).join('/'),
    url: `https://github.com/${sourceRepository}/tree/${sourceRef}/${sourcePath}`
  };
  await addZipFromDirectory(local.skillRoot, id);
  items.push({ id, name: doc.name, category: local.category, tags: [], description: doc.description, markdown: doc.markdown, source });
}

const externalEntries = JSON.parse(await readFile(EXTERNAL_MANIFEST, 'utf8'));
for (const entry of externalEntries) items.push(await buildExternalSkill(entry));

items.sort((a, b) => a.category.localeCompare(b.category) || a.name.localeCompare(b.name));
for (const category of CATEGORIES) {
  const categoryItems = items.filter(item => item.category === category);
  const categoryDir = join(SITE, 'skills', category);
  await mkdir(categoryDir, { recursive: true });
  const links = categoryItems.length
    ? categoryItems.map(item => `- [**${item.name}**](./${item.id}) — ${item.description.replace(/\s+/g, ' ').slice(0, 180)}`).join('\n')
    : '_No Skills in this category yet._';
  await writeFile(join(categoryDir, 'index.md'), `# ${category[0].toUpperCase() + category.slice(1)} Skills\n\n${links}\n`);
  for (const item of categoryItems) {
    await writeFile(join(categoryDir, `${item.id}.md`), detailPage(item));
  }
}

const categoryCards = CATEGORIES.map(category => {
  const count = items.filter(item => item.category === category).length;
  const label = category[0].toUpperCase() + category.slice(1);
  return `<a class="category-card" href="/my-agent-skills/skills/${category}/"><span class="category-count">${String(count).padStart(2, '0')} SKILLS</span><strong>${label}</strong><span>Browse the ${label.toLowerCase()} collection →</span></a>`;
}).join('\n');

const latest = items.slice(0, 8).map(item =>
  `- [**${item.name}**](/skills/${item.category}/${item.id}) <span class="inline-category">${item.category}</span> — ${item.description.replace(/\s+/g, ' ').slice(0, 150)}`
).join('\n') || '_No Skills discovered yet._';

const homepage = `---
title: My Agent Skills
---

<div class="portal-hero">
  <div class="portal-eyebrow">PERSONAL SKILL LIBRARY</div>
  <h1>My Agent Skills<span>.</span></h1>
  <p>A curated library of reusable agent skills — organized, searchable, readable, and downloadable.</p>
  <div class="portal-actions"><a href="/my-agent-skills/skills/personal/">Explore Skills</a><a class="secondary" href="https://github.com/zshebjtzs/my-agent-skills">View GitHub ↗</a></div>
  <div class="portal-total"><strong>${items.length}</strong><span>SKILLS IN CATALOG</span></div>
</div>

## Browse by category

<div class="category-grid">
${categoryCards}
</div>

## Skill catalog

${latest}

<div class="submission-note">
  <strong>Contribute a Skill</strong>
  <span>Have a useful external Skill? Submit it through GitHub Issues. A pull request will be generated for review.</span>
  <a href="https://github.com/zshebjtzs/my-agent-skills/issues/new?template=add-skill.yml">Submit a Skill ↗</a>
</div>
`;
await writeFile(join(SITE, 'index.md'), homepage);
console.log(`Generated the Skill portal with ${items.length} Skills.`);
