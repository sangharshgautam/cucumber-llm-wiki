# Changelog

## [2026-07-03] init | Project scaffold
- Created project structure (raw/, wiki/)
- Created AGENTS.md schema
- Created wiki/index.md and wiki/log.md

## [2026-07-03] agent | feature-writer
- Created opencode.json with cucumber-llm-wiki.frontend_spec config key
- Created .opencode/agents/feature-writer.md agent
- Created sample frontend/openapi.yaml (Pet Store API spec)

## [2026-07-03] agent | wiki-ingestor
- Added step_library and feature_projects config keys to opencode.json
- Created .opencode/agents/wiki-ingestor.md agent
- Added Ingest Step Library and Ingest Feature Projects operations to AGENTS.md
- Updated feature-writer agent to discover step defs, payload, and mock conventions from wiki before generation

## [2026-07-03] agent | ingestion reports
- Added report generation to ingest step-library (wiki/queries/step-library-report.md)
- Added report generation to ingest feature-projects (wiki/queries/{project-name}-report.md)
- Both reports produce structured tables with counts and conventions

## [2026-07-03] docs | README
- Created README.md with setup instructions and agent usage guide

## [2026-07-03] agent | pipeline
- Created .opencode/agents/pipeline.md — orchestrates full workflow end-to-end
- Reads other agent files dynamically and executes their instructions in sequence
