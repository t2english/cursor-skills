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
  "project": "Nome do Projeto"
}
```

Use `team` e `project` como filtros diretos em TODAS as chamadas MCP. Nunca chame `list_teams` ou `list_projects` a menos que explicitamente solicitado.

Se o arquivo nao existir, pergunte ao usuario qual team e project usar. Sugira criar o `.cursor/linear.json`.

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
  estimate: 3  // pontos fibonacci: 1, 2, 3, 5, 8
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

```
CallMcpTool(server: "user-linear", toolName: "list_cycles", arguments: {
  teamId: "<team-id>",
  type: "current"  // current | previous | next
})
```

### Consultar Milestones do Projeto

```
CallMcpTool(server: "user-linear", toolName: "list_milestones", arguments: {
  project: "<project do config>"
})
```

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
1. Ler .cursor/linear.json (team + project)
2. Ler plan file e extrair todos os to-dos
3. Criar issues no Linear (1 issue por to-do)
   - Titulo: conteudo do to-do
   - Labels: inferir tipo + area pelo contexto
   - Prioridade: 3 (Normal) padrao, 2 (High) se urgente
   - Estimativa: inferir pela complexidade (1-5 pts)
   - Estado: Backlog
4. Reportar ao usuario: lista de issues criadas com IDs
5. Mover primeira issue para In Progress
6. Executar sequencialmente, atualizando status no Linear
7. Ao concluir cada to-do: mover issue para Done + comentar resumo
```

### Regras do Workflow

- **Descricao code-agnostic**: A descricao da issue deve seguir os templates (comportamento/dominio, sem referenciar arquivos)
- **Issue pai opcional**: Se o plano tem um titulo claro (ex: "Migrar autenticacao"), criar uma issue pai e as demais como sub-issues
- **Sprint atual**: Se houver ciclo ativo, associar as issues ao ciclo corrente
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
