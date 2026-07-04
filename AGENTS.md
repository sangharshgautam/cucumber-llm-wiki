# LLM Wiki Schema

This project implements Karpathy's LLM Wiki pattern — an LLM-maintained knowledge base of interlinked markdown files.

## Three layers

- **`raw/`** — immutable source documents (articles, papers, notes). LLM reads but never modifies.
- **`wiki/`** — LLM-generated markdown files. The LLM owns this layer entirely.
- **`AGENTS.md`** (this file) — the schema defining conventions and workflows.

## Directory structure

```
raw/
  article-title.md        # source documents, never modified
  another-source.pdf
wiki/
  index.md                # catalog of all pages with summaries
  log.md                  # chronological record of operations
  overview.md             # high-level synthesis of the domain
  entities/               # pages for people, organizations, tools
    person-name.md
  concepts/               # abstract concept pages
    concept-name.md
  sources/                # summary pages per source document
    source-title.md
  queries/                # notable Q&A results filed back into wiki
```

## Page conventions

Every wiki page has YAML frontmatter:

```yaml
---
type: entity | concept | source | query | overview
title: Page Title
description: One-line summary
tags: [tag1, tag2]
timestamp: 2026-04-02
sources: [source-file.md]   # which raw sources informed this page
status: active | needs-review | stale
---
```

Use `[[wikilinks]]` for cross-references between pages. Use `[citations](source-file.md)` to cite raw sources.

## Operations

### Ingest
1. User places source in `raw/`
2. Read the source, discuss key takeaways with the user
3. Write a source summary page in `wiki/sources/`
4. Update or create relevant entity and concept pages
5. Update `wiki/index.md` (add new pages, update summaries)
6. Append entry to `wiki/log.md`
7. Update `wiki/overview.md` if the new source changes the big picture

### Query
1. Read `wiki/index.md` to find relevant pages
2. Read those pages and synthesize an answer
3. If the answer has lasting value, file it as a new page in `wiki/queries/`

### Ingest Step Library
1. Read `step_library` path from `opencode.json`
2. Scan the Maven project for Java step definition classes
3. For each class, extract `@Given`/`@When`/`@Then` annotated methods (regex pattern, parameters, javadoc)
4. Create an entity page per class in `wiki/entities/{ClassName}.md` listing its steps
5. Update `wiki/index.md` under `## Entities`
6. Append to `wiki/log.md`

### Ingest Feature Projects
1. Read `feature_projects` list from `opencode.json`
2. For each project:
   a. Read `public/openapi.yaml` — document the spec
   b. Scan `.feature` files — parse scenarios, tags, steps
   c. Scan for payload directories at any depth — document location, naming, reference patterns
   d. Scan for mock/stub configurations — document framework, directory, activation method
   e. Document conventions (tag hierarchy, background patterns, scenario structure)
3. Create or update `wiki/sources/{project-name}.md` with all findings
4. Update `wiki/index.md` under `## Sources`
5. Append to `wiki/log.md`

### Lint
Periodically health-check the wiki:
- Contradictions between pages
- Stale claims superseded by newer sources
- Orphan pages with no inbound links
- Missing pages for mentioned concepts
- Overview drift (overview.md lagging behind)
- Update `wiki/log.md` with lint results

## Log format

```
## [2026-04-02] ingest | Source Title
- Created wiki/sources/source-title.md
- Updated wiki/entities/person-name.md
- Updated wiki/index.md
```
