# External Skill Catalog

This file contains references to Skills hosted in other public GitHub repositories.
Local Skills are discovered automatically from `skills/{personal,community,shared}`.

Each external entry has this shape:

```json
{
  "id": "community-example-skill",
  "name": "Example Skill",
  "category": "community",
  "tags": ["development"],
  "source": {
    "type": "external",
    "repository": "owner/repository",
    "ref": "main",
    "path": "path/to/skill"
  }
}
```

Submit an **Add external Skill** issue to have a pull request generated automatically.
The build reads the source repository at the selected ref, renders its README/SKILL.md,
and packages only the selected directory into a ZIP download.
