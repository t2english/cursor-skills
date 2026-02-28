# Templates de Issues - Linear

Templates completos para registro de issues seguindo metodologia code-agnostic.
Todos os templates em portugues.

---

## Bug Report

**Labels**: `bug` + label de area (ex: `backend`, `frontend`)

```markdown
## Contexto

[Qual funcionalidade ou area do sistema e afetada. Referenciar pelo nome de dominio, ex: "servico de autenticacao", "painel administrativo", "engine de agentes"]

## Comportamento Atual

[Descreva o que acontece HOJE. Foque no sintoma observavel, nao no codigo.
Ex: "Ao tentar renovar a sessao, o sistema retorna erro 500 em vez de gerar um novo token"]

## Comportamento Esperado

[Descreva o que DEVERIA acontecer.
Ex: "O sistema deve renovar o token silenciosamente e manter a sessao ativa"]

## Passos para Reproduzir

1. [Acao concreta que qualquer pessoa pode seguir]
2. [Proxima acao]
3. [Resultado observado]

## Ambiente (quando relevante)

- Navegador/cliente: [ex: Chrome 120, API direta]
- Ambiente: [local, staging, producao]

## Impacto

[Quem e afetado e com que gravidade. Ex: "Todos os usuarios perdem a sessao apos 30 minutos, gerando reclamacoes de suporte"]

## Criterios de Aceite

- [ ] [Condicao verificavel sem conhecer a implementacao]
- [ ] [Ex: "Sessoes permanecem ativas por pelo menos 8 horas sem intervencao"]
- [ ] [Ex: "Renovacao de token retorna 200 com novo token valido"]

## Observacoes

[Informacoes adicionais, screenshots, logs de erro (sem trechos de codigo)]
```

---

## Feature Request

**Labels**: `feature` + label de area

```markdown
## Contexto

[Motivacao de negocio. Por que precisamos desta funcionalidade?
Ex: "Clientes pedem a possibilidade de testar agentes de voz antes de publicar em producao"]

## Descricao

[O que o sistema deve fazer. Use linguagem de dominio.
Ex: "Criar um ambiente de teste (sandbox) onde o usuario pode interagir com o agente de voz em tempo real, com todas as ferramentas ativas, sem afetar dados de producao"]

## Regras de Negocio

- [Regra 1: Ex: "O ambiente de teste deve ser isolado por organizacao"]
- [Regra 2: Ex: "Sessoes de teste nao devem gerar cobranca de tokens"]
- [Regra 3: Ex: "Limite maximo de 5 minutos por sessao de teste"]

## Comportamento Esperado

[Descreva o fluxo do usuario passo a passo]

1. [Passo 1: Ex: "Usuario acessa a pagina do agente e clica em 'Testar'"]
2. [Passo 2: Ex: "Sistema inicia uma sessao WebRTC com o agente"]
3. [Passo 3: Ex: "Usuario interage por voz, vendo os logs em tempo real"]
4. [Passo 4: Ex: "Ao encerrar, sistema exibe resumo da interacao"]

## Criterios de Aceite

- [ ] [Condicao verificavel]
- [ ] [Ex: "Sessao de teste inicia em menos de 3 segundos"]
- [ ] [Ex: "Logs da sessao sao visiveis em tempo real no painel"]
- [ ] [Ex: "Nenhum dado de teste aparece em relatorios de producao"]

## Fora do Escopo

[O que NAO faz parte desta issue. Importante para limitar o trabalho.
Ex: "Nao inclui gravacao e replay de sessoes (issue separada)", "Nao inclui metricas de qualidade do agente"]

## Dependencias

[Issues ou funcionalidades que precisam estar prontas antes.
Ex: "Depende da issue OKIA-XX (isolamento multi-tenant do servico de sessoes)"]

## Observacoes

[Qualquer informacao adicional, referencias externas, mockups]
```

---

## Improvement

**Labels**: `improvement` + label de area

```markdown
## Contexto

[Qual funcionalidade existente sera melhorada e por que.
Ex: "O painel administrativo atualmente carrega todas as organizacoes de uma vez, causando lentidao quando ha mais de 50 organizacoes"]

## Situacao Atual

[Como funciona hoje - descreva o comportamento, nao a implementacao.
Ex: "A listagem de organizacoes carrega todos os registros e exibe em uma tabela simples sem paginacao"]

## Melhoria Proposta

[O que deve mudar.
Ex: "Implementar paginacao com 20 itens por pagina, busca por nome e filtro por status (ativa/inativa)"]

## Beneficios

- [Ex: "Reducao do tempo de carregamento de 8s para < 1s"]
- [Ex: "Facilita encontrar organizacoes especificas"]
- [Ex: "Prepara para escala de 500+ organizacoes"]

## Criterios de Aceite

- [ ] [Ex: "Listagem carrega em menos de 1 segundo com 500 registros"]
- [ ] [Ex: "Paginacao funciona com navegacao entre paginas"]
- [ ] [Ex: "Busca filtra por nome em tempo real"]
- [ ] [Ex: "Comportamento anterior (sem filtros) continua funcionando"]

## Fora do Escopo

[Limites claros do que nao sera feito nesta melhoria]

## Observacoes

[Referencias, benchmarks, comparacoes com outras ferramentas]
```

---

## Chore / Task

**Labels**: `chore` + label de area

```markdown
## Contexto

[Qual aspecto de manutencao ou infraestrutura precisa de atencao.
Ex: "As dependencias do projeto estao 6 meses desatualizadas, incluindo vulnerabilidades conhecidas"]

## Descricao

[O que precisa ser feito.
Ex: "Atualizar todas as dependencias para versoes mais recentes compativeis, resolver breaking changes e garantir que todos os testes passem"]

## Escopo

- [Item 1: Ex: "Atualizar dependencias de producao"]
- [Item 2: Ex: "Atualizar dependencias de desenvolvimento"]
- [Item 3: Ex: "Resolver breaking changes documentados"]
- [Item 4: Ex: "Validar que CI/CD continua verde"]

## Criterios de Aceite

- [ ] [Ex: "Nenhuma vulnerabilidade conhecida em dependencias de producao"]
- [ ] [Ex: "Todos os testes passam sem alteracao"]
- [ ] [Ex: "Build de producao gera artefatos validos"]

## Riscos

[Riscos conhecidos desta manutencao.
Ex: "Breaking changes em bibliotecas de UI podem exigir ajustes visuais"]

## Observacoes

[Comandos uteis, links para changelogs relevantes]
```

---

## Spike / Investigacao

**Labels**: `spike` + label de area

```markdown
## Contexto

[O que motivou esta investigacao.
Ex: "Precisamos decidir qual abordagem usar para cache distribuido antes de implementar a feature de sessoes compartilhadas"]

## Pergunta a Responder

[Pergunta clara e objetiva que esta spike deve responder.
Ex: "Qual solucao de cache (Redis Cluster vs Memcached vs cache em memoria) atende melhor os requisitos de sessoes compartilhadas com <100ms de latencia?"]

## Criterios de Investigacao

- [Aspecto 1: Ex: "Latencia de leitura/escrita"]
- [Aspecto 2: Ex: "Complexidade de operacao e manutencao"]
- [Aspecto 3: Ex: "Custo de infraestrutura"]
- [Aspecto 4: Ex: "Compatibilidade com a arquitetura atual"]

## Restricoes

[Limites da investigacao.
Ex: "Time-box de 4 horas", "Considerar apenas solucoes open-source", "Deve funcionar com a infra atual em Docker Compose"]

## Entregavel

[O que esta spike deve produzir.
Ex: "Documento comparativo com recomendacao fundamentada, registrado como comentario nesta issue"]

## Observacoes

[Links uteis, documentacoes a consultar, experiencias anteriores]
```

---

## Regras Gerais para Todos os Templates

1. **Titulo**: Claro, conciso, acionavel. Formato: `[Verbo] [o que] [onde]`.
   - Bom: "Implementar paginacao na listagem de organizacoes"
   - Ruim: "Melhorar performance"

2. **Nunca referencie codigo**: Use nomes de dominio, nao caminhos de arquivo.

3. **Criterios de aceite**: Sempre verificaveis por qualquer pessoa, sem precisar ler codigo.

4. **Fora do escopo**: Sempre inclua quando o trabalho puder crescer alem do planejado.

5. **Uma issue = uma entrega**: Se a issue tem mais de 8 pontos, quebre em sub-issues.
