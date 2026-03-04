# Configurar Projeto Linear

Use quando o usuario pedir "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo" ou "setup Linear". Siga este fluxo.

## Gatilhos

- "configurar projeto Linear", "aplicar padrao Linear", "configurar Linear neste repo", "setup Linear"

## Regra de ouro: perguntar quando nao souber

- **Nunca assumir** time ou projeto por padrao (ex.: "OK IA"). Se o arquivo `.cursor/linear.json` nao existir ou nao for claro a qual time/projeto este repo pertence, **sempre pergunte ao usuario** qual time e qual projeto usar.
- **Listar primeiro:** Chame `list_teams` e exiba a lista (nome + id). Pergunte: "Qual time deste repositório? (nome exato ou indique da lista)". Se o usuario citar um time que **nao** aparecer na lista, instrua: "O time [X] nao existe no workspace. Crie o time no Linear em **Settings > Teams** e depois repita a configuracao ou informe o nome exato do time apos criado."
- **Projeto:** Idem: liste projetos do time escolhido e pergunte se usa um existente ou quer criar um novo; nao invente nome de projeto.
- **Em qualquer duvida** sobre setup inicial (time, projeto, labels, primeiro uso), **pergunte ou instrua** o usuario como proceder para chegar ao resultado desejado.

## Sequencia

1. **Listar times**  
   Chamar `list_teams` e exibir lista (nome + id). **Perguntar ao usuario** qual time usar (por nome exato ou indice). Guardar `team` e `teamId`. Se o time informado nao existir na lista, nao prosseguir: instruir a criar o time no Linear e repetir.

2. **Projeto**  
   Chamar `list_projects` com o time escolhido (ou `team: "<nome ou id>"`). Exibir lista. **Perguntar** se o usuario quer um projeto existente (qual) ou criar um novo (qual nome).  
   - Se criar: `save_project(name, setTeams: [teamId])` e guardar `project` e `projectId` da resposta. Opcionalmente perguntar se deseja definir `startDate` e `targetDate` (ISO).  
   - Se escolher existente: guardar `project` e `projectId`.

3. **Aplicar padrao de labels**  
   Fonte: [methodology.md §2](methodology.md) (Tipo: bug, feature, improvement, chore, spike; Area: backend, frontend, database, infra, docs; Impacto: breaking, security, performance, ux).  
   Chamar `list_issue_labels` (por time ou workspace) para obter labels ja existentes. Para cada label do padrao que **nao** existir: `create_issue_label(name, teamId?, color?)`. Nao duplicar. Se houver duvida (ex.: label com nome parecido em outro caso), perguntar ou pular e informar.

4. **Gravar `.cursor/linear.json` no repo**  
   Escrever/atualizar no workspace: `.cursor/linear.json` com `team`, `teamId`, `project`, `projectId`.

5. **Resumo**  
   Informar: time e projeto configurados, quantas labels foram criadas (se aplicavel), caminho do `linear.json`.

## Limitacoes

- Criar **time** nao e possivel via MCP (so `list_teams`/`get_team`). Se o time desejado nao existir, instruir o usuario a criar em **Linear > Settings > Teams**. Ativar **cycles** e ajustar **workflow states** continua na UI do Linear (uma vez por time).
