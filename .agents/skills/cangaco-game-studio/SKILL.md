---
name: cangaco-game-studio
description: Roteia e coordena melhorias multidisciplinares do vertical slice de Cangaço Encantado entre gameplay, level design, IA, arte 2D, economia e verificação. Use somente quando a mesma tarefa exigir dois ou mais desses domínios.
---

# Cangaço Game Studio

Coordene uma equipe enxuta sem substituir a arquitetura existente ou criar burocracia. Se uma Skill de domínio resolver a tarefa, use apenas ela.

## Roteamento

- Experiência, regras e combate: `cangaco-game-designer`.
- Espaço, arquitetura e encounters: `cangaco-level-designer`.
- Inimigos e estados: `cangaco-game-ai`.
- Sprites, animações e atlas: `cangaco-2d-assets`.
- Loja e recompensas: `cangaco-economy-designer`.

## Coordenação

1. Estude o estado atual e formule um problema compartilhado, não soluções isoladas.
2. Classifique P0–P3 e escolha somente os domínios necessários.
3. Defina invariantes que não podem regredir: progressão, save, colisões, identidade visual e controles.
4. Organize passes coerentes e incrementais; não misture redesign amplo com correção urgente.
5. Integre as decisões numa única experiência e faça autorrevisão por domínio.
6. Execute os gates descritos em [references/quality-gates.md](references/quality-gates.md).

Não crie agentes ou processos paralelos apenas para simular um estúdio. Delegação precisa reduzir tempo ou aumentar confiança de uma tarefa realmente independente.
