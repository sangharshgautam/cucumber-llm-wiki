# Cucumber LLM Wiki

An LLM-maintained knowledge base for Cucumber JVM testing ecosystems. This project implements Karpathy's [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the wiki is a persistent, compounding artifact that gets richer with every source you add and every question you ask.

## Architecture

```
opencode.json              # Config — paths to projects, specs
AGENTS.md                  # Schema — conventions and workflows
├── raw/                   # Immutable source documents (LLM reads only)
└── wiki/                  # LLM-generated knowledge base
    ├── index.md           # Page catalog with summaries
    ├── log.md             # Chronological record of operations
    ├── overview.md        # High-level synthesis
    ├── entities/          # Step definition classes, API resources
    ├── concepts/          # Abstract concept pages
    ├── sources/           # Feature project documentation
    └── queries/           # Reports and Q&A results
```

## Setup

1. Clone this repo.
2. Edit `opencode.json` with paths to your real projects:

```json
{
  "cucumber-llm-wiki": {
    "frontend_spec": "frontend/openapi.yaml",
    "step_library": "../my-step-def-library",
    "feature_projects": ["../project-payments", "../project-orders"]
  }
}
```

## Agents

Invoke agents in opencode using `@agent-name`.

### @pipeline

One-shot orchestrator that runs the entire workflow in sequence.

```
@pipeline run
```

Executes:
1. Ingest step library
2. Ingest feature projects
3. Generate feature files
4. Validate the generated project

Reads the latest instructions from each agent file so it always stays in sync.

### @wiki-ingestor

Scans external Maven projects and documents them in the wiki.

**Ingest step definitions:**

```
@wiki-ingestor ingest step-library
```

Scans the `step_library` project for Java classes with `@Given`/`@When`/`@Then` annotations. Creates:
- `wiki/entities/{ClassName}.md` — one page per class listing its step patterns
- `wiki/queries/step-library-report.md` — summary table with step counts

**Ingest feature projects:**

```
@wiki-ingestor ingest feature-projects
```

For each project in `feature_projects`, scans:
- `public/openapi.yaml` — API spec
- `*.feature` files — scenarios, tags, backgrounds
- `requestPayload/`, `responsePayload/` directories — payload naming and reference conventions
- `mocks/` directories — mock framework and activation patterns
- Creates `wiki/sources/{project}.md` and `wiki/queries/{project}-report.md`

### @feature-writer

Generates Cucumber feature files and payloads from an OpenAPI spec.

```
@feature-writer
```

Before generating, reads the wiki to discover:
- Available `@Given`/`@When`/`@Then` step definitions from ingested libraries
- Payload conventions (directory structure, naming, reference patterns)
- Mock conventions (framework, directory, activation)
- Tag hierarchy and background patterns from existing projects

Generates files under `{spec-title}_test/`:
```
{spec-title}_test/
└── src/test/
    ├── java/steps/           # Step definition classes
    ├── java/runners/         # CucumberRunner.java
    └── resources/
        ├── features/         # .feature files
        ├── requestPayload/   # Request body JSON files
        └── responsePayload/  # Expected response JSON files
```

### @validator

Validates a generated Maven project against step definitions, schemas, conventions, and Maven standards.

```
@validator validate pet-store-api_test
```

Checks performed:
1. **Step def matching** — every Gherkin step matches a known `sg:` pattern from `wiki/entities/`
2. **Payload schema** — request/response payloads conform to the OpenAPI spec
3. **Convention compliance** — matches patterns from ingested feature projects
4. **Gherkin syntax** — valid Feature/Scenario/Given-When-Then structure
5. **Maven project** — standard layout, well-formed POM, package/directory match, dependency resolution, compilation

Creates `wiki/queries/{target}-validation-report.md` with a detailed results table.

### @wiki-linter

Health-checks the wiki for contradictions, orphans, stale pages, and coverage gaps.

```
@wiki-linter
```

### @code-writer

General-purpose agent for writing and modifying code across the project.

## Testing

Run agent structure validation locally:

```powershell
./tests/agent-structure-test.ps1
```

Or via GitHub Actions on every push/PR (see `.github/workflows/test-agents.yml`).

### What the structure test checks

| Check | Description |
|-------|-------------|
| YAML frontmatter | Every agent file has valid `---` delimited frontmatter |
| Description | Every agent has a description field |
| Mode | Must be `subagent` |
| Temperature | Must be a numeric value |
| Permission block | Must declare `permission:` with tool keys |
| Permission consistency | Read-only agents (linter, validator) should not have `edit: allow` |
| Cross-references | Agents that reference other agents by name are documented |

### Manual integration testing

See `tests/integration-test-plan.md` for full end-to-end test procedures covering each agent.

## Workflow

### First time setup

1. Configure `opencode.json` with your project paths
2. `@wiki-ingestor ingest step-library` — document your step definitions
3. `@wiki-ingestor ingest feature-projects` — document your feature file projects

### Generating new tests

1. Place an OpenAPI spec at the `frontend_spec` path (default: `frontend/openapi.yaml`)
2. `@feature-writer` — generates feature files, payloads, and step definitions that follow your project's conventions
3. `@validator validate {spec-title}_test` — validate the generated output

### Maintenance

- `@wiki-linter` — periodically check wiki health
- Add new sources to `raw/` and use the standard ingest workflow
- Re-run `@wiki-ingestor` when step libraries or feature projects change

## Project structure

```
.
├── AGENTS.md                    # Wiki schema and operations
├── opencode.json                # Agent configuration
├── README.md
├── .opencode/agents/
│   ├── code-writer.md           # General code writing
│   ├── feature-writer.md        # Cucumber feature generation
│   ├── wiki-ingestor.md         # Project ingestion
│   ├── wiki-linter.md           # Wiki health checks
│   ├── validator.md             # Generated project validation
│   └── pipeline.md              # Full workflow orchestration
├── frontend/
│   └── openapi.yaml             # Sample Pet Store API spec
├── raw/                         # Immutable source documents
└── wiki/
    ├── index.md
    ├── log.md
    ├── overview.md
    ├── entities/
    ├── concepts/
    ├── sources/
    └── queries/
```
