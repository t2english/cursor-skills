# Cursor Skills

Repositorio centralizado de Cursor Agent Skills do time **Transition 2 English (T2E)**. Framework agnostico com 19 skills em 9 categorias, cobrindo o ciclo completo de desenvolvimento: da concepcao ao deploy em producao, incluindo monitoramento, resposta a incidentes e limpeza de artefatos.

## Quick Start

```bash
# Via SSH
git clone git@github.com:transition2english/cursor-skills.git /tmp/cursor-skills \
  && /tmp/cursor-skills/install.sh --all

# Via HTTPS
git clone https://github.com/transition2english/cursor-skills.git /tmp/cursor-skills \
  && /tmp/cursor-skills/install.sh --all
```

## Catalogo de Skills

### development (3)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **code-navi** | Exploracao metodica de codebase com .notebook/ persistente | 1.2.0 |
| **coding-guidelines** | Diretrizes anti-overengineering, error handling, a11y | 1.1.0 |
| **spec-driven** | Planejamento em 4 fases: Specify, Design, Tasks, Implement+Validate | 1.1.0 |

### documentation (1)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **docs-writer** | 5 workflows: API docs, ADRs, Changelogs, Runbooks, READMEs | 2.0.0 |

### github (3)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **finalize-branch** | Lint, build, test, review, push, PR, CI, merge (auto-detect pkg manager) | 1.1.0 |
| **gh-fix-ci** | Diagnostico de CI no GitHub Actions com fix patterns e flaky detection | 1.1.0 |
| **gh-address-comments** | Resolver comentarios de PR com categorizacao e batch fixes | 1.1.0 |

### learning (1)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **learning-opportunities** | Exercicios de aprendizado com Code Archaeology e dominios expandidos | 1.2.0 |

### operations (3) -- NOVO

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **deploy-release** | Pre-deploy checklist, release notes, rollback, versioning | 1.0.0 |
| **observability-setup** | Logging estruturado, metricas, tracing, health checks, alertas | 1.0.0 |
| **incident-response** | Resposta a incidentes: triage, troubleshooting, postmortem | 1.0.0 |

### orchestration (1) -- NOVO

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **feature-lifecycle** | Meta-skill que orquestra o ciclo completo de uma feature | 1.0.0 |

### project-management (1)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **linear-project-management** | Gestao Linear: sprints, retro, velocity, WIP limits | 1.1.0 |

### quality (5) -- NOVO

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **testing-strategy** | Workflow de testes: unit, integration, e2e, coverage analysis | 1.0.0 |
| **code-review** | Review proativo pre-PR com checklist configuravel | 1.0.0 |
| **dependency-guardian** | Audit de dependencias: seguranca, licencas, supply chain | 1.0.0 |
| **performance-audit** | Profiling, query optimization, bundle size, load testing | 1.0.0 |
| **workspace-hygiene** | Limpeza de artefatos: archive specs, prune plans, deep clean | 1.0.0 |

### security (1)

| Skill | Descricao | Versao |
|-------|-----------|--------|
| **security-best-practices** | Review de seguranca com scan proativo e OWASP Top 10 | 1.1.0 |

## Shared References

O diretorio `skills/_shared/references/` contem logica compartilhada entre skills:

- **linear-helpers.md** — Integracao Linear: detectar issue pela branch, atualizar status, comentarios

## Dependencias entre Skills

| Skill | Depende de | Tipo |
|-------|-----------|------|
| **spec-driven** | code-navi | Recomendado |
| **code-navi** | Context7 MCP | Recomendado |
| **finalize-branch** | `gh` CLI, code-review | Obrigatorio / Recomendado |
| **gh-fix-ci** | `gh` CLI autenticado | Obrigatorio |
| **gh-address-comments** | `gh` CLI autenticado | Obrigatorio |
| **linear-project-management** | `user-linear` MCP + `.cursor/linear.json` | Obrigatorio |
| **feature-lifecycle** | Todas as skills acima | Recomendado (graceful degradation) |
| **deploy-release** | docs-writer, dependency-guardian | Recomendado |
| **incident-response** | Sentry MCP, observability-setup | Recomendado |
| **security-best-practices** | dependency-guardian, Sentry MCP | Recomendado |

## Instalacao

### Instalar todas as skills

```bash
./install.sh --all
```

### Instalar skills especificas

```bash
./install.sh --skills code-navi,coding-guidelines,linear-project-management
```

### Instalar por categoria

```bash
./install.sh --category development    # code-navi, coding-guidelines, spec-driven
./install.sh --category github         # finalize-branch, gh-fix-ci, gh-address-comments
./install.sh --category security       # security-best-practices
```

**Categorias disponiveis:** `development`, `documentation`, `github`, `learning`, `operations`, `orchestration`, `project-management`, `quality`, `security`

### Atualizar skills instaladas

Puxa as alteracoes mais recentes do repositorio e re-copia apenas as skills ja instaladas:

```bash
./install.sh --update
```

### Remover uma skill

```bash
./install.sh --remove code-navi
```

### Listar skills e status

```bash
./install.sh --list
```

### Dry run (preview sem executar)

```bash
./install.sh --all --dry-run
```

### Force (sobrescrever sem backup)

```bash
./install.sh --all --force
```

### Backup automatico

Antes de sobrescrever uma skill existente, o script cria backup em `~/.cursor/skills/.backup/<skill-name>-<timestamp>/`. Use `--force` para pular o backup.

## Integracao Linear

A skill `linear-project-management` requer um arquivo `.cursor/linear.json` na raiz de cada projeto:

```json
{
  "team": "OK IA",
  "project": "Nome do Projeto"
}
```

### Criar config para o projeto atual

```bash
./install.sh --init-linear
```

O script pergunta o nome do projeto e cria `.cursor/linear.json`. Se o arquivo ja existir, pede confirmacao antes de sobrescrever.

### Workflow Linear

1. **Plan file** → Agent cria plano no Cursor (plan mode)
2. **Aprovar plano** → Agent cria issues no Linear automaticamente via MCP
3. **Executar** → Agent implementa seguindo as issues criadas
4. **Fechar** → Issues sao marcadas como done ao completar

Ver detalhes completos em `skills/project-management/linear-project-management/methodology.md`.

## Adicionando/Modificando Skills

### Estrutura de uma skill

```
skills/categoria/nome-da-skill/
├── SKILL.md              # Obrigatorio: instrucoes da skill
├── .skill-meta.json      # Obrigatorio: metadados (nome, versao, origem, licenca)
├── references/           # Opcional: arquivos de referencia
├── templates/            # Opcional: templates reutilizaveis
├── scripts/              # Opcional: scripts auxiliares
└── LICENSE.txt           # Opcional: licenca (quando aplicavel)
```

### Formato .skill-meta.json

```json
{
  "name": "nome-da-skill",
  "version": "1.0.0",
  "origin": "fonte-original",
  "author": "Autor",
  "license": "CC-BY-4.0",
  "last_updated": "2026-02-28",
  "description": "Descricao curta da skill.",
  "recommends": ["outras-skills-ou-MCPs"],
  "requires": ["dependencias-obrigatorias"]
}
```

### Como adicionar uma nova skill

1. Criar diretorio em `skills/categoria/nome-da-skill/`
2. Adicionar `SKILL.md` com instrucoes completas
3. Adicionar `.skill-meta.json` com metadados
4. Opcionalmente adicionar `references/`, `templates/`, `scripts/`
5. Atualizar `CHANGELOG.md`
6. Commit: `feat(skills): add nome-da-skill`

## Contexto do Time

O time **Transition 2 English (T2E)** usa estas skills nos projetos:

- **Okia Swarm** — Plataforma multi-tenant para agentes de IA (voz e texto)
- **Okia Academy** — Plataforma educacional com agentes de curso
- **OK Inteligencia Artificial** — Site institucional e comunidade

Estrutura do time:
- 1 Senior Developer (Rafael) — arquitetura, code review, deploy
- 1 Trainee Developer — features e testes com supervisao
- 1 Estagiario — tarefas guiadas com pair programming

Capacidade de sprint: ~30 story points/semana (metodologia em `skills/project-management/linear-project-management/methodology.md`).

## Creditos e Atribuicao

### CC-BY-4.0 (Atribuicao obrigatoria)

As skills abaixo sao distribuidas sob licenca [Creative Commons Attribution 4.0](https://creativecommons.org/licenses/by/4.0/). Os headers `metadata.author` nos arquivos `SKILL.md` **devem permanecer intactos**.

| Skill | Autor original |
|-------|---------------|
| code-navi | [Felipe Rodrigues](https://github.com/felipfr) |
| spec-driven | [Felipe Rodrigues](https://github.com/felipfr) |
| learning-opportunities | Chris Hicks (original), [Felipe Rodrigues](https://github.com/felipfr) (modified) |
| coding-guidelines | ale (Karpathy Guidelines) |
| docs-writer | [tech-leads-club](https://github.com/felipfr/tech-leads-club-cursor-skills) |

### MIT License

| Skill | Autor |
|-------|-------|
| gh-fix-ci | [OpenAI](https://github.com/openai/codex-universal/tree/main/skills) |
| gh-address-comments | [OpenAI](https://github.com/openai/codex-universal/tree/main/skills) |
| security-best-practices | [OpenAI](https://github.com/openai/codex-universal/tree/main/skills) |

### Proprietary

| Skill | Autor |
|-------|-------|
| finalize-branch | Rafael Pereira / T2E |
| linear-project-management | Rafael Pereira / T2E |

### Skills NAO incluidas

As skills em `~/.cursor/skills-cursor/` (create-rule, create-skill, create-subagent, update-cursor-settings, migrate-to-skills) sao **internas do Cursor** e nao sao incluidas neste repositorio. Elas sao gerenciadas automaticamente pelo editor.
