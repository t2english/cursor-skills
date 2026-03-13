# Changelog

## [2.2.0] - 2026-03-13

### Added
- **ghcr-portainer-deploy** v1.0.0 (operations): pipeline Docker completo via GitHub Actions, push GHCR, deploy Portainer via API
  - Workflow GitHub Actions com build, tag, push para GHCR
  - Registro de GHCR no Portainer, criacao/update de stacks
  - Verificacao pos-deploy, rollback, integracao com production-intelligence
  - Configuravel via `.cursor/deploy.json`
- **production-intelligence** v1.0.0 (operations): feedback loop producao-dev
  - Coleta dados de Sentry, Portainer logs, health endpoints
  - Analise de padroes de erro e correlacao com deploys
  - Persistencia em `.notebook/production/` e audit trail em `.deploys/log.md`
  - Cria issues no Linear para problemas recorrentes
- 5 templates de referencia para **docs-writer**: api-docs, adr-template, changelog-format, runbook-template, readme-template

### Enhanced
- **feature-lifecycle** v1.1.0: integracoes com ghcr-portainer-deploy (DEPLOY container), production-intelligence (MONITOR feedback), workspace-hygiene (CLEANUP)
- **observability-setup** v1.1.0: step 7 Post-Deploy Performance Watch com deteccao de degradacao e sugestao de performance-audit/incident-response
- **deploy-release** v1.0.0: estrategia GHCR + Portainer com referencia a ghcr-portainer-deploy
- **incident-response** v1.0.0: secao "Record in Production Intelligence" para persistir aprendizados pos-postmortem

### Fixed
- Versoes no frontmatter SKILL.md sincronizadas com `.skill-meta.json` (6 skills corrigidas)
- README atualizado de 19 para 21 skills, versoes corrigidas
- `install.sh` agora instala `_shared/references/` automaticamente
- `install.sh --init-linear` agora pergunta nome do time (antes hardcoded "OK IA")
- Tabela de dependencias no README completada com todas as relacoes documentadas

## [2.1.0] - 2026-03-13

### Added
- **workspace-hygiene** v1.0.0 (quality): limpeza e arquivamento de artefatos de desenvolvimento
  - Quick Sweep: limpeza leve pos-merge (archive specs, clean plans, remove handoff)
  - Deep Clean: limpeza profunda por sprint (prune archives >90 dias, orphan files, stale branches)
  - Configuravel via `.cursor/hygiene.json`

### Enhanced
- **finalize-branch** v1.1.0: step 6.5 sugere Quick Sweep apos merge
- **feature-lifecycle** v1.1.0: passo pos-MONITOR invoca workspace-hygiene para cleanup
- **linear-project-management** v1.1.0: workflow de retro sugere Deep Clean (passo 8)

## [2.0.0] - 2026-03-13

### Breaking Changes
- **Removed**: `add-api-endpoint` e `add-database-model` — skills projeto-especificas nao pertencem ao framework agnostico. Mover para o repositorio do projeto que as usa.
- **Renamed**: nomes canonicos atualizados (`codenavi` → `code-navi`, `tlc-spec-driven` → `spec-driven`)

### Added — 8 novas skills
- **testing-strategy** v1.0.0 (quality): workflow dedicado para unit/integration/e2e, deteccao de framework, coverage analysis
- **code-review** v1.0.0 (quality): review proativo pre-PR, checklist configuravel, deteccao de code smells
- **deploy-release** v1.0.0 (operations): pre-deploy checklist, release notes, rollback, versioning, integracao Linear
- **observability-setup** v1.0.0 (operations): logging estruturado, metricas, tracing, Sentry MCP, health checks
- **dependency-guardian** v1.0.0 (quality): audit de dependencias, licencas, supply chain, Renovate/Dependabot
- **performance-audit** v1.0.0 (quality): profiling, query analysis, bundle size, load testing, quick wins
- **incident-response** v1.0.0 (operations): triage P1-P4, troubleshooting guiado, postmortem template, Linear follow-up
- **feature-lifecycle** v1.0.0 (orchestration): meta-skill que orquestra ciclo completo da feature

### Added — infraestrutura
- 3 novas categorias: `operations`, `orchestration`, `quality`
- `skills/_shared/references/linear-helpers.md`: logica Linear compartilhada (detectar issue, atualizar status)
- install.sh v2.0: suporta todas as 9 categorias

### Enhanced — 10 skills existentes
- **code-navi** v1.2.0: bootstrap automatico do .notebook/, integracao com testing-strategy no VERIFY, referencia a linear-helpers.md, nivel Discovery Sprint
- **spec-driven** v1.1.0: formato User Story, acceptance criteria Given/When/Then, Definition of Ready checklist
- **coding-guidelines** v1.1.0: error handling strategy, a11y/i18n guidelines, secao "When to break the rules"
- **docs-writer** v2.0.0: reescrita completa com 5 workflows (API docs, ADRs, Changelogs, Runbooks, READMEs)
- **finalize-branch** v1.1.0: auto-detect package manager, checks configuraveis via .cursor/finalize.json, pre-flight code-review, referencia linear-helpers
- **security-best-practices** v1.1.0: modo proativo, OWASP Top 10 checklist, secrets detection, integracao Sentry MCP
- **linear-project-management** v1.1.0: sprint retrospective, velocity tracking, WIP limits, referencia linear-helpers
- **gh-fix-ci** v1.1.0: common fix patterns reference, categorias de falha, rerun strategy, flaky detection
- **gh-address-comments** v1.1.0: categorizacao (blocking/suggestion/nit), batch fixes, auto-resolve threads
- **learning-opportunities** v1.2.0: exercicios para novos dominios (testing, deploy, security), Code Archaeology, progress awareness

## [1.3.0] - 2026-03-12

### Enhanced
- **Todas as 10 skills**: descriptions reescritas com abordagem "pushy" para combater under-triggering
  - Cenarios de trigger mais explicitos e agressivos
  - Frases "Make sure to use this skill whenever..." para expandir alem dos casos obvios
  - Mais trigger phrases em linguagem natural e variada
- **create-skill** (Cursor built-in): integrado principios da [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) da Anthropic
  - Novo principio "Explain the Why" — instrucoes devem explicar raciocinio, nao empilhar MUSTs
  - Guia de "pushy descriptions" com exemplos concretos
  - Phase 5: Validation with Test Prompts (test prompts + should/should-not trigger queries)
  - Checklist atualizado com novos criterios de qualidade e validacao

### Added
- `templates/skill-eval-template.md`: template para avaliar skills com test prompts, trigger accuracy, review qualitativo e notas de iteracao

## [1.2.0] - 2026-03-12

### Enhanced
- **codenavi** v1.1.0: integrado conceitos do [napkin](https://github.com/blader/napkin) skill
  - Nova categoria `corrections/` no `.notebook/` para rastrear erros do agente com padrao "Do instead"
  - Regras de curacao: re-priorizar, mesclar duplicatas, remover obsoletos, cap de ~15 corrections
  - Graduacao de corrections para `patterns/` ou `gotchas/` quando aplicam de forma ampla
  - Padrao "Do instead" obrigatorio em gotchas e corrections (acao concreta, nao principio vago)
  - Consistency Contract atualizado (11 itens, inclui auto-registro de erros)

## [1.1.0] - 2026-02-28

### Added
- **finalize-branch** v1.0.0 (custom T2E): workflow completo para fechar branch com lint, knip, build, test, push, PR, CI, merge
- Knip dead code check integrado ao pipeline de finalizacao

## [1.0.0] - 2026-02-28

### Added
- Initial release with 9 skills em 6 categorias
- `install.sh` com --all, --skills, --category, --update, --remove, --list, --dry-run, --force, --init-linear
- Sistema de backup automatico antes de sobrescrever skills existentes
- Template `.cursor/linear.json.example` para integracao Linear

### Skills incluidas
- **linear-project-management** v1.1.0 (custom T2E): workflow plan→issues, templates, metodologia de sprints
- **coding-guidelines** v1.0.0 (tech-leads-club): diretrizes anti-overengineering baseadas em Karpathy Guidelines
- **tlc-spec-driven** v1.0.0 (tech-leads-club/felipfr): planejamento de features em 4 fases (Specify, Design, Tasks, Implement+Validate)
- **codenavi** v1.0.0 (tech-leads-club/felipfr): exploracao metodica de codebase com .notebook/ persistente
- **docs-writer** v1.0.0 (tech-leads-club): escrita e revisao de documentacao
- **gh-fix-ci** v1.0.0 (openai/skills): diagnostico de CI no GitHub Actions
- **gh-address-comments** v1.0.0 (openai/skills): resolver comentarios de PR
- **security-best-practices** v1.0.0 (openai/skills): revisao de seguranca para Python, JS/TS, Go
- **learning-opportunities** v1.1.0 (Chris Hicks/felipfr): exercicios de aprendizado durante coding
