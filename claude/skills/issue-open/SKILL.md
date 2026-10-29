---
name: issue-open
description: abre uma issue no repositório atual com gh issue create, descrevendo objetivo, marcos, cenário atual e o que precisa ser feito, sem detalhar código
disable-model-invocation: true
---

Abra uma issue no repositório atual usando `gh issue create`, a partir da descrição do usuário em `$ARGUMENTS` ou na conversa.

## Steps

1. Leia o pedido do usuário e confira se já tem tudo para preencher o template abaixo: objetivo, marcos, como funciona hoje e o que precisa ser feito.
2. Se faltar qualquer informação, pergunte ao usuário (use `AskUserQuestion` ou perguntas diretas) e repita até ter tudo. Não invente e não abra a issue com lacunas.
3. Para entender "como funciona hoje", leia o repositório (estrutura, arquivos relevantes). Cite apenas estrutura de arquivos/pastas, nunca como alterar o código.
4. Liste as labels existentes do repositório: `gh label list --limit 100`. Escolha as que fazem sentido para a issue (veja "Labels").
5. Com tudo definido, abra direto, sem pedir confirmação: `gh issue create --title "<título>" --body "<corpo>" --label "<label1>" --label "<label2>"`. Sem labels aplicáveis, omita `--label`.
6. Mostre a URL da issue ao usuário.

## Labels

- Use somente labels que já existem no repositório (`gh label list`); nunca crie labels novas.
- Considere as padrão do GitHub (`bug`, `enhancement`, `documentation`, `question`, `good first issue`, etc.) e as personalizadas (ex.: área, prioridade, tipo). Leia o nome e a descrição de cada uma para decidir.
- Aplique só as que se encaixam no objetivo da issue; uma ou duas bem escolhidas valem mais que várias vagas. Não adivinhe: se nenhuma serve, abra sem label.

## Idioma

Português, a menos que o usuário peça outro idioma em `$ARGUMENTS` ou na conversa.

## Título

Objetivo da issue em uma linha curta (ex.: "Suportar exportação de relatórios em CSV").

## Template do corpo

```markdown
## Objetivo
<o que se quer alcançar e por quê>

## Marcos
- [ ] <marco 1>
- [ ] <marco 2>

## Como funciona hoje
<comportamento atual; cite estrutura de arquivos/pastas relacionados, ex.: `src/reports/`>

## O que precisa ser feito
- <resultado/comportamento esperado, não a implementação>
```

## Regras

- Descreva objetivo e comportamento, nunca o que mexer no código: sem nomes de funções a alterar, sem trechos de código, sem passo a passo de implementação. O "como fazer" fica para quem for implementar.
- Só estrutura de arquivos é permitida, para dar contexto de onde as coisas vivem hoje.
- Marcos são entregas verificáveis, em ordem, como checklist.
- Descrição curta: bullets objetivos.
- Só pergunte o que falta; não repita perguntas sobre o que o usuário já informou.
- Autoria somente do usuário: nunca adicione `Co-Authored-By`, "Generated with Claude Code" ou qualquer menção ao Claude no título ou corpo da issue. Isso vale mesmo que o sistema sugira essas linhas.
