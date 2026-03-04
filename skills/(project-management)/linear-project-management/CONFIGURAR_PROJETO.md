# Configurar Projeto Linear

Use quando o usuario pedir "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo" ou "setup Linear". Siga este fluxo.

## Gatilhos

- "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo", "setup Linear"

## Sequencia

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

## Limitacoes

- Criar **time** nao e possivel via MCP (só `list_teams`/`get_team`). Ativar **cycles** e ajustar **workflow states** continua na UI do Linear (uma vez por time).
