# Cursor Skills

Repositorio centralizado de Cursor Skills do time **Transition 2 English (T2E)**. Contem 10 skills organizadas em 6 categorias, com script de instalacao automatizado e sistema de backup.

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

| Skill | Categoria | Descricao | Versao | Origem |
|-------|-----------|-----------|--------|--------|
| **coding-guidelines** | development | Diretrizes anti-overengineering (Karpathy Guidelines) | 1.0.0 | tech-leads-club |
| **code-navi** | development | Exploracao metodica de codebase com .notebook/ persistente | 1.1.0 | tech-leads-club/felipfr |
| **spec-driven** | development | Planejamento em 4 fases: Specify, Design, Tasks, Implement+Validate | 1.0.0 | tech-leads-club/felipfr |
| **docs-writer** | documentation | Escrita e revisao de documentacao com estilo consistente | 1.0.0 | tech-leads-club |
| **finalize-branch** | github | Workflow: lint, knip, build, test, push, PR, CI, merge, cleanup | 1.0.0 | T2E (custom) |
| **gh-fix-ci** | github | Diagnostico e fix de CI no GitHub Actions | 1.0.0 | openai/skills |
| **gh-address-comments** | github | Resolver comentarios e reviews de PR | 1.0.0 | openai/skills |
| **learning-opportunities** | learning | Exercicios de aprendizado durante AI-assisted coding | 1.1.0 | Chris Hicks/felipfr |
| **linear-project-management** | project-management | Gestao de projetos no Linear: plan→issues, sprints, templates | 1.2.0 | T2E (custom) |
| **security-best-practices** | security | Revisao de seguranca para Python, JS/TS, Go | 1.0.0 | openai/skills |

## Dependencias entre Skills

Algumas skills referenciam outras ferramentas ou skills:

| Skill | Depende de | Tipo |
|-------|-----------|------|
| **spec-driven** | code-navi | Recomendado (exploracao de codebase) |
| **code-navi** | Context7 MCP | Recomendado (lookup de docs) |
| **finalize-branch** | `gh` CLI autenticado | Obrigatorio |
| **gh-fix-ci** | `gh` CLI autenticado | Obrigatorio |
| **gh-address-comments** | `gh` CLI autenticado | Obrigatorio |
| **linear-project-management** | `user-linear` MCP + `.cursor/linear.json` | Obrigatorio |

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

**Categorias disponiveis:** `development`, `documentation`, `github`, `learning`, `project-management`, `security`

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
