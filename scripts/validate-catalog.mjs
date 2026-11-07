import { readFile } from 'node:fs/promises';

const categories = new Set(['personal', 'community', 'shared']);
const entries = JSON.parse(await readFile(new URL('../catalog/external-skills.json', import.meta.url), 'utf8'));
if (!Array.isArray(entries)) throw new Error('catalog/external-skills.json must contain an array.');

const ids = new Set();
for (const [index, entry] of entries.entries()) {
  const label = `external-skills[${index}]`;
  if (!entry || typeof entry !== 'object') throw new Error(`${label} must be an object.`);
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(entry.id ?? '')) throw new Error(`${label}.id must be a lowercase kebab-case identifier.`);
  if (ids.has(entry.id)) throw new Error(`Duplicate external Skill id: ${entry.id}`);
  ids.add(entry.id);
  if (!entry.name?.trim()) throw new Error(`${label}.name is required.`);
  if (!categories.has(entry.category)) throw new Error(`${label}.category must be personal, community, or shared.`);
  if (entry.source?.type !== 'external') throw new Error(`${label}.source.type must be external.`);
  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(entry.source.repository ?? '')) throw new Error(`${label}.source.repository must be owner/repository.`);
  if (!entry.source.path || entry.source.path.startsWith('/') || entry.source.path.split('/').some(part => part === '..' || part === '.')) {
    throw new Error(`${label}.source.path must be a safe repository-relative directory.`);
  }
}
console.log(`Catalog validation passed (${entries.length} external Skills).`);
