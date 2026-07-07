# Integration Test Plan

This document describes how to manually test each agent end-to-end using the sample projects already configured in `opencode.json`.

## Prerequisites

- Projects exist at the paths configured in `opencode.json`:
  - `C:/Users/sangh/IdeaProjects/sangharshgautam/openapi-bdd`
  - `C:/Users/sangh/IdeaProjects/sangharshgautam/coffee-ordering-api`
- OpenCode is running in this project directory

## Test 1: Ingest Step Library

**Command:** `@wiki-ingestor ingest step-library`

**Expected results:**

| Artifact | Expected | Verified |
|----------|----------|----------|
| `wiki/entities/api-step-definitions.md` | Created with 32 steps | ✅ |
| `wiki/queries/step-library-report.md` | Created with step counts | ✅ |
| `wiki/index.md` | Updated under `## Entities` | ✅ |
| `wiki/log.md` | Entry added | ✅ |

**Pass if:** All artifacts created, step counts match (1 Given, 5 When, 2 Then, 24 And).

---

## Test 2: Ingest Feature Projects

**Command:** `@wiki-ingestor ingest feature-projects`

**Expected results:**

| Artifact | Expected | Verified |
|----------|----------|----------|
| `wiki/sources/coffee-ordering-api.md` | Created with spec + 11 scenarios + payloads + conventions | ✅ |
| `wiki/queries/coffee-ordering-api-report.md` | Created with summary tables | ✅ |
| `wiki/index.md` | Updated under `## Sources` and `## Queries` | ✅ |
| `wiki/log.md` | Entry added | ✅ |

**Pass if:** Source page documents all 11 scenarios, payload naming pattern is descriptive, mock section says "none".

---

## Test 3: Generate Feature Files

**Command:** `@feature-writer`

**Expected results:**

| Artifact | Expected | Verified |
|----------|----------|----------|
| `journey-pet-store-api-service-test/pom.xml` | Created with openapi-bdd dependency | |
| `journey-pet-store-api-service-test/src/test/java/runners/CucumberRunner.java` | Created | |
| `journey-pet-store-api-service-test/src/test/java/steps/PetSteps.java` | Created | |
| `journey-pet-store-api-service-test/src/test/resources/features/pets.feature` | 11 scenarios | |
| `journey-pet-store-api-service-test/src/test/resources/requestPayload/` | 3 JSON files | |
| `journey-pet-store-api-service-test/src/test/resources/responsePayload/` | 1 JSON file | |
| `journey-pet-store-api-service-test/src/test/resources/junit-platform.properties` | Created | |

**Pass if:** All files created, feature file uses `sg:` step patterns, payloads use descriptive names.

---

## Test 4: Validate Generated Project

**Command:** `@validator validate journey-pet-store-api-service-test`

**Expected results:**

| Check | Expected | Verified |
|-------|----------|----------|
| Step def matching | All steps match known patterns | |
| Payload schema | Valid against OpenAPI spec | |
| Convention compliance | Matches coffee-ordering-api patterns | |
| Gherkin syntax | Valid | |
| Maven project | Layout, POM, packages OK | |
| `wiki/queries/journey-pet-store-api-service-test-validation-report.md` | Created | |

**Pass if:** All checks pass or are acceptable.

---

## Test 5: Pipeline (full run)

**Command:** `@pipeline run`

**Expected results:** Same as Tests 1-4 but executed in sequence automatically.

**Pass if:** No errors, all artifacts from each step are created.

---

## Test 6: Wiki Linter

**Command:** `@wiki-linter`

**Expected results:**

| Check | Expected | Verified |
|-------|----------|----------|
| Schema integrity | No missing frontmatter | |
| Staleness | New pages should not be stale | |
| Orphans | All pages should have inbound links | |
| Coverage gaps | Report of missing pages | |

---

## Regression testing

After changes to any agent file, re-run the full pipeline and verify:
1. All artifacts are still created correctly
2. Validation report shows no new issues
3. `wiki/log.md` captures all operations
4. `wiki/index.md` links are all valid

## Cleanup between test runs

To reset the wiki to a clean state between runs:

```powershell
Remove-Item -Recurse -Force wiki/entities/*.md, wiki/sources/*.md, wiki/queries/*.md, journey-pet-store-api-service-test -ErrorAction SilentlyContinue
git checkout -- wiki/index.md wiki/log.md
```
