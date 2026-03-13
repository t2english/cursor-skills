---
name: linear-project-management
description: Gerencia projetos e issues no Linear via MCP. Use para criar, consultar, atualizar ou listar issues, sprints ou projetos. Tambem use para gestao de tarefas, sprint planning, backlog grooming, ou qualquer operacao no Linear. Triggers em "criar issue", "listar tarefas", "sprint", "backlog", "Linear", "planejar projeto", "criar milestone", ou quando um plano (plan file) for aprovado e precisar virar issues. Ao executar, usar team/projeto do linear.json, criar milestone com data atual, e validar cada issue ao concluir. Do NOT use para tarefas que nao envolvam o Linear.
---

# Linear Project Management

Skill para gestao de projetos no Linear via MCP (server: `user-linear`).

## Resumo (nao pular)

- **SEMPRE** ler `.cursor/linear.json` antes de qualquer operacao; usar `team` e `project` (e `teamId`/`projectId` se existirem) em todas as chamadas.
- Ao **executar um plano aprovado**: criar **milestone** do plano com **targetDate = data atual** (hoje em ISO); usar team/projeto do config; criar 1 issue por to-do associada ao milestone; ao concluir cada to-do, **validar** e so entao mover para **Done** + comentario resumo.
- **Configurar projeto**: quando o usuario pedir, seguir o fluxo em [project-setup.md](project-setup.md). **Nunca assumir** time ou projeto: listar times/projetos e **perguntar ao usuario** qual time e qual projeto usar. Se nao conseguir relacionar o repo a um time/projeto existente ou houver duvida no setup inicial, **perguntar ou instruir** como proceder (ex.: "Qual time deste repositório?", "O time X nao existe — crie em Linear > Settings > Teams e repita").
- **Quando nao souber ou tiver duvidas** sobre setup inicial (time, projeto, primeiro uso do Linear no repo), **pergunte ao usuario** ou **instrua** o que fazer para obter o resultado desejado; nao invente valores.

## Passo 1: Obter Contexto do Projeto

**SEMPRE antes de qualquer operacao Linear**, leia o arquivo `.cursor/linear.json` na raiz do repositorio atual (ou em `.cursor/linear.json`).

```json
{
  "team": "<nome exato do time no Linear>",
  "teamId": "<uuid do time>",
  "project": "<nome do projeto>",
  "projectId": "<uuid do projeto>"
}
```

Use o **nome exato** do time e do projeto como aparecem no Linear (ex.: "ISP AI Stater", "OK IA"). Nunca assuma um valor por padrao; se o arquivo nao existir, siga project-setup.md e pergunte ao usuario.

Para logica compartilhada de integracao Linear (detectar issue pela branch, atualizar status, etc.), veja `_shared/references/linear-helpers.md`.

Use `team` e `project` como filtros diretos em TODAS as chamadas MCP. Quando for necessario **ID** (ex.: `list_cycles`), use `teamId` do config se existir; senao use `team` (nome). Idem para `projectId`/`project`.

**Excecao:** Nunca chame `list_teams` ou `list_projects` a menos que (a) explicitamente solicitado pelo usuario, ou (b) o arquivo **nao existir** e o usuario quiser **configurar o Linear** para o repo. Nesse caso (b), use `list_teams` e `list_projects` para **perguntar** ao usuario qual time e qual projeto usar (exibir a lista e pedir escolha); **nunca assuma** um time ou projeto por padrao. Depois crie o arquivo com os quatro campos (`team`, `teamId`, `project`, `projectId`).

Se o arquivo nao existir e o usuario nao pedir configuracao, **pergunte** qual team e project usar e sugira criar o `.cursor/linear.json` (ou ofereca o fluxo de configuracao guiada em project-setup.md). Se nao souber ou tiver duvida sobre qual time/projeto relacionar a este repo, **pergunte ou instrua** o usuario como proceder.

## Passo 2: Operacoes Disponiveis

### Consultar Issues do Projeto

```
CallMcpTool(server: "user-linear", toolName: "list_issues", arguments: {
  project: "<project do config>",
  team: "<team do config>",
  state: "<filtro opcional: Backlog | Todo | In Progress | In Review | Done>",
  assignee: "me",  // ou nome/email especifico
  limit: 50
})
```

### Consultar Issues do Sprint Atual

```
CallMcpTool(server: "user-linear", toolName: "list_issues", arguments: {
  team: "<team do config>",
  project: "<project do config>",
  state: "Todo"
})
```

Para ver o que esta em andamento, filtre tambem `state: "In Progress"` e `state: "In Review"`.

### Ver Detalhes de uma Issue

```
CallMcpTool(server: "user-linear", toolName: "get_issue", arguments: {
  id: "<issue-id>",
  includeRelations: true
})
```

### Criar Issue

Use `save_issue` com a descricao seguindo os templates code-agnostic (ver abaixo e [templates.md](templates.md)):

```
CallMcpTool(server: "user-linear", toolName: "save_issue", arguments: {
  title: "<titulo claro e conciso>",
  description: "<markdown seguindo template>",
  team: "<team do config>",
  project: "<project do config>",
  priority: 3,  // 1=Urgent, 2=High, 3=Normal, 4=Low
  labels: ["feature", "backend"],  // tipo + area
  assignee: "me",  // ou null para nao atribuir
  estimate: 3,  // pontos fibonacci: 1, 2, 3, 5, 8
  // Opcionais: cycle: "<id ou nome do ciclo>", milestone: "<nome ou id>", dueDate: "<ISO>"
})
```

### Atualizar Status

```
CallMcpTool(server: "user-linear", toolName: "save_issue", arguments: {
  id: "<issue-id>",
  state: "In Progress"  // Backlog | Todo | In Progress | In Review | Done | Canceled
})
```

### Registrar Progresso (Comentario)

```
CallMcpTool(server: "user-linear", toolName: "create_comment", arguments: {
  issueId: "<issue-id>",
  body: "## Progresso\n\n- Implementado X\n- Proximo passo: Y"
})
```

### Criar Sub-issues

Para decompor trabalho complexo, crie issues filhas:

```
CallMcpTool(server: "user-linear", toolName: "save_issue", arguments: {
  title: "Sub-tarefa especifica",
  description: "...",
  team: "<team do config>",
  project: "<project do config>",
  parentId: "<issue-pai-id>",
  labels: ["chore", "backend"],
  estimate: 2
})
```

### Consultar Ciclos/Sprints

Se `linear.json` tiver `teamId`, use-o; senao use `team` (nome):

```
CallMcpTool(server: "user-linear", toolName: "list_cycles", arguments: {
  teamId: "<teamId do config se existir>",  // ou team: "<team do config>"
  type: "current"  // current | previous | next
})
```

### Consultar Milestones do Projeto

```
CallMcpTool(server: "user-linear", toolName: "list_milestones", arguments: {
  project: "<project do config>"
})
```

## Configurar Projeto Linear

Quando o usuario pedir "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo" ou "setup Linear", siga o fluxo completo em **[project-setup.md](project-setup.md)** (listar times, listar/escolher ou criar projeto, aplicar padrao de labels, gravar `.cursor/linear.json`).

## Regras de Escrita Code-Agnostic

**NUNCA** referencie em issues:
- Caminhos de arquivo (`src/services/auth.ts`)
- Numeros de linha (`linha 42`)
- Trechos de codigo (blocos de codigo)
- Nomes de variaveis ou funcoes especificas (`handleAuth()`)

**SEMPRE** use:
- Nomes de dominio: "servico de autenticacao", "engine de agentes", "modulo de billing"
- Comportamento: "o sistema nao valida tokens expirados"
- Impacto: "usuarios perdem a sessao ao trocar de aba"
- Criterios verificaveis: "[ ] Tokens expirados retornam 401"

## Templates Rapidos

### Bug

```markdown
## Contexto
[Area/funcionalidade do sistema afetada]

## Comportamento Atual
[O que acontece - descreva o sintoma, nao o codigo]

## Comportamento Esperado
[O que deveria acontecer]

## Passos para Reproduzir
1. [Acao 1]
2. [Acao 2]

## Criterios de Aceite
- [ ] [Verificacao 1]
- [ ] [Verificacao 2]
```

### Feature

```markdown
## Contexto
[Motivacao de negocio - por que precisamos disso]

## Descricao
[O que o sistema deve fazer - linguagem de dominio]

## Regras de Negocio
- [Regra 1]
- [Regra 2]

## Criterios de Aceite
- [ ] [Verificacao 1]
- [ ] [Verificacao 2]

## Fora do Escopo
[O que NAO faz parte desta issue]
```

Para templates completos de todos os tipos (bug, feature, improvement, chore, spike), consulte [templates.md](templates.md).

## Labels Obrigatorias

Toda issue deve ter no minimo:
1. **Uma label de Tipo**: bug, feature, improvement, chore, spike
2. **Uma label de Area** (quando aplicavel): backend, frontend, database, infra, docs

Labels de **Impacto** sao opcionais: breaking, security, performance, ux

## Prioridades

- **1 (Urgent)**: Producao quebrada, perda de dados
- **2 (High)**: Funcionalidade core bloqueada, deadline proximo
- **3 (Normal)**: Trabalho planejado do sprint
- **4 (Low)**: Nice-to-have, melhorias futuras

## Estimativas (Fibonacci)

- **1** = Trivial (< 1h)
- **2** = Simples (1-3h)
- **3** = Medio (meio dia)
- **5** = Complexo (1 dia)
- **8** = Muito complexo (2+ dias - considerar quebrar em sub-issues)

## Workflow de Transicao

```
Backlog → Todo → In Progress → In Review → Done
                                          → Canceled
```

- **Backlog**: Registrada, nao priorizada
- **Todo**: No sprint atual, pronta para pegar
- **In Progress**: Em desenvolvimento (max 2 por pessoa)
- **In Review**: PR aberto ou aguardando validacao
- **Done**: Merged, testado e verificado
- **Canceled**: Descartada (registrar motivo em comentario)

## Controle de Prazos e Agendas

Use os campos de data do MCP para controle de agenda e estimativas:

| Nivel | Ferramenta | Campos | Uso |
|-------|------------|--------|-----|
| **Projeto** | `save_project` | `startDate`, `targetDate` (ISO) | Envelope de tempo do projeto; visivel no roadmap. No fluxo "Configurar projeto", ao criar projeto, opcionalmente preencher. |
| **Milestone** | `save_milestone` | `targetDate` (ISO, opcional) | Prazo da entrega/plano. No workflow plano→issues, ao criar o milestone do plano, usar **data atual** (hoje em ISO) por padrao. |
| **Issue** | `save_issue` | `dueDate` (ISO), `estimate` (pontos) | `dueDate` para prazos especificos (releases, dependencias externas); `estimate` para capacidade do sprint (Fibonacci). |

Regras curtas: **Projeto** = periodo total; **Milestone** = meta da entrega; **Issue** = prazo pontual + estimativa para planning.

## Padrao de Comentarios de Progresso

Ao trabalhar em uma issue, registre progresso via comentarios:

```markdown
## Progresso [data]

### Concluido
- [O que foi feito - comportamento implementado]

### Proximo
- [Proximos passos planejados]

### Bloqueios
- [Se houver bloqueios, descreva aqui]
```

## Workflow: Plano Aprovado → Issues no Linear

Quando o usuario aprova um plano (plan file do Cursor), o agente deve **automaticamente criar issues no Linear** antes de comecar a executar. Este e o fluxo padrao para qualquer plano com 2+ tarefas.

### Comportamento padrao (obrigatorio)

- **Milestone:** Sempre criar um milestone para o plano. Nome = titulo do plano (ou do plan file). **targetDate = data atual** (hoje em ISO, ex.: `2025-03-03`), salvo se o plano ou o usuario indicar outra data.
- **Team e projeto:** Sempre usar `team` e `project` (e `teamId`/`projectId` se existirem) do `.cursor/linear.json`. Nao perguntar; usar o config do repo.
- **Ao concluir cada issue:** Antes de mover para Done, **validar** que a tarefa esta concluida (criterios de aceite atendidos ou implementacao verificada/testes passando). So entao mover a issue para **Done** e adicionar **comentario** com resumo do que foi feito.

### Gatilho

O workflow e ativado quando:
- O usuario diz "aprovar plano", "executar plano", "pode fazer", "implementar" apos um plano ser apresentado
- Existe um plan file (`.cursor/plans/*.plan.md`) com to-dos pendentes

### Sequencia de Execucao

```
1. Ler .cursor/linear.json (team, project, teamId se existir)
2. Ler plan file e extrair todos os to-dos
3. Criar milestone do plano: save_milestone(project, name: "<titulo do plano>", targetDate: "<data atual em ISO, ex. 2025-03-03>"). Usar sempre a data do dia, salvo se o plano ou o usuario indicar outra.
4. Obter ciclo atual (opcional): list_cycles(teamId ou team, type: "current"). Se retornar ciclo, usar em cada save_issue.
5. Criar issues no Linear (1 issue por to-do)
   - Titulo: conteudo do to-do
   - milestone: "<nome ou id do milestone criado no passo 3>"
   - cycle: id ou nome do ciclo (se passo 4 retornou ciclo; senao omitir)
   - Labels: inferir tipo + area pelo contexto
   - Prioridade: 3 (Normal) padrao, 2 (High) se urgente
   - Estimativa: inferir pela complexidade (1-5 pts)
   - Estado: Backlog
6. Reportar ao usuario: lista de issues criadas com IDs
7. Mover primeira issue para In Progress
8. Executar sequencialmente, atualizando status no Linear
9. Ao concluir cada to-do: (1) Validar que a tarefa esta concluida (criterios atendidos ou verificacao rapida); (2) Mover issue para Done; (3) Comentar resumo do que foi feito.
```

**Associar ao sprint atual:** Para colocar as issues no ciclo/sprint corrente, chame `list_cycles(teamId: config.teamId ou team: config.team, type: "current")`. Se houver ciclo ativo, passe o id ou nome em cada `save_issue(..., cycle: "<id ou nome do ciclo>")`.

### Regras do Workflow

- **Milestone do plano:** Sempre criar um milestone para o plano (passo 3) e associar todas as issues a ele (`milestone` em `save_issue`).
- **Descricao code-agnostic**: A descricao da issue deve seguir os templates (comportamento/dominio, sem referenciar arquivos)
- **Issue pai opcional**: Se o plano tem um titulo claro (ex: "Migrar autenticacao"), criar uma issue pai e as demais como sub-issues
- **Sprint atual**: Se houver ciclo ativo, associar as issues ao ciclo corrente (ver passo 4-5 acima)
- **Feedback continuo**: Apos criar todas as issues, listar os IDs para o usuario antes de comecar a executar
- **Falha graceful**: Se o MCP Linear nao estiver disponivel, continuar a execucao normalmente (apenas sem rastreamento no Linear)

### Exemplo de Criacao

Para um plano com 3 to-dos:

```
Plan: "Configurar monitoramento do sistema"
  - to-do 1: Configurar healthcheck endpoint
  - to-do 2: Adicionar metricas Prometheus
  - to-do 3: Criar dashboard Grafana

→ Issue pai: "Configurar monitoramento do sistema" (feature, infra, 8 pts)
  → Sub-issue: "Configurar healthcheck endpoint" (chore, infra, 2 pts)
  → Sub-issue: "Adicionar metricas Prometheus" (feature, infra, 3 pts)
  → Sub-issue: "Criar dashboard Grafana" (chore, infra, 3 pts)
```

### Atualizacao de Progresso

Durante a execucao de cada issue:
- Mover para **In Progress** ao iniciar
- Adicionar comentario de progresso se a tarefa demorar
- **Antes de mover para Done:** Validar que a tarefa esta concluida (criterios de aceite ou verificacao). Em seguida mover para **Done** e adicionar comentario com resumo do que foi feito.
- Se encontrar bloqueio, registrar como comentario e pular para a proxima

## Workflow: Sprint Retrospective

Automacao da cerimonia de retrospectiva.

### Gatilho

- O usuario diz "retrospectiva", "retro", "o que podemos melhorar"

### Sequencia

```
1. Ler .cursor/linear.json (team + project)
2. Buscar ciclo anterior (list_cycles type: "previous")
3. Listar issues Done do ciclo anterior
4. Apresentar 3 perguntas ao usuario:
   a. O que funcionou bem neste sprint?
   b. O que poderia ser melhorado?
   c. Que acoes concretas devemos tomar?
5. Aguardar respostas do usuario
6. Para cada acao concreta, criar issue no Linear:
   - Tipo: improvement
   - Prioridade: 3 (Normal)
   - Descricao: acao concreta com contexto da retro
7. Apresentar resumo: acoes criadas com IDs
8. Sugerir Deep Clean: se a skill workspace-hygiene estiver disponivel,
   oferecer: "Quer rodar uma limpeza profunda do workspace? Vou auditar
   specs arquivados, notas antigas e arquivos orfaos."
   Se aceito, invocar workspace-hygiene Deep Clean.
```

## Velocity Tracking

Acompanhar a velocidade do time ao longo dos sprints.

### Gatilho

- O usuario diz "velocity", "velocidade do time", "metricas de sprint"

### Sequencia

```
1. Ler .cursor/linear.json (team)
2. Buscar ciclo atual e os 2 anteriores (list_cycles)
3. Para cada ciclo, calcular:
   - Pontos comprometidos (total de estimativas das issues no ciclo)
   - Pontos completados (total de estimativas das issues Done)
   - Completion rate (completados / comprometidos * 100)
4. Apresentar tabela comparativa:
   | Sprint | Comprometido | Completado | Rate |
5. Calcular media movel de 3 sprints
6. Sugerir capacidade para proximo sprint baseado na media
```

## WIP Limits

Limite de trabalho em progresso para evitar context switching.

**Regra**: Maximo 2 issues "In Progress" por pessoa. Antes de mover nova issue para In Progress, verificar se o limite ja foi atingido.

Se o limite for atingido:
1. Listar issues In Progress do usuario
2. Perguntar qual deve ser concluida ou pausada primeiro
3. Somente apos liberar uma, mover a nova para In Progress

## Integracao com Outras Skills

### CodeNavi (durante execucao)

Veja `_shared/references/linear-helpers.md` para a logica compartilhada de integracao.

## Referencia Completa

- Fluxo configurar projeto: [project-setup.md](project-setup.md)
- Templates detalhados: [templates.md](templates.md)
- Metodologia completa (labels, sprints, escala): [methodology.md](methodology.md)
