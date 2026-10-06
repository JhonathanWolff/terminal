#!/bin/bash
cd "$(dirname "$0")"

mkdir -p ~/.claude/skills
for skill_dir in */SKILL.md; do
  skill_name=$(dirname "$skill_dir")
  ln -sfn "$(pwd)/$skill_name" ~/.claude/skills/"$skill_name"
  echo "Skill instalada: $skill_name -> ~/.claude/skills/$skill_name"
done

LINE="Se existir HANDOFF.md na raiz do projeto, leia-o antes de qualquer coisa e continue o trabalho a partir dos Next Steps."
grep -qF "$LINE" ~/.claude/CLAUDE.md 2>/dev/null || echo "$LINE" >> ~/.claude/CLAUDE.md
