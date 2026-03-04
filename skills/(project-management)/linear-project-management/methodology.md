# Metodologia de Gestao de Projetos - Linear

Guia completo de referencia para a equipe.

---

## 1. Estrutura do Workspace

### Team

O time de cada repositório é definido no `.cursor/linear.json` (campo `team` e `teamId`). Ao **configurar** o Linear num repo, o agente deve **listar times** e **perguntar ao usuário** qual time usar; nunca assumir um time por padrão. Exemplos de times no workspace: OK IA, ISP AI Stater, Transition2English, SAAS OKIA — o nome exato vem do Linear.

**Por que não criar times por área técnica (DB, Frontend, Backend):**
- Com equipe pequena (3-7 pessoas), todos tocam multiplas areas
- Times por area criam silos artificiais e dependencias cross-team em cada issue
- Overhead de coordenacao cresce exponencialmente com o numero de times
- Labels de area resolvem a categorizacao sem criar silos

### Projects

Cada produto ou iniciativa = 1 Project no Linear. Projetos ativos:

| Projeto | Descricao |
|---------|-----------|
| Okia Swarm - Production Deploy | Platform de agentes AI realtime |
| Video Studio Framework | Pipeline de producao de video marketing |
| Transition2English | Sistema de aprendizado de ingles com IA |
| ISP AI | IA para provedores de internet |
| ISPAI Dashboards N1 | Dashboards e métricas para provedores (ISPAI) |
| Sultel Telecom | Projeto cliente Sultel |
| Tech Provider | Instancia WhatsApp + Chatwoot |

Novos projetos: criar via Linear UI ou MCP `save_project`.

---

## 2. Taxonomia de Labels

### Grupo "Tipo" (obrigatorio em toda issue)

| Label | Quando usar |
|-------|-------------|
| `bug` | Defeitos, erros, comportamento incorreto |
| `feature` | Funcionalidade completamente nova |
| `improvement` | Melhoria em funcionalidade existente |
| `chore` | Manutencao, refactoring, config, infra interna |
| `spike` | Investigacao, pesquisa, prova de conceito |

### Grupo "Area" (onde o trabalho acontece)

| Label | Quando usar |
|-------|-------------|
| `backend` | Logica de servidor, APIs, servicos |
| `frontend` | Interface, componentes, UX |
| `database` | Schema, migrations, queries, modelagem |
| `infra` | Docker, CI/CD, deploy, monitoramento |
| `docs` | Documentacao tecnica ou de usuario |

### Grupo "Impacto" (quando aplicavel)

| Label | Quando usar |
|-------|-------------|
| `breaking` | Mudanca que quebra compatibilidade |
| `security` | Relacionado a seguranca de dados ou acesso |
| `performance` | Otimizacao de velocidade, memoria, rede |
| `ux` | Impacto direto na experiencia do usuario |

### Regras de aplicacao

- Toda issue DEVE ter **1 label de Tipo**
- Toda issue DEVE ter **pelo menos 1 label de Area** (pode ter mais de uma)
- Labels de Impacto sao **opcionais**, aplicar quando relevante
- Na duvida entre `feature` e `improvement`: se o usuario ja consegue fazer algo parecido = improvement; se e totalmente novo = feature

---

## 3. Prioridades

| Nivel | Nome | Quando usar | Tempo de resposta |
|-------|------|-------------|-------------------|
| 1 | Urgent | Producao quebrada, perda de dados, seguranca | Imediato |
| 2 | High | Feature core bloqueada, deadline proximo | Mesmo sprint |
| 3 | Normal | Trabalho planejado do sprint | Sprint atual/proximo |
| 4 | Low | Nice-to-have, melhorias futuras | Quando houver espaco |

---

## 4. Estimativas

Escala de Fibonacci para story points:

| Pontos | Complexidade | Tempo estimado | Exemplo |
|--------|-------------|----------------|---------|
| 1 | Trivial | < 1 hora | Corrigir typo, ajustar config |
| 2 | Simples | 1-3 horas | Adicionar campo em formulario |
| 3 | Medio | Meio dia | Implementar endpoint simples |
| 5 | Complexo | 1 dia | Feature com logica de negocio |
| 8 | Muito complexo | 2+ dias | Deve ser quebrado em sub-issues |

### Regras de estimativa

- Issues com 8+ pontos DEVEM ser decompostas em sub-issues
- Na duvida, arredonde para cima
- Estimativa e feita pelo responsavel, validada em planning
- Spike tem estimativa fixa: o time-box definido (geralmente 2 ou 3)

---

## 5. Sprints Semanais

### Configuracao Inicial (uma vez, via Linear UI)

Acesse **Team Settings > Cycles** do time escolhido (ex.: OK IA, ISP AI Stater) e configure:
1. **Enable cycles**: On
2. **Cycle duration**: 1 week
3. **Starting day**: Monday (segunda-feira)
4. **Upcoming cycles**: 4 (cria 4 sprints futuros)
5. **Cooldown**: None (sem cooldown para sprints semanais)
6. **Auto-add active issues**: On (issues em status "Started" entram no ciclo automaticamente)

Apos ativar, Linear cria ciclos automaticamente a cada semana.

### Cadencia

| Dia | Cerimonia | Duracao | Objetivo |
|-----|-----------|---------|----------|
| Segunda | Sprint Planning | 30 min | Selecionar issues do Backlog para Todo, atribuir responsaveis |
| Diario | Standup assincrono | - | Cada um atualiza status das suas issues no Linear |
| Sexta | Sprint Review | 15 min | Revisar o que foi concluido, mover incompletos para proximo sprint |

### Capacidade semanal

| Papel | Pontos/semana | Observacao |
|-------|--------------|------------|
| Senior | 15-20 | Inclui code review e mentoria |
| Trainee | 8-12 | Curva de aprendizado |
| Estagiario | 5-8 | Pair programming recomendado |

**Capacidade total do time**: ~28-40 pontos/sprint

### Regras de sprint

1. **WIP limit**: Maximo 2 issues "In Progress" por pessoa
2. **Carryover**: Issues nao concluidas voltam ao topo do Backlog com comentario explicando
3. **Scope creep**: Novas issues urgentes durante o sprint devem substituir outra issue de mesma estimativa
4. **Done = Done**: Issue so vai para Done quando merged, testado e verificado

---

## 6. Workflow de Estados

```
Backlog → Todo → In Progress → In Review → Done
                                          → Canceled
```

### Transicoes

| De | Para | Quem | Quando |
|----|------|------|--------|
| Backlog | Todo | Lead/Planning | Sprint planning ou priorizacao |
| Todo | In Progress | Dev responsavel | Ao iniciar o trabalho |
| In Progress | In Review | Dev responsavel | Ao abrir PR ou solicitar review |
| In Review | Done | Reviewer | Apos aprovacao e merge |
| In Review | In Progress | Reviewer | Quando precisa de ajustes |
| Qualquer | Canceled | Lead | Com comentario justificando |

### Regras de estado

- **Backlog**: Toda issue nova entra aqui por padrao
- **Todo**: Somente issues do sprint atual. Nao empilhar.
- **In Progress**: Ao mover para ca, o dev deve se atribuir como assignee
- **In Review**: Link do PR deve ser adicionado como comentario ou attachment
- **Canceled**: SEMPRE registrar o motivo como comentario antes de cancelar

---

## 7. Decomposicao de Issues

### Quando decompor

- Issue com estimativa >= 8 pontos
- Issue que leva mais de 2 dias
- Issue que envolve mais de uma area (backend + frontend)
- Issue onde partes podem ser entregues independentemente

### Padrao de decomposicao

**Issue pai**: Descreve o objetivo completo (feature/improvement)
**Sub-issues**: Cada uma entregavel independentemente

Exemplo:
```
[Feature] Implementar sistema de notificacoes (13 pts)
  ├── [backend] Criar servico de notificacoes (5 pts)
  ├── [database] Modelar entidades de notificacao (3 pts)
  ├── [frontend] Criar componente de notificacoes (3 pts)
  └── [chore] Configurar envio de email via provider (2 pts)
```

---

## 8. Escrita Code-Agnostic

### Principios

1. **Referencie modulos por nome de dominio**, nao por caminho de arquivo
   - Bom: "o servico de autenticacao"
   - Ruim: "`packages/api/src/services/auth.service.ts`"

2. **Descreva comportamento**, nao implementacao
   - Bom: "o sistema nao valida tokens expirados"
   - Ruim: "a funcao `validateToken()` nao checa o campo `exp`"

3. **Criterios de aceite verificaveis externamente**
   - Bom: "Requisicao com token expirado retorna 401"
   - Ruim: "O middleware chama `next()` com erro correto"

4. **Contexto de negocio antes de tecnico**
   - Comece explicando POR QUE (valor para usuario/negocio)
   - Depois explique O QUE (comportamento esperado)
   - NUNCA explique COMO (implementacao)

### Vocabulario de dominio

Manter consistencia na nomenclatura dos modulos/servicos:

| Termo de dominio | O que e |
|-----------------|---------|
| Servico de autenticacao | Login, tokens, sessoes |
| Engine de agentes | Orquestracao e execucao de agentes AI |
| Servico de billing | Cobranca, tokens, uso |
| Painel administrativo | Interface de gestao (admin) |
| Playground | Interface de teste de agentes |
| Servico de handlers | Execucao isolada de ferramentas |
| Servico de logs | Coleta e armazenamento de logs |

Adapte esta tabela para cada projeto. Mantenha-a atualizada conforme o dominio evolui.

---

## 9. Caminho de Escala

### 3-7 pessoas (atual)

- Times definidos por repo em `.cursor/linear.json` (ex.: OK IA, ISP AI Stater); na configuracao, perguntar ao usuario qual time.
- Projects: 1 por produto
- Labels: Tipo + Area + Impacto
- Sprints semanais
- Planning + Review semanal (45 min total)

### 8-15 pessoas

- 2-3 Teams por **dominio de produto** (ex: "Okia Platform", "Video Studio"), NAO por area tecnica
- Initiatives para coordenar trabalho cross-team
- Sprints quinzenais (mais tempo para trabalho profundo)
- Adicionar Sprint Retrospective (30 min, quinzenal)

### 15+ pessoas

- Teams por dominio com sub-teams se necessario
- Initiatives + Roadmaps no Linear
- Program Increment planning trimestral
- Tech leads por team
- Metricas de velocity e cycle time

---

## 10. Metricas a Acompanhar

### Semanais (a partir do primeiro sprint)

- **Velocity**: Total de pontos concluidos no sprint
- **Carryover rate**: % de issues que nao foram concluidas no sprint
- **WIP**: Numero medio de issues em progresso por pessoa

### Mensais (quando tiver historico)

- **Cycle time**: Tempo medio de In Progress ate Done
- **Lead time**: Tempo medio de criacao ate Done
- **Bug rate**: % de issues do tipo bug vs total

### Metas iniciais (time de 3)

- Velocity: estabilizar em ~30 pts/sprint apos 4 sprints
- Carryover: < 20%
- Cycle time: < 3 dias para issues de 1-3 pts
