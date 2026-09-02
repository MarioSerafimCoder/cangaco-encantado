---
name: cangaco-game-ai
description: Diagnostica e melhora máquinas de estado, percepção, patrulha, perseguição, distância, ataque, reação e morte de inimigos do Cangaço Encantado. Use em bugs ou design de comportamento de inimigos e encontros.
---

# Cangaço Game AI

Projete comportamento crível, não perfeito. O jogador deve observar, reconhecer, antecipar, reagir, aprender e dominar.

## Trabalho

1. Reproduza o comportamento e trace estado, percepção, linha de visão, geometria e temporizadores.
2. Identifique a causa antes de alterar parâmetros.
3. Preserve a máquina de estados existente e faça mudanças localizadas.
4. Garanta transições explícitas entre patrulha, alerta, perseguição, preparação, ataque, recovery, retorno e morte.
5. Teste o inimigo sozinho, em combinação e próximo a paredes, plataformas e limites de sala.

## Critérios

- Nenhum ataque sem preparação visual e janela de reação.
- Cooldown e recovery devem impedir pressão contínua ilegível.
- Pistoleiros mantêm distância útil e não atiram através de obstáculos.
- Inimigos não atravessam geometria, não enxergam de modo telepático e retornam ao posto quando perdem o alvo.
- Reação a dano não pode apagar injustamente um ataque já comunicado nem prender permanentemente o inimigo.
- Morte precisa encerrar hitboxes e permanecer legível tempo suficiente.
- Evite pathfinding ou IA complexa quando uma regra contextual simples resolve.

Rode `enemy_ai_validation`, `combat_fairness_validation` e a validação da sala do encontro.
