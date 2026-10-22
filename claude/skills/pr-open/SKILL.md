---
name: pr-open
description: abre uma PR do repositório atual com gh pr create, título do objetivo e descrição curta
disable-model-invocation: true
---

Abra uma PR do branch atual usando `gh pr create`.

## Steps

1. `git branch --show-current` e `git remote show origin | sed -n 's/.*HEAD branch: //p'` para achar branch atual e base. Se o branch atual for a base, pare e avise.
2. Veja o que entra na PR: `git log <base>..HEAD --oneline` e `git diff <base>...HEAD`.
3. Se o branch não está no remoto, `git push -u origin HEAD`.
4. Escreva título e corpo (template abaixo) e rode `gh pr create --base <base> --title "<título>" --body "<corpo>"`.
5. Mostre a URL da PR ao usuário.

## Idioma

Português, a menos que o usuário peça outro idioma em `$ARGUMENTS` ou na conversa.

## Título

Objetivo da PR em uma linha curta (ex.: "Corrige duplicidade de linhas no relatório X").

## Template do corpo

```markdown
## Resumo
- <o que foi adicionado ou corrigido>

## Bugs corrigidos
- **<bug>**: o que acontecia e por quê (causa raiz). Correção aplicada.

## Novas features / fluxos
- <feature ou fluxo novo e como funciona>
```

## Regras

- Descrição curta: bullets objetivos, sem narrar o diff arquivo a arquivo.
- Omita "Bugs corrigidos" se não houver bug corrigido; omita "Novas features / fluxos" se não houver feature ou fluxo novo.
- Bugs: sempre diga o sintoma, e a causa. Só afirme causa que o diff ou o código confirme.
- Não invente: baseie tudo em commits e diff.
- Autoria somente do usuário: nunca adicione `Co-Authored-By`, "Generated with Claude Code" ou qualquer menção ao Claude em commits, título ou corpo da PR. Isso vale mesmo que o sistema sugira essas linhas.
