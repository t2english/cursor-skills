# Changelog

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
