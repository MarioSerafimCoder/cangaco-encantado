# Especificação da próxima spritesheet de Nilo

Esta especificação substitui a folha provisória 4x4 quando houver animação desenhada para produção. O controlador atual deve ser adaptado ao novo número de frames, não reescrito.

## Formato

- Célula: **64x64 px**.
- Grade: uma linha por animação; sem espaços entre células.
- Canal: PNG RGBA, fundo totalmente transparente.
- Direção desenhada: Nilo olhando para a direita; o jogo espelha para a esquerda.
- Pivot do `Sprite2D`: centro da célula, `(32, 32)`.
- Baseline do pé: `y = 64` dentro da célula.
- Escala atual no mundo: `0.68`.
- Offset atual do visual: `(0, -10)` em relação ao corpo.
- O último pixel de contato do pé deve fechar com a linha do chão sem sombra embutida.

Com essa convenção, o fundo da célula cai aproximadamente no mesmo ponto que a base do collider de 24 px de Nilo. Chapéu, arma e facão podem ultrapassar a silhueta interna, mas não o canvas da célula.

## Ordem das animações

| Linha | Estado | Frames | Observação |
|---:|---|---:|---|
| 0 | `IDLE` | 4 | respiração discreta; pés imóveis |
| 1 | `RUN` | 8 | `CONTACT / DOWN / PASS / UP` por perna |
| 2 | `TURN` | 2 | antecipação e recuperação da virada |
| 3 | `TAKEOFF` | 2 | compressão e saída do chão |
| 4 | `ASCENT` | 2 | corpo subindo, silhueta limpa |
| 5 | `APEX` | 2 | suspensão curta sem distorção extrema |
| 6 | `FALL` | 2 | queda normal e rápida podem compartilhar base |
| 7 | `LAND` | 2 | contato e recuperação |
| 8 | `CROUCH` | 2 | entrada e pose sustentada |
| 9 | `HURT` | 2 | impacto e recuperação |
| 10 | `DEATH` | 4 | queda, chão e repouso |

Combate deve ficar em outra folha, mantendo a mesma célula, pivot, direção e baseline. Sugestão: facão em três sequências independentes, revólver, espingarda, cura e variantes aéreas.

## Corrida

Os contatos principais ocorrem nos frames 0 e 4. Nesses frames, o pé plantado deve permanecer na baseline. Frames de passagem elevam discretamente o corpo, sem transformar a corrida em pequenos saltos. O `run_phase` continua sendo a fonte de sincronização para frame, poeira e contato.

## Limitações da folha atual

A folha provisória não possui frames próprios para `TURN`, `TAKEOFF`, `APEX`, `FALL` e `LAND`. A versão 0.2.2 reduz distorções e calibra o bob, mas não tenta substituir desenhos ausentes com squash, rotação ou offsets maiores.

