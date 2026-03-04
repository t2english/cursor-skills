---
name: linear-project-management
description: Gerencia projetos e issues no Linear via MCP. Use quando o usuario pedir para criar, consultar, atualizar ou listar issues, sprints, projetos ou qualquer operacao relacionada ao Linear, gestao de tarefas, backlog ou sprint planning. Tambem use quando um plano (plan file) for aprovado para criar issues automaticamente no Linear antes da execucao.
---

# Linear Project Management

Skill para gestao de projetos no Linear via MCP (server: `user-linear`).

## Passo 1: Obter Contexto do Projeto

**SEMPRE antes de qualquer operacao Linear**, leia o arquivo `.cursor/linear.json` na raiz do repositorio atual (ou em `.cursor/linear.json`).

```json
{
  "team": "OK IA",
  "teamId": "<uuid ou omitir se não disponível>",
  "project": "Nome do Projeto",
  "projectId": "<uuid ou omitir se não disponível>"
}
```

Use `team` e `project` como filtros diretos em TODAS as chamadas MCP. Quando for necessario **ID** (ex.: `list_cycles`), use `teamId` do config se existir; senao use `team` (nome). Idem para `projectId`/`project`.

**Excecao:** Nunca chame `list_teams` ou `list_projects` a menos que (a) explicitamente solicitado pelo usuario, ou (b) o arquivo **nao existir** e o usuario quiser **configurar o Linear** para o repo. Nesse caso (b), use `list_teams` e `list_projects` para guiar a escolha e entao crie o arquivo com os quatro campos (`team`, `teamId`, `project`, `projectId`).

Se o arquivo nao existir e o usuario nao pedir configuracao, pergunte qual team e project usar e sugira criar o `.cursor/linear.json` (ou ofereca o fluxo de configuracao guiada acima).

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

Use quando o usuario pedir "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo" ou "setup Linear".

### Gatilhos

- "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo", "setup Linear"

### Sequencia

1. **Listar times**  
   Chamar `list_teams` e exibir lista (nome + id). Usuario escolhe o time (por nome ou indice). Guardar `team` e `teamId`.

2. **Projeto**  
   Chamar `list_projects` (ou listar e filtrar pelo time escolhido). Usuario escolhe um projeto existente **ou** informa nome para **criar** um novo.  
   - Se criar: `save_project(name, team)` e guardar `project` e `projectId` da resposta. Opcionalmente perguntar se deseja definir `startDate` e `targetDate` (ISO) para controle de agenda.  
   - Se escolher existente: guardar `project` e `projectId`.

3. **Aplicar padrao de labels**  
   Fonte: [methodology.md §2](methodology.md) (Tipo: bug, feature, improvement, chore, spike; Area: backend, frontend, database, infra, docs; Impacto: breaking, security, performance, ux).  
   Chamar `list_issue_labels` (por time ou workspace) para obter labels ja existentes. Para cada label do padrao que **nao** existir: `create_issue_label(name, parent?, teamId?, color?)`. Nao duplicar.

4. **Gravar `.cursor/linear.json` no repo**  
   Escrever/atualizar na raiz do workspace: `team`, `teamId` (se tiver), `project`, `projectId` (se tiver).

5. **Resumo**  
   Informar: time e projeto configurados, quantas labels foram criadas, caminho do `linear.json`.

### Limitacoes

- Criar **time** nao e possivel via MCP (só `list_teams`/`get_team`). Ativar **cycles** e ajustar **workflow states** continua na UI do Linear (uma vez por time).

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
| **Milestone** | `save_milestone` | `targetDate` (ISO, opcional) | Prazo da entrega/plano. No workflow plano→issues, ao criar o milestone do plano, perguntar ou usar data se o plano tiver. |
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

### Gatilho

O workflow e ativado quando:
- O usuario diz "aprovar plano", "executar plano", "pode fazer", "implementar" apos um plano ser apresentado
- Existe um plan file (`.cursor/plans/*.plan.md`) com to-dos pendentes

### Sequencia de Execucao

```
1. Ler .cursor/linear.json (team, project, teamId se existir)
2. Ler plan file e extrair todos os to-dos
3. Criar milestone do plano: save_milestone(project, name: "<titulo do plano>", targetDate?: "<ISO opcional>")
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
9. Ao concluir cada to-do: mover issue para Done + comentar resumo
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
- Mover para **Done** ao concluir, com comentario resumindo o que foi feito
- Se encontrar bloqueio, registrar como comentario e pular para a proxima

## Referencia Completa

- Templates detalhados: [templates.md](templates.md)
- Metodologia completa (labels, sprints, escala): [methodology.md](methodology.md)
