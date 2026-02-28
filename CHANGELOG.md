# Changelog

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
